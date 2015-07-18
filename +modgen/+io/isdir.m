function isPositive=isdir(dirName)
% ISDIR returns true if a specified name corresponds to an existing
% directory
%
% Input:
%   regular:
%       dirName: char[1,] - directory name to check
% Output:
%   isPositive: logical[1,1] - true if the directory exists
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-Jul-08 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
isPositive=modgen.io.FileUtils.isDirectory(dirName);