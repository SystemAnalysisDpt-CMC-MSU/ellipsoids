function outEllArr=mtimes(multMat,inpEllArr)
%
% MTIMES - overloaded operator '*'.
%
%   Multiplication of the ellipsoid by a matrix or a scalar.
%   If inpEllVec(iEll) = E(q, Q) is an GenEllipsoid, and
%   multMat = A - matrix of suitable dimensions,
%   then A E(q, Q) = E(Aq, AQA').
%
% Input:
%   regular:
%       multMat: double[mRows, nDims]/[1, 1] - scalar or
%           matrix in R^{mRows x nDim}
%       inpEllVec: GenEllipsoid [1, nCols] - array of GenEllipsoids.
%
% Output:
%   outEllVec: GenEllipsoid [1, nCols] - resulting GenEllipsoids.
%
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
[isFstScal,outEllArr]=mtimesInternal(multMat,inpEllArr);
arrayfun(@(x) fSingleMtimes(x),outEllArr);
    function fSingleMtimes(ellObj)
        if isFstScal
            eigvMat=modMat*modMat*ellObj.eigvMat;
        else
            eigvMat=modMat*ellObj.eigvMat;
        end
        ellObj.centerVec=multMat*ellObj.getCenterVec();
        ellObj.eigvMat=eigvMat;
    end
end