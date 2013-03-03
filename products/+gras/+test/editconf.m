function editconf(confName)

confRepoMgr=gras.test.configuration.AdaptiveConfRepoManager();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);

end
