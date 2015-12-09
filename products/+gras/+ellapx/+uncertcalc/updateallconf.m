function updateallconf()
confRepoMgr=gras.ellapx.uncertcalc.conf.ConfRepoMgr();
confRepoMgr.updateAll();
confRepoMgr=gras.ellapx.uncertcalc.conf.sysdef.ConfRepoMgr();
confRepoMgr.updateAll();
gras.ellapx.uncertcalc.test.updateallconf();