function editconf(confName)
confRepoMgr=gras.ellapx.uncertcalc.conf.ConfRepoMgr();
%confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.updateConf(confName);
confRepoMgr.editConf(confName);