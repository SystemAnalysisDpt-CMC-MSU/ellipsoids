function [gitMsgLineList, varargout]=gitcall(ParamStr,pathStr)
isPath=nargin>1;

Msg=struct([]);
% call git with the given parameter string
if isPath,
    curDirStr=pwd();
    cd(pathStr);
end
gitDirStr=pwd();
callStr=sprintf('git %s',ParamStr);
if isunix
    callStr=['TERM=ansi ',callStr];
end
%
[gitErr,gitMsg]=system(callStr);
if isPath,
    cd(curDirStr);
end

% create cellstring with one row per line
gitMsgLineList=strsplit(gitMsg,sprintf('\r\n'));
%
% check for an error reported by the operating system
if gitErr~=0
    % an error is reported
    if isempty(gitMsgLineList),
        Msg(1).identifier='GIT:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            ' Git could not be executed! Error code is ' ...
            num2str(gitErr) 10 ' Path is ' gitDirStr];
    elseif strncmp('''git',gitMsgLineList{1},4),
        Msg(1).identifier='GIT:installationProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            ' Git could not be executed!' 10 'Path is ' gitDirStr];
    else
        Msg(1).identifier='GIT:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.string.cell2str(gitMsgLineList,' ') 10 ' Path is ' gitDirStr];
    end
elseif ~isempty(gitMsgLineList)
    if strncmp('git:',gitMsgLineList{1},4),
        Msg(1).identifier='GIT:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.string.cell2str(gitMsgLineList,' ') 10 ...
            ' Path is ' gitDirStr];
    end
end

if nargout>1
    varargout{1}=Msg;
else
    error(Msg);
end