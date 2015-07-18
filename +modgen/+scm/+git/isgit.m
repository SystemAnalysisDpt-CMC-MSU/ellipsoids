function res=isgit(pathStr)
persistent mp
if isempty(mp)
    mp=containers.Map();
end
if mp.isKey(pathStr)
    res=mp(pathStr);
else
    if nargin==0,
        pathStr=fileparts(mfilename('fullpath'));
    end
    res=~strcmp(modgen.scm.git.gitgethash(pathStr),'unversioned');
    mp(pathStr)=res;
end
end