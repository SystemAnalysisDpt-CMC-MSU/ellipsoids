function results = run_reach_proj_adv_tests(...
    testCaseNameStr, inpConfAdvTestList, inpModeAdvTestList)
% 'fix' - a mode with fixed projection matrix
% 'rand' - a mode with random projection matrix
%
% elltool.reach.test.run_reachcont_proj_adv_tests() - run test for all
%       configurations in 'fix' mode.
%
% elltool.reach.test.run_reachcont_proj_adv_tests({'conf1'}) - run test for
%       'conf1' configuration in 'fix' mode.
%
% If you want to run additionaly 'rand' mode you can
% do one of the folowing:
%
% elltool.reach.test.run_reachcont_proj_adv_tests('*',{'rand'}) - run test
%       for all configurations in 'rand' mode.
%
% elltool.reach.test.run_reachcont_proj_adv_tests('*','*') - run test
%       for all configurations in both 'rand' mode and 'fix' mode.
%
% elltool.reach.test.run_reachcont_proj_adv_tests({'conf1'},'*') - run test
%       in 'conf1' configuration in both 'rand' mode and 'fix' mode.
%
import modgen.common.throwerror;
import modgen.cell.cellstr2expression;
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
DEFAULT_CONF_LIST = {'ltisys', 'test2dbad'};
% DEFAULT_CONF_LIST = {'ltisys'};
DEFAULT_MODE_LIST = {'fix'};
ALLOWED_MODE_LIST = {'fix','rand'};
suiteList = {};
%
if nargin < 2
    modeList = DEFAULT_MODE_LIST;
    confList = DEFAULT_CONF_LIST;
else
    nInpConf = numel(inpConfAdvTestList);
    nInpMode = numel(inpModeAdvTestList);
    if nargin < 3
        modeList = DEFAULT_MODE_LIST;
    elseif (nInpMode==1 && strcmp(inpModeAdvTestList,'*'))
        modeList = ALLOWED_MODE_LIST;
    elseif sum(ismember(inpModeAdvTestList,DEFAULT_MODE_LIST)) == numel(inpModeAdvTestList)
        modeList = inpModeAdvTestList;
    else
        throwerror('wrongInput:unknownMode',...
            'Unexpected input mode: %s. Allowed modes: %s.',...
            inpModeAdvTestList{~ismember(inpModeAdvTestList,ALLOWED_MODE_LIST)},...
            cellstr2expression(ALLOWED_MODE_LIST));
    end
    %
    if (nInpConf==1 && strcmp(inpConfAdvTestList,'*'))
        confList = DEFAULT_CONF_LIST;
    elseif sum(ismember(inpConfAdvTestList,DEFAULT_CONF_LIST)) == numel(inpConfAdvTestList)
        confList = inpConfAdvTestList;
    else
        throwerror('wrongInput:unknownConf',...
            'Unexpected input configuration: %s. Allowed configurations: %s.',...
            inpConfAdvTestList{~ismember(inpConfAdvTestList,DEFAULT_CONF_LIST)},...
            cellstr2expression(DEFAULT_CONF_LIST));
    end
end
%
nConf = numel(confList);
for iConf = 1:nConf
    confName=confList{iConf};
    suiteList{end + 1} = loader.load_tests_from_test_case(...
        testCaseNameStr,...
        confList{iConf}, crm, crmSys, modeList,...
        'marker',confName);
end
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
results=runner.run(suite);
end