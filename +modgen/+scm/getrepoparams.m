function [urlTypeMarkerStr,urlStr,branchName,revisionStr]=...
    getrepoparams(repoDir)
% GETREPOPARAMS returns generic parameters of SCM repository (currently
% only git and subversion repositories are supported
%
% Input:
%   optional:
%       repoDir: char[1,] - an arbitrary sub-folder within a repository
%           if not specified the path if determined automatically based on
%           location of the function
% Output:
%   urlType: char[1,] - repository URL marker (svnURL or gitURL)
%   urlStr: char[1,] - URL itself
%   branchName: char[1,] - current branch name
%   revisionStr: char[1,] - current revision
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 16-Jun-2015 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
import modgen.common.throwerror;
%
if nargin==0
    callerPath=mfilename('fullpath');
    if isempty(callerPath)%command line
        repoDir=cd();
    else
        repoDir=fileparts(callerPath);
    end
end
urlTypeMarkerStr='';
try
    isSvn=modgen.scm.subversion.issvn(repoDir);
    if isSvn,
        isGit=false;
        urlTypeMarkerStr='svnURL';
        urlStr=modgen.scm.subversion.svngeturl(repoDir);
    else
        isGit=modgen.scm.git.isgit(repoDir);
        if isGit,
            urlTypeMarkerStr='gitURL';
            urlStr=modgen.scm.git.gitgeturl(repoDir);
        else
            throwerror('wrongObjState',...
                'Files with code should be under either SVN or Git');
        end
    end
catch meObj
    rethrow(meObj);
    isSvn=false;
    isGit=false;
    urlTypeMarkerStr='unknownURL';
    urlStr='unknown';
end
if isSvn,
    revisionStr=modgen.scm.subversion.getrevision('ignoreErrors',true);
    branchName='unknown';
elseif isGit,
    revisionStr=modgen.scm.git.gitgethash(repoDir);
    branchName=modgen.scm.git.gitgetbranch(repoDir);
else
    revisionStr='unversioned';
    branchName='unknown';
end
end