function copysysconf(confName,toConfName)
confRepoMgr=gras.ellapx.uncertmixcalc.conf.sysdef.ConfRepoMgr();
confRepoMgr.copyConf(confName,toConfName);