function [isSuccess,msgStr,messageId]=mkdir(dirName)
% MKDIR creates a directory recursively
%
% Input:
%   regular:
%       dirName: char[1,] directory name
%
% Output:
%   isSuccess: logical[1,1] - if true, execution was successful
%   msgStr: char[1,] - string containing the warning or error message 
%       if operation is unsuccessful, empty otherwise
%   messageId: char[1,] - string containing the warning or error message id
%       if operation is unsuccessful, empty otherwise
%
% Note: tha main difference from the built-in mkdir function is that this
%   function works with long file names on Windows
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-Jul-06 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
try
    modgen.io.FileUtils.createDirectoryRecursively(dirName);
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