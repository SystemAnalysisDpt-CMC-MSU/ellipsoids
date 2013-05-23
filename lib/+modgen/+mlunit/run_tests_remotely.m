function run_tests_remotely(inpArgList,confRepoMgr,...
    log4jConfiguratorName,emailSubjSuffixName,runnerName,fTempDirGetter,...
    scriptName)
import(log4jConfiguratorName);
%
try
    %% Configure Log4j
    confName=confRepoMgr.getCurConfName();
    Log4jConfigurator.unlockConfiguration();
    Log4jConfigurator.configure(confRepoMgr);
    Log4jConfigurator.lockConfiguration();
    %% Log configuration
    logger=Log4jConfigurator.getLogger();
    logger.info(sprintf('Test configuration:\n%s',...
        evalc('strucdisp(confRepoMgr.getConf(confName))')));
    %
    emailLogger=modgen.logging.EmailLoggerBuilder.fromConfRepoMgr(...
        confRepoMgr,runnerName,emailSubjSuffixName,....
        Log4jConfigurator.getMainLogFileName(),fTempDirGetter);
    %
    try
        nParallelProcesses=confRepoMgr.getParam(...
            'executionControl.nParallelProcesses');
        parallelConfiguration = confRepoMgr.getParam(...
            'executionControl.parallelConfiguration');
        confFHandle=str2func(['@(x)',log4jConfiguratorName,...
            '.configure(x,''isLockAfterConfigure'',true)']);
        testRunner=mlunitext.RemoteTestRunner(emailLogger,fTempDirGetter);
        testRunner.runTestPack(scriptName,inpArgList{:},...
            'nParallelProcesses',nParallelProcesses,...
            'parallelConfiguration',parallelConfiguration,...
            'confRepoMgr',confRepoMgr,'hConfFunc',confFHandle);
    catch meObj
        emailLogger.sendMessage('ERROR',...
            modgen.exception.me.obj2plainstr(meObj));
        rethrow(meObj);
    end
catch meObj
    disp(errst2str(meObj));
    rethrow(meObj);
end
    