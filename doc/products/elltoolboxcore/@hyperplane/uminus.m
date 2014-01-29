function outHypArr = uminus(inpHypArr)
%
% UMINUS - switch signs of normal vector and the shift scalar
%          to the opposite.
%
% Input:
%   regular:
%       inpHypArr: hyperplane [nDims1, nDims2, ...] - array
%           of hyperplanes.
%
% Output:
%   outHypArr: hyperplane [nDims1, nDims2, ...] - array
%       of the same hyperplanes as in inpHypArr whose
%       normals and scalars are multiplied by -1.
%
% Example:
%   hypObj = -hyperplane([-1; 1], 1)
% 
%   hypObj =
%   size: [1 1]
% 
%   Element: [1 1]
%   Normal:
%        1
%       -1
% 
%   Shift:
%       -1
% 
%   Hyperplane in R^2.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Aushkap Nikolay <n.aushkap@gmail.com> $  
% $Date: 30-11-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics
%             and Computer Science,
%             System Analysis Department 2012 $

hyperplane.checkIsMe(inpHypArr);

sizeVec = size(inpHypArr);
nElems = numel(inpHypArr);
outHypArr(nElems)=hyperplane();
outHypArr = reshape(outHypArr, sizeVec);
indArr = reshape(1:nElems, sizeVec);
arrayfun(@(x) setProp(x), indArr);

    function setProp(iObj)
        outHypArr(iObj).normal = -inpHypArr(iObj).normal;
        outHypArr(iObj).shift = -inpHypArr(iObj).shift;
        outHypArr(iObj).absTol = inpHypArr(iObj).absTol;
    end

end