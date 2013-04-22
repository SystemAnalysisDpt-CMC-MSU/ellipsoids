function listsysconfs()
% LISTSYSCONFS lists all available system configurations
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2013-04-10 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
%
confRepoMgr=gras.ellapx.uncertcalc.test.regr.conf.sysdef.ConfRepoMgr();
confRepoMgr.deployConfTemplate('*');
confRepoMgr.getConfNameList()
