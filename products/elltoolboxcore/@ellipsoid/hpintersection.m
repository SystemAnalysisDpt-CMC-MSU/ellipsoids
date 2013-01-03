function [intEllArr, isnIntersectedArr] = ...
    hpintersection(myEllArr, myHypArr)
%
% HPINTERSECTION - computes the intersection of ellipsoid with hyperplane.
%
% Input:
%   regular:
%       myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - array
%           of ellipsoids.
%       myHypArr: hyperplane [nDims1,nDims2,...,nDimsN]/[1,1] - array
%           of hyperplanes of the same size.
%
% Output:
%   intEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%       resulting from intersections.
%
%   isnIntersectedArr: logical [nDims1,nDims2,...,nDimsN].
%       isnIntersectedArr(iCount) = true, if myEllArr(iCount)
%       doesn't intersect myHipArr(iCount),
%       isnIntersectedArr(iCount) = false, otherwise.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%

import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.common.checkmultvar;

ellipsoid.checkIsMe(myEllArr,'first');
modgen.common.checkvar(myHypArr,@(x) isa(x,'hyperplane'),...
    'errorTag','wrongInput',...
    'errorMessage','second argument must be hyperplane.');

isEllScal = isscalar(myEllArr);
isHypScal = isscalar(myHypArr);
nEllDimsArr = dimension(myEllArr);
maxEllDim   = max(nEllDimsArr(:));

checkmultvar('x1 || x2 ||all(size(x3)==size(x4))',...
    4,isEllScal,isHypScal,myEllArr,myHypArr,...
    'errorTag','wrongSizes','errorMessage',...
    'sizes of ellipsoidal and hyperplane arrays do not match.');
checkmultvar('all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
    2,nEllDimsArr,dimension(myHypArr),...
    'errorTag','wrongSizes','errorMessage',...
    'ellipsoids and hyperplanes must be of the same dimension.');

isSecondOutput = nargout==2;
if isHypScal
    nAmount = numel(myEllArr);
    sizeCVec = num2cell(size(myEllArr));
else
    nAmount = numel(myHypArr);
    sizeCVec = num2cell(size(myHypArr));
end
intEllArr(sizeCVec{:}) = ellipsoid;
isnIntersectedArr = false(sizeCVec{:});
indexVec = 1:nAmount;

if Properties.getIsVerbose()
    if ~(isEllScal&&isHypScal)
        fprintf('Computing %d ellipsoid-hyperplane intersections...\n',...
            nAmount);
    else
        fprintf('Computing ellipsoid-hyperplane intersection...\n');
    end
end

if ~(isEllScal || isHypScal)
    arrayfun(@(x,y) fSingleCase(x,y), indexVec,indexVec);
elseif isHypScal
    arrayfun(@(x) fSingleCase(x,1), indexVec);
else
    arrayfun(@(x) fSingleCase(1,x),indexVec);
end

    function fSingleCase(ellIndex, hypIndex)
        myEll = myEllArr(ellIndex);
        myHyp = myHypArr(hypIndex);
        index = max(ellIndex,hypIndex);
        if distance(myEll, myHyp) > 0
            if (~isSecondOutput)
                modgen.common.throwerror('degenerateEllipsoid',...
                    'Hypeplane doesn''t intersect ellipsoid');
            else
                intEllArr(index) = ellipsoid;
                isnIntersectedArr(index) = true;
            end
        else
            intEllArr(index) = l_compute1intersection(myEll,myHyp,...
                maxEllDim);
            isnIntersectedArr(index) = false;
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
intEllCentVec   = myEllCentVec + myEllCentVec(1, 1)*...
    [-1; invMyEllShMat*invShMatrixVec];
intEllShMat   = (1 - hCoefficient) * [0 zeros(1, maxEllDim-1); ...
    zeros(maxEllDim-1, 1) invMyEllShMat];
intEll   = ellipsoid(intEllCentVec, intEllShMat);
intEll   = ell_inv(tMat)*(intEll + rotVec);
end
