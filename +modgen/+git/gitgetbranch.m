function hashStr=gitgetbranch(pathStr)
persistent mp
if isempty(mp)
    mp=containers.Map();
end
if mp.isKey(pathStr)
    hashStr=mp(pathStr);
else
    if nargin==0,
        pathStr=fileparts(mfilename('fullpath'));
    end
    [hashStr,StMsg]=modgen.git.gitcall('rev-parse --abbrev-ref HEAD',...
        pathStr);
    if isempty(StMsg),
        hashStr=[hashStr{:}];
    else
        if iscell(hashStr)&&isempty(hashStr),
            error(StMsg);
        elseif strcmp(StMsg.identifier,'GIT:versioningProblem')&&...
                strncmp(hashStr,'fatal: Not a git repository',...
                numel('fatal: Not a git repository')),
            hashStr='unversioned';
        else
            error(StMsg);
        end
    end
    mp(pathStr)=hashStr;
end