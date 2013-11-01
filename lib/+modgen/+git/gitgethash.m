function hashStr=gitgethash(pathStr)
if nargin==0,
    pathStr=fileparts(mfilename('fullpath'));
end
[hashStr,StMsg]=modgen.git.gitcall('log -1 HEAD --pretty=format:%H',...
    pathStr);
if isempty(StMsg),
    hashStr=hashStr{:};
else
    if strcmp(StMsg.identifier,'GIT:versioningProblem')&&...
            strncmp(hashStr,'fatal: Not a git repository',...
            numel('fatal: Not a git repository')),
        hashStr='unversioned';
    else
        error(StMsg);
    end
end