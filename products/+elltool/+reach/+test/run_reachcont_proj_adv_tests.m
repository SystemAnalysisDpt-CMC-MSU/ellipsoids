function results = run_reachcont_proj_adv_tests(inpConfAdvTestList, inpModeAdvTestList)
import modgen.common.throwerror;
import modgen.cell.cellstr2expression;
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
FULL_CONF_LIST = {'ltisys', 'test2dbad'};
FULL_MODE_LIST = {'fix','rand'};
suiteList = {};
%
if nargin < 1
    modeList = FULL_MODE_LIST;
    confList = FULL_CONF_LIST;
else
    nInpConf = numel(inpConfAdvTestList);
    nInpMode = numel(inpModeAdvTestList);
    if (nargin < 2)||(nInpMode==1 && strcmp(inpModeAdvTestList,'*'))
        modeList = FULL_MODE_LIST;
    elseif sum(ismember(inpModeAdvTestList,FULL_MODE_LIST)) == numel(inpModeAdvTestList)
        modeList = inpModeAdvTestList;
    else
        throwerror('wrongInput:unknownMode',...
            'Unexpected input mode: %s. Allowed modes: %s.',...
             inpModeAdvTestList{~ismember(inpModeAdvTestList,FULL_MODE_LIST)},...
             cellstr2expression(FULL_MODE_LIST));
    end    
    %
    if (nInpConf==1 && strcmp(inpConfAdvTestList,'*'))
        confList = FULL_CONF_LIST;
    elseif sum(ismember(inpConfAdvTestList,FULL_CONF_LIST)) == numel(inpConfAdvTestList)
        confList = inpConfAdvTestList;
    else
        throwerror('wrongInput:unknownConf',...
            'Unexpected input configuration: %s. Allowed configurations: %s.',...
             inpConfAdvTestList{~ismember(inpConfAdvTestList,FULL_CONF_LIST)},...
             cellstr2expression(FULL_CONF_LIST));
    end
end    
%
nConf = numel(confList);
nMode = numel(modeList);
for iConf = 1:nConf
    for iMode = 1:nMode
        suiteList{end + 1} = loader.load_tests_from_test_case(...
            'elltool.reach.test.mlunit.ContinuousReachProjAdvTestCase',...
            confList{iConf}, crm, crmSys, modeList{iMode});
    end
end    
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
results=runner.run(suite);
end