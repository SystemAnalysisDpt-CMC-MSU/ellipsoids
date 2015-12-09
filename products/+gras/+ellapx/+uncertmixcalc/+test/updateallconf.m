function updateallconf()
% UPDATEALLCONF updates all the configurations in the nested packages
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-11-24 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
confRepoMgr=gras.ellapx.uncertmixcalc.test.conf.ConfRepoMgr();
confRepoMgr.updateAll(true);
confRepoMgr=gras.ellapx.uncertmixcalc.test.conf.sysdef.ConfRepoMgr();
confRepoMgr.updateAll(true);