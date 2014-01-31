function [svnMsg, varargout]=svncall(ParamStr)

% History: 2005-11-30 created
% 2005-12-12 callStr changed to make SVN return values
% independent from localization

Msg=struct([]);
% call subversion with the given parameter string
%callStr=sprintf('svn %s',ParamStr);
svnDirStr=pwd();
callStr=sprintf('set LC_MESSAGES=en_En&&svn %s',ParamStr);
[svnErr,svnMsg]=system(callStr);

% create cellstring with one row per line
svnMsg=strread(svnMsg,'%s','delimiter','\n','whitespace','');
% check for an error reported by the operating system
if svnErr~=0
    % an error is reported
    if isempty(svnMsg),
        Msg(1).identifier='SVN:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            ' Subversion could not be executed! Error code is ' ...
            num2str(svnErr) 10 ' Path is ' svnDirStr];
    elseif strncmp('''svn',svnMsg{1},4),
        Msg(1).identifier='SVN:installationProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            ' Subversion could not be executed!' 10 ...
            ' Path is ' svnDirStr];
    else
        Msg(1).identifier='SVN:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.string.cell2str(svnMsg,' ') 10 ...
            ' Path is ' svnDirStr];
    end
elseif ~isempty(svnMsg)
    if strncmp('svn:',svnMsg{1},4),
        Msg(1).identifier='SVN:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.string.cell2str(svnMsg,' ') 10 ...
            ' Path is ' svnDirStr];
    end
end

if nargout>1
    varargout{1}=Msg;
else
    error(Msg);
end