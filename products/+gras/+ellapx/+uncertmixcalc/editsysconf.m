function editsysconf(confName)
confRepoMgr=gras.ellapx.uncertmixcalc.conf.sysdef.ConfRepoMgr();
confRepoMgr.updateConf(confName);
confRepoMgr.editConf(confName);