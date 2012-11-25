function listconf()
%LISTCONF gives a list of existing configurations
%
%No input or output, just displays list of configuration
%
%$Author: Zakharov Eugene  <justenterrr@gmail.com> $    $Date: 17-november-2012 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
confRepoMgr=elltool.conf.Properties.getConfRepoMgr();
disp(confRepoMgr.getConfNameList().');