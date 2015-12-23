function updateallconf()
% UPDATEALLCONF updates all the configurations in the nested packages
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2011-09-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
confRepoMgr=gras.ellapx.uncertcalc.test.regr.conf.ConfRepoMgr();
confRepoMgr.updateAll(true);
confRepoMgr=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
confRepoMgr.updateAll(true);