function [isSuccess,msgStr,messageId]=rmdir(dirName,sFlag)
% RMDIR removes a directory (optionally recursively)
%
% Input:
%   regular:
%       dirName: char[1,] directory name
%   optional:
%       sFlag: char[1,1] - can only take 's' value, if sFlag is specified
%           the directory is removed with all subfolders and files. If the
%           flag is not specified the function expects an empty directory
%
% Output:
%   isSuccess: logical[1,1] - if true, execution was successful
%   msgStr: char[1,] - string containing the warning or error message
%       if operation is unsuccessful, empty otherwise
%   messageId: char[1,] - string containing the warning or error message id
%       if operation is unsuccessful, empty otherwise
%
% Note: tha main difference from the built-in rmdir function is that this
%   function works with long file names on Windows
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-06-15 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
try
    if nargin<=1
        modgen.io.FileUtils.removeDirectory(dirName);
    else
        modgen.common.checkvar(sFlag,@(x)ischar(x)&&strcmp(x,'s'));
        modgen.io.FileUtils.removeDirectoryRecursively(dirName);
    end
    isSuccess=true;
    msgStr='';
    messageId='';    
    %
catch meObj
    if nargout==0
        rethrow(meObj)
    else
        isSuccess=false;
        msgStr=meObj.message;
        messageId=meObj.identifier;
    end
end