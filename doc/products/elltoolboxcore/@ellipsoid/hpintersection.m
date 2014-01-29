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
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   hypMat = [hyperplane([0 -1; -1 0]', 1); hyperplane([0 -2; -1 0]', 1)];
%   ellMat = ellObj.hpintersection(hypMat)
% 
%   ellMat =
%   2x2 array of ellipsoids.
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

import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;
  
persistent logger;

ellipsoid.checkIsMe(myEllArr,'first');
modgen.common.checkvar(myHypArr,@(x) isa(x,'hyperplane'),...
    'errorTag','wrongInput',...
    'errorMessage','second argument must be hyperplane.');

isEllScal = isscalar(myEllArr);
isHypScal = isscalar(myHypArr);
nEllDimsArr = dimension(myEllArr);
maxEllDim   = max(nEllDimsArr(:));

modgen.common.checkvar( myEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( myEllArr,'all(~x(:).isEmpty())','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

modgen.common.checkvar( myHypArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( myHypArr,'all(~isEmpty(x(:)))','errorTag', ...
    'wrongInput:emptyHyperplane', 'errorMessage', ...
    'Array should not have empty hyperplane.');

checkmultvar('x1 || x2 ||all(size(x3)==size(x4))',...
    4,isEllScal,isHypScal,myEllArr,myHypArr,...
    'errorTag','wrongSizes','errorMessage',...
    'sizes of ellipsoidal and hyperplane arrays do not match.');

checkmultvar('all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
    2,nEllDimsArr,dimension(myHypArr),...
    'errorTag','wrongSizes','errorMessage',...
    'ellipsoids and hyperplanes must be of the same dimension.');


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
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if ~(isEllScal&&isHypScal)
        logger.info(sprintf('Computing %d ellipsoid-hyperplane intersections...',...
            nAmount));
    else
        logger.info('Computing ellipsoid-hyperplane intersection...');
    end
end
[~,absTol]=myEllArr.getAbsTol();
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
        if distance(myEll, myHyp) > absTol
           intEllArr(index) = ellipsoid;
           isnIntersectedArr(index) = true;
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
import elltool.logging.Log4jConfigurator;
  
persistent logger;

[normHypVec, hypScalar] = parameters(myHyp);
if hypScalar < 0
    normHypVec = - normHypVec;
    hypScalar = - hypScalar;
end
tMat = ell_valign([1; zeros(maxEllDim-1, 1)], normHypVec);
rotVec = (hypScalar*tMat*normHypVec)/(normHypVec'*normHypVec);
myEll = tMat*myEll - rotVec;
myEllCentVec = myEll.centerVec;
myEllShMat = myEll.shapeMat;

if rank(myEllShMat) < maxEllDim
    if Properties.getIsVerbose()
            if isempty(logger)
                logger=Log4jConfigurator.getLogger();
            end
        logger.info('HPINTERSECTION: Warning! Degenerate ellipsoid.');
        logger.info('                Regularizing...');
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
