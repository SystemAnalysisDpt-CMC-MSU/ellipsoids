function resObj = run_generic_tests(testCaseName,confCMat,varargin)
% RUN_CONT_TESTS runs most of the tests based on specified patters
% for markers, test cases, tests names
%
% Input:
%   regular:
%       testCaseName: char[1,] - test case name 
%       confCMat: cell[nConfs,3] - test configuration matrix
%       
%   optional:
%       confNameList: cell[1,nTestConfs] of char[1,] - list of
%           configurations to test, if not specified, all configurations
%           are tested
%   properties:
%       nParallelProcesses: double[1,1] - if nParallelProcesses>1 then
%           tests are run in parallel in the corresponding number of parallel
%           processes (Parallel Toolbox is required)
%       reCache: logical[1,1] - if true, test results are rechaced on disk
%       filter: cell[1,3] with the following elements
%           markerRegExp: char[1,] - regexp for marker AND/OR configuration
%               names, default is '.*' which means 'all cofigs'
%           testCaseRegExp: char[1,] - regexp for test case names, same 
%               default
%           testRegExp: char[1,] - regexp for test names, same default
%
% Output:
%   resObj: mlunitext.text_test_run[1,1] - test result object
%
% $Author: Komarov Yuri <ykomarov94@gmail.com> $
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $
% $Date: 2015-30-10 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2015$
%
import elltool.reach.ReachFactory;
%
[restArgList,~,testCasePropList]=modgen.common.parseparext(varargin,...
    {'reCache';false;'islogical(x)'},[],'propRetMode','list');
[restArgList,~,filterProp]=modgen.common.parseparext(restArgList,{'filter';{}});
[reg,suitePropList]=modgen.common.parseparams(restArgList);
%
crm = elltool.control.test.conf.ConfRepoMgr();
crmSys = elltool.control.test.conf.sysdef.ConfRepoMgr();
%
if ~isempty(reg)
    confNameList=reg{1};
    if ischar(confNameList)
        confNameList={confNameList};
    end
else
    confNameList=crm.deployConfTemplate('*');
end
%%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
isSelVec=ismember(confCMat(:,1),confNameList);
confCMat=confCMat(isSelVec,:);
%
nConfs = size(confCMat, 1);
suiteList = [];
%
for iConf = 1:nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
    inPointVecList = confCMat{iConf, 3};
    outPointVecList = confCMat{iConf, 4};
    if confTestsVec(1)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            testCaseName,...
            ReachFactory(confName,crm,crmSys,true,false),...
            inPointVecList,outPointVecList,testCasePropList{:},...
            'marker', [confName,'_IsBackTrueIsEvolveFalse']); %#ok<AGROW>
    end
    if confTestsVec(2)
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            testCaseName,...
            ReachFactory(confName,crm,crmSys,true,true),...
            inPointVecList,outPointVecList,testCasePropList{:},...
            'marker',[confName,'_IsBackTrueIsEvolveTrue']); %#ok<AGROW>
    end
end
%%
testLists = cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
testVec = horzcat(testLists{:});
suite = mlunitext.test_suite(testVec,suitePropList{:});
suiteFilteredObj = suite.getCopyFiltered(filterProp{:});
resObj = runner.run(suiteFilteredObj);