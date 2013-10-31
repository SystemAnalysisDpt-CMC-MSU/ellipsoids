function res=isgit(pathStr)
if nargin==0,
    pathStr=fileparts(mfilename('fullpath'));
end
res=~strcmp(modgen.git.gitgethash(pathStr),'unversioned');
end