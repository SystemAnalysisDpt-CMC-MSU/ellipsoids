function resObj = run_generic_tests(fConstructFactory,testCaseName,...
    confCMat,testMarker,varargin)
% RUN_CONT_TESTS runs most of the tests based on specified patters
% for markers, test cases, tests names
%
% Input:
%   regular:
%       fConstructFactory: function_handle[1,1] - function that is
%           responsible for constructing the reachability factories
%       testCaseName: char[1,] - test case name 
%       confCMat: cell[nConfs,3] - test configuration matrix
%       testMarker: char[1,] - marker for the tests (for instance to
%          distinguish tests for discrete and continuous systems)
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
suiteCMat = cell(2,nConfs);
%
for iConf = 1:nConfs
    confName = confCMat{iConf, 1};
    confTestsVec = confCMat{iConf, 2};
    inPointVecList = confCMat{iConf, 3};
    outPointVecList = confCMat{iConf, 4};
    if confTestsVec(1)
        suiteCMat{1,iConf} = loader.load_tests_from_test_case(...
            testCaseName,...
            fConstructFactory(confName,crm,crmSys,true,false),...
            inPointVecList,outPointVecList,testCasePropList{:},...
            'marker', [confName,'_IsBackTrueIsEvolveFalse',testMarker]);
    end
    if confTestsVec(2)
        suiteCMat{2,iConf} = loader.load_tests_from_test_case(...
            testCaseName,...
            fConstructFactory(confName,crm,crmSys,true,true),...
            inPointVecList,outPointVecList,testCasePropList{:},...
            'marker',[confName,'_IsBackTrueIsEvolveTrue',testMarker]);
    end
end
%%
isnEmptyMat=~cellfun('isempty',suiteCMat);
testLists = cellfun(@(x)x.tests,suiteCMat(isnEmptyMat),...
    'UniformOutput',false);
%
testVec = horzcat(testLists{:});
suite = mlunitext.test_suite(testVec,suitePropList{:});
suiteFilteredObj = suite.getCopyFiltered(filterProp{:});
resObj = runner.run(suiteFilteredObj);