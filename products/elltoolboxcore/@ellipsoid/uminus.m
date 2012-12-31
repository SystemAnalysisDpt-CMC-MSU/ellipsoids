function outEllArr = uminus(ellArr)
%
% VOLUME - changes the sign of the center of ellipsoid.
%
% Input:
%	regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array
%           of ellipsoids.
%
% Output:
%	outEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of
%    	ellipsoids, same size as ellArr.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

ellipsoid.checkIsMe(ellArr);

sizeCVec = num2cell(size(ellArr));
outEllArr(sizeCVec{:}) = ellipsoid;
arrayfun(@(x) fSingleUminus(x), 1:numel(ellArr));
    function fSingleUminus(index)
        outEllArr(index).center = -ellArr(index).center;
        outEllArr(index).shape = ellArr(index).shape;
    end
end
