function testResVec=runtestcase(testCaseNameList,varargin)
% RUNTESTCASE runs all the tests from a specified test suite
%
% Usage:
%   mlunitext.runtestcase(testCaseName)
%   mlunitext.runtestcase(testCaseName,testName)
%   mlunitext.runtestcase(testCaseName,testName,'testParams',{'somestring',[1 2 3],3})
%
% Input:
%   regular:
%       testCaseMethodNameList: char[1,]/cell[1,nTestCase] of char[1,nTestCases]
%           - name(s) of testcase class (or classes)
%          ('modgen.common.test.mlunit_test_common' for instance). Test
%          case name can contain a test name as well - like
%          'modgen.common.test.mlunit_test_common.testAbsRelCompare'
%
%   optional:
%       testNameList: char[1,] - name of a concrete test within a specified
%           test case (test cases, respectively) ('test_toCell' for
%           instance)
%
%   properties:
%       testParams: cell[1,nTestParams] - a list of test parameters
%       suiteParams: cell[1,nSuiteParams] - a list of suite parameters
%
%
% Example:
%   mlunitext.runtestcase('smartdb.relationoperators.test.mlunit_test_selfjoin')
%   mlunitext.runtestcase('smartdb.relations.test.mlunit_test_dynamicrelation','test_toCell')
%   mlunitext.runtestcase('smartdb.relationoperators.test.mlunit_test_selfjoin','^test_',...
%       'suiteParams',{'nParallelProcesses',2})
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2013$
%
%
import modgen.common.throwerror;
[regArgList,isTestNameSpec,testArgList,suiteArgList]=modgen.common.parseparext(varargin,...
    {'testParams','suiteParams';...
    {},{};...
    @iscell,@iscell},[0 1]);
%
if ischar(testCaseNameList),
    testCaseNameList={testCaseNameList};
end
nTestCases=numel(testCaseNameList);
if isTestNameSpec
    testNameList=regArgList{1};
    if ischar(testNameList)
        testNameList={testNameList};
    end
else
    testNameList=cell(1,nTestCases);
end
%
nTestNames=numel(testNameList);
if nTestCases~=nTestNames
    throwerror('wrongInput',['if more than one test name specified ',...
        'in testNameList the number of test names should match the ',...
        'number of test cases']);
end
%
%
for iTestCase=1:nTestCases,
    testCaseAndMethodName=testCaseNameList{iTestCase};
    testName=testNameList{iTestCase};
    if isempty(testName)
        isnClass=isempty(meta.class.fromName(testCaseAndMethodName));
        if isnClass
            indLastDot=find(testCaseAndMethodName=='.',1,'last');
            indSlashVec=find(testCaseAndMethodName=='/');
            nSlashes=numel(indSlashVec);
            if nSlashes>1
                throwerror('wrongInput',['%s can only contain up to one ',...
                    'right slash separating class and method names'],...
                    testCaseName);
            elseif nSlashes==1
            %
                indSlash=indSlashVec;
                if indSlash<indLastDot
                    throwerror('wrongInput',['%s cannot contain any dots',...
                        'after a right slash'],...
                        testCaseName);
                end
                indSep=indSlash;
            else
                if isempty(indLastDot)
                    indLastDot=numel(testCaseAndMethodName)+1;
                end
                indSep=indLastDot;
            end
            %
            testName=testCaseAndMethodName(indSep+1:end);
            testCaseName=testCaseAndMethodName(1:indSep-1);
            isnClass=isempty(meta.class.fromName(testCaseName));
            if isnClass
                throwerror('wrongInput:noSuchClass',...
                    '%s is neither method nor class name',...
                    testCaseName);
            end
            testCaseNameList{iTestCase}=testCaseName;
            testNameList{iTestCase}=testName;
        end
    end
end
%
testRunner = mlunitext.text_test_runner(1, 1);
testSuite=mlunitext.test_suite(suiteArgList{:});
%
for iTestCase=1:nTestCases,
    testCaseName=testCaseNameList{iTestCase};
    testName=testNameList{iTestCase};
    %
    constructorName=modgen.string.splitpart(testCaseName,'.','last');
    metaClass=meta.class.fromName(testCaseName);
    if isempty(metaClass)
        throwerror('wrongInput:noSuchClass',...
            'test case %s not found', testCaseName);
    end
    if isempty(testName)
        tempTestSuite = mlunitext.test_suite.fromTestCaseNameList(...
            {testCaseName},testArgList{:});
        testSuite.add_tests(tempTestSuite.tests);
    else
        %
        methodList=...
            cellfun(@(x)x.Name,metaClass.Methods,'UniformOutput',false);
        isMatchedVec=...
            cellfun(@(x)(~isempty(regexp(x,testName, 'once'))&&...
            ~strcmp(x,constructorName)),methodList);
        testList=methodList(isMatchedVec);
        if isempty(testList)
            throwerror('wrongInput:noSuchMethod',...
                ['no test methods matching the pattern ',...
                '"%s" were found in test case %s'],testName, testCaseName);
        end
        %
        for iTest=1:length(testList)
            curTestName=testList{iTest};
            testSuite.add_test(feval(testCaseName,curTestName,...
                testCaseName,testArgList{:}));
        end
    end
end
%
testResVec=testRunner.run(testSuite);