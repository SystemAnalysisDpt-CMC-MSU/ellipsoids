function run_tests_remotely(markerStr,confName)
import gras.test.logging.Log4jConfigurator;
%
if nargin<1
    markerStr='';
else
    markerStr=[',',markerStr];
end
if nargin<2
    confName='default';
end
RUNNER_NAME='GRASTestRunner';
SCRIPT_NAME='gras.test.run_tests';
%
runnerName=[RUNNER_NAME,markerStr];
log4jConfiguratorName='gras.test.logging.Log4jConfigurator';
fTempDirGetter=@gras.test.TmpDataManager.getDirByCallerKey;
svnRev=modgen.subversion.getrevisionbypath(...
    fileparts(mfilename('fullpath')),'ignoreErrors',true);
emailSubjSuffName=[',[grasRev:',svnRev,']'];
try
    %% Read test configuration
    confRepoMgr=gras.test.configuration.AdaptiveConfRepoManager();
    confRepoMgr.selectConf(confName);

    modgen.mlunit.run_tests_remotely({},confRepoMgr,...
    log4jConfiguratorName,emailSubjSuffName,runnerName,...
    fTempDirGetter,SCRIPT_NAME);
catch meObj
    disponoff([],errst2str(meObj));
    rethrow(meObj);
end
    