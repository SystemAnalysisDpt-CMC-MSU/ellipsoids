function hashStr=gitgethash(pathStr)
import modgen.common.throwerror;
persistent mp
GIT_HASH_LENGTH=40;
GIT_HASH_CMD='log -1 HEAD --pretty=format:%H';
if isempty(mp)
    mp=containers.Map();
end
if mp.isKey(pathStr)
    hashStr=mp(pathStr);
else
    if nargin==0,
        pathStr=fileparts(mfilename('fullpath'));
    end
    [hashStr,StMsg]=modgen.scm.git.gitcall(GIT_HASH_CMD,pathStr);
    %
    if isempty(StMsg),
        hashStr=[hashStr{:}];
        hashStr=strtrim(hashStr);
        nHashSymb=numel(hashStr);
        if nHashSymb>GIT_HASH_LENGTH
            %on unix hash string can contain a garbage tail like in
            %dc6698d793bde0c84d3137dd0641d7a7bce1cdd1[m
            hashStr=hashStr(1:GIT_HASH_LENGTH);
        elseif nHashSymb>GIT_HASH_LENGTH
            throwerror('wrongState',...
                'hash string returned by %s command is too short',GIT_HASH_CMD);
        end        
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