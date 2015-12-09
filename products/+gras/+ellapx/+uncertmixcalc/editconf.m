function editconf(confName)
confRepoMgr=gras.ellapx.uncertmixcalc.conf.ConfRepoMgr();
%confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.updateConf(confName);
confRepoMgr.editConf(confName);