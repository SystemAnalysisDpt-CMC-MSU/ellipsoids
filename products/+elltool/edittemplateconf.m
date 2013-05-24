function edittemplateconf(confName)
%EDITTEMPLAECONF edit configuration template named confName
%
%Input:
%   regular:
%       confName:char[1,] - name of configuration to edit
%
%$Author: Petr Gagarinov <pgagarinov@gmail.com> $    $Date: 09-Apr-2013 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
confRepoMgr.editConfTemplate(confName);