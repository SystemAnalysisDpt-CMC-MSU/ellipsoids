function outEllArr=mtimes(multMat,inpEllArr)
%
% MTIMES - overloaded operator '*'.
%
%   Multiplication of the AEllipsoid by a matrix or a scalar.
%
% Input:
%   regular:
%       multMat: double[mRows, nDims]/[1, 1] - scalar or
%           matrix in R^{mRows x nDim}
%       inpEllVec: AEllipsoid [1, nCols] - array of AEllipsoids.
%
% Output:
%   outEllVec: AEllipsoid [1, nCols] - resulting AEllipsoids.
%
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   tempMat = [0 1; -1 0];
%   outEllObj = tempMat*ellObj
%
%   outEllObj =
%
%   Center:
%       -1
%        2
%
%   Shape:
%        1     1
%        1     4
%
%   Nondegenerate ellipsoid in R^2.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California
% 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $
% $Date: Dec-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
% $Author: Alexandr Timchenko <timchenko.alexandr@gmail.com> $   
% $Date: Dec-2015$
% $Copyright: Moscow State University,
%			Faculty of Computational Mathematics and Computer Science,
%			System Analysis Department 2015 $
%
import modgen.common.checkvar
checkIsMeVirtual(inpEllArr);
checkvar(multMat,@(x)isa(x,'double'),...
    'errorTag','wrongInput','errorMessage',...
    'first input argument must be matrix or scalar.');
checkvar(inpEllArr,'~any(isempty(x(:)))',...
    'errorTag','wrongInput','errorMessage',...
    'array of ellipsoids contains empty ellipsoid');
isFstScal=isscalar(multMat);
nDims=size(multMat,2);
nDimsVec=dimension(inpEllArr);
modgen.common.checkmultvar...
    ('all(x2(:)==x2(1))&&(x1||(~x1)&&(x2(1)==x3))',3,isFstScal,...
    nDimsVec,nDims,'errorTag','wrongSizes','errorMessage',...
    'dimensions not match.');
outEllArr=inpEllArr.getCopy();
arrayfun(@(x) fSingleMtimes(x),outEllArr);
    function fSingleMtimes(ellObj)
        ellObj.changeShapeMatInternal(isFstScal,multMat);
        ellObj.centerVec=multMat*ellObj.getCenterVec();
    end
end