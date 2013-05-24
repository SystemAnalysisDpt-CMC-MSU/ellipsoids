function outEllArr = move2origin(inpEllArr)
%
% MOVE2ORIGIN - moves ellipsoids in the given array to the origin.
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
%   outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
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
sizeCVec = num2cell(size(inpEllArr));
outEllArr(sizeCVec{:}) = ellipsoid;
arrayfun(@(x) fSingleMove(x), 1:numel(inpEllArr));
    function fSingleMove(index)
        nDim = dimension(inpEllArr(index));
        outEllArr(index).centerVec = zeros(nDim,1);
        outEllArr(index).shapeMat = inpEllArr(index).shapeMat;
    end
end