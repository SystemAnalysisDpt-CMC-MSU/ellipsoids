function copyconf(confName,toConfName)
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.copyConf(confName,toConfName);