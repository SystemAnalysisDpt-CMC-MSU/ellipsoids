function rev=getrevisionbypath(ReferencePath,varargin)
import modgen.common.throwerror;
UNVERSIONED_MESSAGE='unversioned';
UNVERSIONED_FILE_SVN_MESSAGE='Unversioned file';
%
isErrorsIgnored=false;
[~,prop]=parseparams(varargin);
nProp=length(varargin);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'ignoreerrors',
            isErrorsIgnored=prop{k+1};
        otherwise
            error([upper(mfilename),':wrongInput'],...
                'unknown property %s',prop{k});
    end
end
try
    [svnErr,svnMsg]=system(['svnversion ' '"',ReferencePath,'"']);
    % create cellstring with one row per line
    svnMsg=strread(svnMsg,'%s','whitespace',char(10));
    % check for an error reported by the operating system
    if svnErr~=0
        throwerror('svnError',strrep([svnMsg{:}],'\','/'));
    else
        rev=svnMsg{end};
        if strcmp(rev,UNVERSIONED_FILE_SVN_MESSAGE)
            rev=UNVERSIONED_MESSAGE;
        end
    end
catch meObj
    if ~isErrorsIgnored
        rethrow(meObj);
    else
        rev=UNVERSIONED_MESSAGE;
    end
end