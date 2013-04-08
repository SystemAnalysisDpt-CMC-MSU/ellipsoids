function setconf(confName)
%SETCONF - selects the configuration confName as current
%
%Input:
%   regular:
%       confName:char[1,] - name of configuration to set
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $ 
%$Date: 2012-11-17$
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2012 $
%
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.selectConf(confName);
elltool.conf.Properties.setConfRepoMgr(confRepoMgr);