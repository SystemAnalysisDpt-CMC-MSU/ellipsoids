function updateallconf()
confRepoMgr=gras.ellapx.uncertmixcalc.conf.ConfRepoMgr();
confRepoMgr.updateAll();
confRepoMgr=gras.ellapx.uncertmixcalc.conf.sysdef.ConfRepoMgr();
confRepoMgr.updateAll();
gras.ellapx.uncertmixcalc.test.updateallconf();