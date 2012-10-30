function run_tests_remotely(markerStr,confName)
import elltool.test.logging.Log4jConfigurator;
%
if nargin<1
    markerStr='';
else
    markerStr=[',',markerStr];
end
if nargin<2
    confName='default';
end
RUNNER_NAME='EllTestRunner';
SCRIPT_NAME='elltool.test.run_tests';
%
runnerName=[RUNNER_NAME,markerStr];
log4jConfiguratorName='elltool.test.logging.Log4jConfigurator';
fTempDirGetter=@elltool.test.TmpDataManager.getDirByCallerKey;
svnRev=modgen.subversion.getrevisionbypath(...
    fileparts(mfilename('fullpath')),'ignoreErrors',true);
emailSubjSuffName=[',[ellTbxRev:',svnRev,']'];
try
    %% Read test configuration
    confRepoMgr=elltool.test.configuration.AdaptiveConfRepoManager();
    confRepoMgr.selectConf(confName);

    modgen.mlunit.run_tests_remotely({},confRepoMgr,...
    log4jConfiguratorName,emailSubjSuffName,runnerName,...
    fTempDirGetter,SCRIPT_NAME);
catch meObj
    disp(errst2str(meObj));
    rethrow(meObj);
end
    