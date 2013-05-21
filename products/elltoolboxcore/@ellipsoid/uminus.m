function outEllArr = uminus(ellArr)
%
% UMINUS - changes the sign of the centerVec of ellipsoid.
%
% Input:
%	regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%           
%
% Output:
%	outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids, 
%    	same size as ellArr.
%
% Example:
%   ellObj = -ellipsoid([-2; -1], [4 -1; -1 1])
% 
%   ellObj =
% 
%   Center:
%        2
%        1
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

ellipsoid.checkIsMe(ellArr);
sizeCVec = num2cell(size(ellArr));
if isempty(ellArr)
    outEllArr = ellipsoid.empty(sizeCVec{:});
else    
    outEllArr(sizeCVec{:}) = ellipsoid;
    arrayfun(@(x) fSingleUminus(x), 1:numel(ellArr));   
end
    function fSingleUminus(index)
        outEllArr(index).centerVec = -ellArr(index).centerVec;
        outEllArr(index).shapeMat = ellArr(index).shapeMat;
    end
end
