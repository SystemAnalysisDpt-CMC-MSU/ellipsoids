function results = run_reachproj_adv_tests(inpConfAdvTestList, inpModeAdvTestList)
import modgen.common.throwerror;
%
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
crm = gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
crmSys = gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
%
fullConfList = {'ltisys', 'test2dbad'};
fullModeList = {'fix','rand'};
suiteList = {};
%
if nargin < 1
    modeList = fullModeList;
    confList = fullConfList;
else
    nInpConf = numel(inpConfAdvTestList);
    nInpMode = numel(inpModeAdvTestList);
    if (nargin < 2)||(nInpMode==1 && strcmp(inpModeAdvTestList,'*'))
        modeList = fullModeList;
    elseif sum(ismember(inpModeAdvTestList,fullModeList)) == numel(inpModeAdvTestList)
        modeList = inpModeAdvTestList;
    else
        throwerror('wrongInput:unknownMode',...
            'Unexpected input mode: %s. Allowed modes: fix, rand. ',...
             inpModeAdvTestList{~ismember(inpModeAdvTestList,fullModeList)});
    end    
    %
    if (nInpConf==1 && strcmp(inpConfAdvTestList,'*'))
        confList = fullConfList;
    elseif sum(ismember(inpConfAdvTestList,fullConfList)) == numel(inpConfAdvTestList)
        confList = inpConfAdvTestList;
    else
        throwerror('wrongInput:unknownConf',...
            'Unexpected input configuration: %s. Allowed configurations: ltisys, test2dbad.',...
             inpConfAdvTestList{~ismember(inpConfAdvTestList,fullConfList)});
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