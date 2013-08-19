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
%       testCaseNameList: char[1,] (or char cell [1,nTestCases]) - name(s)
%          of testcase class (or classes)
%          ('smartdb.relations.test.mlunit_test_dynamicrelation' for
%          instance)
%
%   optional:
%       testName: char[1,] - name of a concrete test within a specified
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
[reg,prop]=modgen.common.parseparams(varargin);
nProp=length(prop);
if rem(nProp,2)~=0
    reg=[reg,prop(1)];
    prop(1)=[];
    nProp=nProp-1;
end
%
if ~isempty(reg)
    if length(reg)>1
        throwerror('wrongInput',...
            'at maximum 2 regular input arguments are expected');
    else
        testName=reg{1};
    end
end
testArgList={};
suiteArgList={};
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'testparams',
            if ~iscell(prop{k+1})
                throwerror('wrongInput',...
                    'propety %s is expected to be a cell array',prop{k});
            end
            testArgList=prop{k+1};
        case 'suiteparams',
            if ~iscell(prop{k+1})
                throwerror('wrongInput',...
                    'propety %s is expected to be a cell array',prop{k});
            end
            suiteArgList=prop{k+1};
        otherwise,
            throwerror('wrongInput',...
                'unknown property %s',prop{k});
    end
end
%
if ischar(testCaseNameList),
    testCaseNameList={testCaseNameList};
end
nTestCases=numel(testCaseNameList);
%
if ~modgen.system.ExistanceChecker.isVar('testName')
    runner = mlunitext.text_test_runner(1, 1);
    loader = mlunitext.test_loader;
    testCVec=cell(1,nTestCases);
    for iTestCase=1:nTestCases,
        testCaseName=testCaseNameList{iTestCase};
        test_suite = loader.load_tests_from_test_case(testCaseName,...
            testArgList{:});
        testCVec{iTestCase}=test_suite.tests;
    end
    test_suite = mlunitext.test_suite(horzcat(testCVec{:}),suiteArgList{:});
    testResVec=runner.run(test_suite);
else
    runner = mlunitext.text_test_runner(1, 1);
    test_suite=mlunitext.test_suite(suiteArgList{:});
    for iTestCase=1:nTestCases,
        testCaseName=testCaseNameList{iTestCase};
        constructorName=modgen.string.splitpart(testCaseName,'.','last');
        metaClass=meta.class.fromName(testCaseName);
        if isempty(metaClass)
            throwerror('noSuchClass',...
                'test case %s not found', testCaseName);
        end
        %
        methodList=...
            cellfun(@(x)x.Name,metaClass.Methods,'UniformOutput',false);
        isMatchedVec=...
            cellfun(@(x)(~isempty(regexp(x,testName, 'once'))&&...
            ~strcmp(x,constructorName)),methodList);
        testList=methodList(isMatchedVec);
        if isempty(testList)
            throwerror('wrongInput',...
                ['no test methods matching the pattern ',...
                '"%s" were found in test case %s'],testName, testCaseName);
        end
        %
        for iTest=1:length(testList)
            curTestName=testList{iTest};
            test_suite.add_test(feval(testCaseName,curTestName,...
                testCaseName,testArgList{:}));
        end
    end
    %
    testResVec=runner.run(test_suite);
end
