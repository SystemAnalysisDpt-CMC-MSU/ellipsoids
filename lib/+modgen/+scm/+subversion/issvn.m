function isPos=issvn(pathStr)
if nargin==0,
    pathStr=fileparts(mfilename('fullpath'));
end
svnVersionStr=modgen.scm.subversion.getrevisionbypath(...
    pathStr,'ignoreErrors',true);
isPos=isempty(regexpi(svnVersionStr,'unversioned|exported'));