function editconf(confName)
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);