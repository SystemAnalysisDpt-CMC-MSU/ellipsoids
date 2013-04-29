function copysysconf(confName,toConfName)
confRepoMgr=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
confRepoMgr.copyConf(confName,toConfName);