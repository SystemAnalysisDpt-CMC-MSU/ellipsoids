function invEllArr = inv(myEllArr)
%
% INV - inverts shape matrices of ellipsoids in the given 
%       array.
%
%   invEllArr = INV(myEllArr)  Inverts shape matrices of
%       ellipsoids in the array myEllMat. In case shape 
%       matrix is sigular, it is regularized before 
%       inversion.
%
% Input:
%   regular:
%       myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - 
%         array of ellipsoids.
%
% Output:
%    invEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array 
%       of ellipsoids with inverted shape matrices.
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

ellipsoid.checkIsMe(myEllArr);

sizeCVec = num2cell(size(myEllArr));
invEllArr(sizeCVec{:}) = ellipsoid;
arrayfun(@(x) fSingleInv(x),1:numel(myEllArr));

    function fSingleInv(index)
        
        singEll = myEllArr(index);
        if isdegenerate(singEll)
            regShMat = ellipsoid.regularize(singEll.shape,...
                getAbsTol(singEll));
        else
            regShMat = singEll.shape;
        end
        regShMat = ell_inv(regShMat);
        invEllArr(index) = ellipsoid(singEll.center ,...
            0.5*(regShMat + regShMat'));
    end
end