function inpEllArr = move2origin(inpEllArr)
%
% MOVE2ORIGIN - moves ellipsoids in the given array to the origin. Modified 
%               given array is on output (not its copy).
%
%   outEllArr = MOVE2ORIGIN(inpEll) - Replaces the centers of
%       ellipsoids in inpEllArr with zero vectors.
%
% Input:
%   regular:
%       inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of 
%           ellipsoids.
%
% Output:
%   inpEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%       with the same shapes as in inpEllArr centered at the origin.
%
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   outEllObj = ellObj.move2origin()
% 
%   outEllObj =
% 
%   Center:
%        0
%        0
% 
%   Shape:
%        4    -1
%       -1     1
% 
%   Nondegenerate ellipsoid in R^2.
%
%       
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

ellipsoid.checkIsMe(inpEllArr,...
    'errorTag','wrongInput',...
    'errorMessage','argument must be array of ellipsoid.');
arrayfun(@(x) fSingleMove(x), inpEllArr);
    function fSingleMove(ellObj)
        nDim = dimension(ellObj);
        ellObj.centerVec = zeros(nDim,1);
    end
end