function URL=svngeturl(WorkingCopy)

% default return value
URL=[];

% call subversion with the given parameter string to get a list of all
% properties
ParamStr=sprintf('info "%s"',WorkingCopy);
svnMsg=modgen.subversion.svncall(ParamStr);

URL_Idx=strmatch('URL:',svnMsg);
if isempty(URL_Idx)
    error('SVN:versioningProblem', '%s',...
        ['Problem using version control system - no URL found:' 10 ...
            ' ' [svnMsg{:}]])
end
URL=svnMsg{URL_Idx}(6:end);
