function isBadDirVec = isbaddirection(minEll, subEll, dirsMat)
%
% ISBADDIRECTION - checks if ellipsoidal approximations of geometric
%                  difference of two ellipsoids can be computed for
%                  given directions.
%   RES = ISBADDIRECTION(minEll, subEll, dirsMat)  Checks if it is
%       possible to build ellipsoidal approximation of the geometric
%       difference of two ellipsoids minEll - subEll in directions
%       specified by matrix dirsMat (columns of dirsMat are
%       direction vectors). Type 'help minkdiff_ea' or
%       'help minkdiff_ia' for more information.
%
% Input:
%   regular:
%       minEll: ellipsod [1, 1] - first ellipsoid. Suppose nDim - space
%       dimension.
%       subEll: ellipsod [1, 1] - second ellipsoid of the same dimention.
%       dirsMat: numeric[nDims, nCols] - matrix whose columns are
%           direction vectors that need to be checked.
%
% Output:
%    isBadDirVec: logical[1, nCols] - array of true or false with length
%       being equal to the number of columns in matrix dirsMat.
%       ture marks direction vector as bad - ellipsoidal approximation
%       cannot be computed for this direction. false means the opposite.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Rustam Guliev <glvrst@gmail.com>> $  $Date: 10-11-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

import modgen.common.throwwarn;

if ~isbigger(minEll, subEll)
    fstErrMsg = 'ISBADDIRECTION: geometric difference of these ';
    secErrMsg = 'two ellipsoids is empty set.\n';
    throwwarn('wrongInput:emptyGeomDiff', [fstErrMsg secErrMsg]);
end

isBadDirVec=ellipsoid.isbaddirectionmat(minEll.shape,...
    subEll.shape, dirsMat);
