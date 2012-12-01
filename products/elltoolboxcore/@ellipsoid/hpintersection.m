function [intEllMat, isnIntersectedMat] = ...
    hpintersection(myEllMat, myHypMat)
%
% HPINTERSECTION - computes the intersection of ellipsoid with hyperplane.
%
% Input:
%   regular:
%       myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%       myHypMat: hyperplane [mRows, nCols] - matrix of hyperplanes
%           of the same size.
%
% Output:
%   intEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids
%       resulting from intersections.
%
%   isnIntersectedMat: logical[mRows, nCols].
%       isnIntersectedMat(i, j) = true, if myEllMat(i, j) 
%       doesn't intersect myHipMat(i, j),
%       isnIntersectedMat(i, j) = false, otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;
import modgen.common.throwerror;

if ~(isa(myEllMat, 'ellipsoid')) || ~(isa(myHypMat, 'hyperplane'))
    fstErrMsg = 'HPINTERSECTION: first argument must be ellipsoid';
    secErrMsg = 'second argument - hyperplane.';
    throwerror('wrongInput', [fstErrMsg ', ' secErrMsg]);
end
if ndims(myEllMat) ~= 2
    throwerror('wrongInput:wrongDim','The dimension of input must be 2');
end;
if ndims(myHypMat) ~= 2
    throwerror('wrongInput:wrongDim','The dimension of input must be 2');
end;

[mEllRows, nEllCols] = size(myEllMat);
[mHipRows, nHipCols] = size(myHypMat);
nEllipsoids     = mEllRows * nEllCols;
nHiperplanes     = mHipRows * nHipCols;
if (nEllipsoids > 1) && (nHiperplanes > 1) && ...
        ((mEllRows ~= mHipRows) || (nEllCols ~= nHipCols))
    fstErrMsg = 'HPINTERSECTION: ';
    secErrMsg = 'sizes of ellipsoidal and hyperplane arrays do not match.';
    throwerror('wrongSizes', [fstErrMsg secErrMsg]);
end

isSecondOutput = nargout==2;

if (isSecondOutput)
    isnIntersectedMat = false(mEllRows, nEllCols);
end;

nEllDimsMat = dimension(myEllMat);
nHipDimsMat = dimension(myHypMat);
minEllDim   = min(min(nEllDimsMat));
minHipDim   = min(min(nHipDimsMat));
maxEllDim   = max(max(nEllDimsMat));
maxHipDim   = max(max(nHipDimsMat));
if (minEllDim ~= maxEllDim)
    throwerror('wrongSizes', ...
        'HPINTERSECTION: ellipsoids must be of the same dimension.');
end
if (minHipDim ~= maxHipDim)
    throwerror('wrongSizes', ...
        'HPINTERSECTION: hyperplanes must be of the same dimension.');
end

if Properties.getIsVerbose()
    if (nEllipsoids > 1) || (nHiperplanes > 1)
        fprintf('Computing %d ellipsoid-hyperplane intersections...\n',...
            max([nEllipsoids nHiperplanes]));
    else
        fprintf('Computing ellipsoid-hyperplane intersection...\n');
    end
end

intEllMat = [];
if (nEllipsoids > 1) && (nHiperplanes > 1)
    for iRow = 1:mEllRows
        intEllVec = [];
        for jCol = 1:nEllCols
            if distance(myEllMat(iRow, jCol), myHypMat(iRow, jCol)) > 0
                intEllVec = [intEllVec ellipsoid];
                if (~isSecondOutput)
                    throwerror('degenerateEllipsoid',...
                        'Hypeplane doesn''t intersect ellipsoid');
                else
                    isnIntersectedMat(iRow, jCol) = true;
                end;
            else
                intEllVec = [intEllVec ...
                    l_compute1intersection(myEllMat(iRow, jCol), ...
                    myHypMat(iRow, jCol), maxEllDim)];
            end
        end
        intEllMat = [intEllMat; intEllVec];
    end
elseif (nEllipsoids > 1)
    for iRow = 1:mEllRows
        intEllVec = [];
        for jCol = 1:nEllCols
            if distance(myEllMat(iRow, jCol), myHypMat) > 0
                intEllVec = [intEllVec ellipsoid];
            else
                intEllVec = [intEllVec ...
                    l_compute1intersection(myEllMat(iRow, jCol), ...
                    myHypMat, maxEllDim)];
            end
        end
        intEllMat = [intEllMat; intEllVec];
    end
else
    for iRow = 1:mHipRows
        intEllVec = [];
        for jCol = 1:nHipCols
            if distance(myEllMat, myHypMat(iRow, jCol)) > 0
                intEllVec = [intEllVec ellipsoid];
                if (~isSecondOutput)
                    throwerror('degenerateEllipsoid',...
                        'Hypeplane doesn''t intersect ellipsoid');
                else
                    isnIntersectedMat(iRow, jCol) = true;
                end;
            else
                intEllVec = [intEllVec ...
                    l_compute1intersection(myEllMat, ...
                    myHypMat(iRow, jCol), maxEllDim)];
            end
        end
        intEllMat = [intEllMat; intEllVec];
    end
end

end





%%%%%%%%

function intEll = l_compute1intersection(myEll, myHyp, maxEllDim)
%
% L_COMPUTE1INTERSECTION - computes intersection of single ellipsoid with
%                          single hyperplane.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1] - ellipsoid.
%       myHyp: hyperplane [1, 1] - hyperplane.
%       maxEllDim: double [1, 1] - maximum dimension of ellipsoids.
%
% Output:
%   intEll: ellipsoid [1, 1] - ellipsoid resulting from intersections.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import elltool.conf.Properties;

[normHypVec, hypScalar] = parameters(myHyp);
if hypScalar < 0
    normHypVec = - normHypVec;
    hypScalar = - hypScalar;
end
tMat = ell_valign([1; zeros(maxEllDim-1, 1)], normHypVec);
rotVec = (hypScalar*tMat*normHypVec)/(normHypVec'*normHypVec);
myEll = tMat*myEll - rotVec;
myEllCentVec = myEll.center;
myEllShMat = myEll.shape;

if rank(myEllShMat) < maxEllDim
    if Properties.getIsVerbose()
        fprintf('HPINTERSECTION: Warning! Degenerate ellipsoid.\n');
        fprintf('                Regularizing...\n');
    end
    myEllShMat = ellipsoid.regularize(myEllShMat,myEll.absTol);
end

invMyEllShMat   = ell_inv(myEllShMat);
invMyEllShMat   = 0.5*(invMyEllShMat + invMyEllShMat');
invShMatrixVec   = invMyEllShMat(2:maxEllDim, 1);
invShMatrixElem = invMyEllShMat(1, 1);
invMyEllShMat   = ell_inv(invMyEllShMat(2:maxEllDim, 2:maxEllDim));
invMyEllShMat   = 0.5*(invMyEllShMat + invMyEllShMat');
hCoefficient   = (myEllCentVec(1, 1))^2 * (invShMatrixElem - ...
    invShMatrixVec'*invMyEllShMat*invShMatrixVec);
intEllcentVec   = myEllCentVec + myEllCentVec(1, 1)*...
    [-1; invMyEllShMat*invShMatrixVec];
intEllShMat   = (1 - hCoefficient) * [0 zeros(1, maxEllDim-1); ...
    zeros(maxEllDim-1, 1) invMyEllShMat];
intEll   = ellipsoid(intEllcentVec, intEllShMat);
intEll   = ell_inv(tMat)*(intEll + rotVec);
end
