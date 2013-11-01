function [isBadDirVec,pUniversalVec] = isbaddirection(fstEll, secEll, dirsMat,absTol)
%
% ISBADDIRECTION - checks if ellipsoidal approximations of geometric
%                  difference of two ellipsoids can be computed for
%                  given directions.
%   isBadDirVec = ISBADDIRECTION(fstEll, secEll, dirsMat) - Checks if
%       it is possible to build ellipsoidal approximation of the
%       geometric difference of two ellipsoids fstEll - secEll in
%       directions specified by matrix dirsMat (columns of dirsMat
%       are direction vectors). Type 'help minkdiff_ea' or
%       'help minkdiff_ia' for more information.
%
% Input:
%   regular:
%       fstEll: ellipsoid [1, 1] - first ellipsoid. Suppose nDim - space
%           dimension.
%       secEll: ellipsoid [1, 1] - second ellipsoid of the same dimention.
%       dirsMat: numeric[nDims, nCols] - matrix whose columns are
%           direction vectors that need to be checked.
%       absTol: double [1,1] - absolute tolerance
%
% Output:
%    isBadDirVec: logical[1, nCols] - array of true or false with length
%       being equal to the number of columns in matrix dirsMat.
%       ture marks direction vector as bad - ellipsoidal approximation
%       true marks direction vector as bad - ellipsoidal approximation
%       cannot be computed for this direction. false means the opposite.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import modgen.common.throwwarn;

if ~isbigger(fstEll, secEll)
    fstErrMsg = 'ISBADDIRECTION: geometric difference of these ';
    secErrMsg = 'two ellipsoids is empty set.\n';
    throwwarn('wrongInput:emptyGeomDiff', [fstErrMsg secErrMsg]);
    isBadDirVec = true(1,size(dirsMat,2));
else    
    [isBadDirVec,pUniversalVec] = ellipsoid.isbaddirectionmat(fstEll.shapeMat,...
        secEll.shapeMat, dirsMat,absTol);
end