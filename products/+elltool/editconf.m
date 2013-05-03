function editconf(confName)
%EDITCONF - edit configuration confName
%
%Input:
%   regular:
%       confName:char[1,] - name of configuration to edit
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    
%$Date: 2012-11-17 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics 
%            and Computer Science,
%            System Analysis Department 2012 $
%
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);