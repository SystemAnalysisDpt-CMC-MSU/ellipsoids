function results=run_tests(varargin)
% RUN_TESTS runs tests based on specified patters
%  for markers, test cases, tests names
%
% Input:
%   optional:
%       markerRegExp: char[1,] - regexp for marker AND/OR configuration
%           names, default is '.*' which means 'all cofigs'
%       testCaseRegExp: char[1,] - regexp for test case names, same default
%       testRegExp: char[1,] - regexp for test names, same default
%
% Output:
%   results: mlunitext.text_test_run[1,1] - test result
%
% Example:
%
%   gras.ellapx.uncertmixcalc.test.run_tests('springs_2',...
%       'gras.ellapx.uncertmixcalc.test.mlunit.SuiteMixTubeFort','testCompare')  
%
%   gras.ellapx.uncertmixcalc.test.run_tests('.*',...
%       ''gras.ellapx.uncertmixcalc.test.mlunit.SuiteMixTubeFort'','testCompare')
%
%   gras.ellapx.uncertmixcalc.test.run_tests('springs_2',...
%       '.*','testCompare')
%
% $Authors: Peter Gagarinov <pgagarinov@gmail.com>
% $Date: 1-Nov-2015 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012-2015$
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm=gras.ellapx.uncertmixcalc.test.conf.ConfRepoMgr();
confNameList=crm.deployConfTemplate('*');
confNameList=setdiff(confNameList,{'default'});
crmSys=gras.ellapx.uncertmixcalc.test.conf.sysdef.ConfRepoMgr();
crmSys.deployConfTemplate('*');
nConfs=length(confNameList);
%
suiteList=cell(1,nConfs);
for iConf=1:nConfs
    confName = confNameList{iConf};
    %
    if ~isempty(strfind(confName, 'springs_'))
        suiteList{iConf}=loader.load_tests_from_test_case(...
            'gras.ellapx.uncertmixcalc.test.mlunit.SuiteMixTubeFort',...
            crm,crmSys,confName,'marker',confName);
    else
        suiteList{iConf}=loader.load_tests_from_test_case(...
            'gras.ellapx.uncertmixcalc.test.mlunit.SuiteBasic',...
            crm,crmSys,confName);
    end
end
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
suite=suite.getCopyFiltered(varargin{:});
%
resList{1}=runner.run(suite);
%
results=[resList{:}];