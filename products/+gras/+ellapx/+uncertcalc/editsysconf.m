function editsysconf(confName)
confRepoMgr=gras.ellapx.uncertcalc.conf.sysdef.ConfRepoMgr();
confRepoMgr.updateConf(confName);
confRepoMgr.editConf(confName);