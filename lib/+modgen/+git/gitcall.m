function [gitMsg, varargout]=gitcall(ParamStr,pathStr)
isPath=nargin>1;

Msg=struct([]);
% call git with the given parameter string
if isPath,
    curDirStr=pwd();
    cd(pathStr);
end
callStr=sprintf('git %s',ParamStr);
[gitErr,gitMsg]=system(callStr);
if isPath,
    cd(curDirStr);
end

% create cellstring with one row per line
gitMsg=strread(gitMsg,'%s','delimiter','\n','whitespace','');
% check for an error reported by the operating system
if gitErr~=0
    % an error is reported
    if strncmp('''git',gitMsg{1},4),
        Msg(1).identifier='GIT:installationProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            ' Git could not be executed!'];
    else
        Msg(1).identifier='GIT:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.string.cell2str(gitMsg,' ')];
    end
elseif ~isempty(gitMsg)
    if strncmp('git:',gitMsg{1},4),
        Msg(1).identifier='GIT:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.string.cell2str(gitMsg,' ')];
    end
end

if nargout>1
    varargout{1}=Msg;
else
    error(Msg);
end