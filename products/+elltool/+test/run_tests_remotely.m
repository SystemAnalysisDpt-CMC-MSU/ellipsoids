function resultVec=run_tests_remotely(markerStr,confName)
import elltool.test.logging.Log4jConfigurator;
%
if nargin<1
    markerStr='';
else
    markerStr=[',[marker:',markerStr,']'];
end
if nargin<2
    confName='default';
end
RUNNER_NAME='EllTestRunner';
SCRIPT_NAME='elltool.test.run_tests';
%
runnerName=RUNNER_NAME;
log4jConfiguratorName='elltool.test.logging.Log4jConfigurator';
fTempDirGetter=@elltool.test.TmpDataManager.getDirByCallerKey;
%
try
    %% Read test configuration
    confRepoMgr=elltool.test.configuration.AdaptiveConfRepoManager();
    confRepoMgr.selectConf(confName);

    resultVec=modgen.mlunit.run_tests_remotely({},confRepoMgr,...
    log4jConfiguratorName,markerStr,runnerName,...
    fTempDirGetter,SCRIPT_NAME,'isConsoleOutputCollected',false);
catch meObj
    disp(modgen.exception.me.obj2plainstr(meObj));
    rethrow(meObj);
end
    