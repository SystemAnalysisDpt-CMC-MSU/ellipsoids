function [isSuccess,msgStr,messageId]=copyfile(srcName,dstName)
% COPYFILE is a simplified version of the built-in function that 
% supports long file paths on Windows (>260 symbols). Only copying of a
% single file to a destination folder/file is supported
%
% Input:
%   regular:
%       srcName: char[1,] - source file name
%       dstName: char[1,] - destination file/directory name
%
% Output:
%   isSuccess: logical[1,1] - if true, execution was successful
%   msgStr: char[1,] - string containing the warning or error message
%       if operation is unsuccessful, empty otherwise
%   messageId: char[1,] - string containing the warning or error message id
%       if operation is unsuccessful, empty otherwise
%
% Note: as opposed to the built-in copyfile function this function doesn't
%   support wildcards and copying multiple files
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-Jul-08 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
try
    modgen.io.FileUtils.copyFile(srcName,dstName);
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