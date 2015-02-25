function updateallconf()
%UPDATEALLCONF - update all configurations for all branches (computers)
%
%$Author: Peter Gagarinov  <pgagarinov@gmail.com> $    
%$Date: 2-Nov-2015 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics 
%            and Computer Science,
%            System Analysis Department 2015 $
%
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.updateAll(true);