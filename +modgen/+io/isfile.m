function isPositive=isfile(fileName)
% ISFILE returns true if a specified name corresponds to an existing file
%
% Input:
%   regular:
%       fileName: char[1,] - file name to check
% Output:
%   isPositive: logical[1,1] - true if the file exists
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-Jul-08 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
isPositive=modgen.io.FileUtils.isFile(fileName);