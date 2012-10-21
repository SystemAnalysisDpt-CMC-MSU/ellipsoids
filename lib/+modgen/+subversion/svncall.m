function [svnMsg, varargout]=svncall(ParamStr)

% History: 2005-11-30 created
% 2005-12-12 callStr changed to make SVN return values
% independent from localization

Msg=struct([]);
% call subversion with the given parameter string
%callStr=sprintf('svn %s',ParamStr);
callStr=sprintf('set LC_MESSAGES=en_En&&svn %s',ParamStr);
[svnErr,svnMsg]=system(callStr);

% create cellstring with one row per line
svnMsg=strread(svnMsg,'%s','delimiter','\n','whitespace','');
% check for an error reported by the operating system
if svnErr~=0
    % an error is reported
    if strmatch('''svn',svnMsg{1})==1
        Msg(1).identifier='SVN:installationProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            ' Subversion could not be executed!'];
    else
        Msg(1).identifier='SVN:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.subversion.cell2str(svnMsg,' ')];
    end
elseif ~isempty(svnMsg)
    if strmatch('svn:',svnMsg{1})==1
        Msg(1).identifier='SVN:versioningProblem';
        Msg(1).message=['Problem using version control system:' 10 ...
            modgen.subversion.cell2str(svnMsg,' ')];
    end
end

if nargout>1
    varargout{1}=Msg;
else
    error(Msg);
end