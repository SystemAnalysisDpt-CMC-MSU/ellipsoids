function fileNameList=listdirsrecursive(dirName,patternStr,maxDepth)
% LISTDIRSRECURSIVE returns a list of directories with names matching
% a specified pattern in all the subdirectories of a directory
% up to the specified depth
%
% Input:
%   regular:
%       dirName: char[1,] - directory name to scan
%
%       patternStr: char[1,] - either Glob expression with "glob:" prefix
%           ("glob:**.m" for instance) or Regex expression with "regex:"
%           prefix.
%             -------Glob syntax description--------
%             *.txt	Matches all files that has extension as txt.
%             *.{html,htm}	Matches all files that has extension as
%               html or htm. { } are used to group patterns and ,
%               comma is used to separate patterns.
%             ?.txt	Matches all files that has any single charcter as
%               name and extension as txt.
%             *.*	Matches all files that has . in its name.
%             C:\\Users\\*	Matches any files in C: "Users" directory
%               in Windows file system. Backslash is used to escape a
%             special character.
%             /home/**	Matches /home/foo and /home/foo/bar on UNIX
%               platforms. ** matches strings of characters corssing
%               directory boundaries.
%             [xyz].txt	Matches a file name with single character "x"
%               or "y" or "z" and extension as txt. Square brackets [ ]
%               are used to sepcify a character set.
%             [a-c].txt	Matches a file name with single character "a" or
%               "b" or "c" and extension as txt. Hypehen ÿ is used to
%               specify a range and used in [ ]
%             [!a].txt	Matches a file name with single character that
%               is not "a". ! is used for negation.
%
%       maxDepth: double[1,1] - maximum depth, use Inf means for no depth
%           liminations
% Output:
%   dirNameList: cell[nFiles,1] of char[1,] - resuling list of directories
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
modgen.common.checkvar(maxDepth,'fix(x)==x&&x>=0');
if maxDepth==Inf
    maxDepth=-1;
else
    maxDepth=maxDepth+1;
end
%
fileNameList=cell(modgen.io.FileUtils.listDirsRecursive(dirName,...
    patternStr,maxDepth));