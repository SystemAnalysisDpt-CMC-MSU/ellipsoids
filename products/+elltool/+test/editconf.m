function editconf(confName)
confRepoMgr=elltool.test.configuration.AdaptiveConfRepoManager();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);