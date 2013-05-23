function copyconf(confName,toConfName)
%COPYCONF - copies configuration confName to configuration 
%           toConfName
%
%Input:
%   regular:
%       confName:char[1,] - name of copied configuration
%       toConfName:char[1,] - name of new copy
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    
%$Date: 2012-11-17 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics 
%            and Computer Science,
%            System Analysis Department 2012 $
%
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.copyConf(confName,toConfName);