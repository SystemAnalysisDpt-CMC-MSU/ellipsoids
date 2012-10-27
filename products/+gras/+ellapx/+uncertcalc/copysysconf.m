function copysysconf(confName,toConfName)
confRepoMgr=gras.ellapx.uncertcalc.conf.sysdef.ConfRepoMgr();
confRepoMgr.copyConf(confName,toConfName);