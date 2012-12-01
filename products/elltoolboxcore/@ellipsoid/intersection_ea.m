function outEllMat = intersection_ea(myEllMat, objMat)
%
% INTERSECTION_EA - external ellipsoidal approximation of the
%                   intersection of two ellipsoids, or ellipsoid and
%                   halfspace, or ellipsoid and polytope.
%
%   outEllMat = INTERSECTION_EA(myEllMat, objMat) Given two ellipsoidal
%       matrixes of equal sizes, myEllMat and objMat = ellMat, or,
%       alternatively, myEllMat or ellMat must be a single ellipsoid,
%       computes the ellipsoid that contains the intersection of two
%       corresponding ellipsoids from myEllMat and from ellMat.
%   outEllMat = INTERSECTION_EA(myEllMat, objMat) Given matrix of
%       ellipsoids myEllMat and matrix of hyperplanes objMat = hypMat
%       whose sizes match, computes the external ellipsoidal
%       approximations of intersections of ellipsoids
%       and halfspaces defined by hyperplanes in hypMat.
%       If v is normal vector of hyperplane and c - shift,
%       then this hyperplane defines halfspace
%               <v, x> <= c.
%   outEllMat = INTERSECTION_EA(myEllMat, objMat) Given matrix of
%       ellipsoids myEllMat and matrix of polytopes objMat = polyMat
%       whose sizes match, computes the external ellipsoidal
%       approximations of intersections of ellipsoids myEllMat and
%       polytopes polyMat.
%
%   The method used to compute the minimal volume overapproximating
%   ellipsoid is described in "Ellipsoidal Calculus Based on
%   Propagation and Fusion" by Lluis Ros, Assumpta Sabater and
%   Federico Thomas; IEEE Transactions on Systems, Man and Cybernetics,
%   Vol.32, No.4, pp.430-442, 2002. For more information, visit
%   http://www-iri.upc.es/people/ros/ellipsoids.html
%
% Input:
%   regular:
%       myEllMat: ellipsoid [mRows, nCols] - matrix of ellipsoids.
%       objMat: ellipsoid [mRows, nCols] / hyperplane [mRows, nCols] /
%           / polytope [mRows, nCols]  - matrix of ellipsoids or
%           hyperplanes or polytopes of the same sizes.
%
% Output:
%    outEllMat: ellipsoid [mRows, nCols] - matrix of external
%       approximating ellipsoids; entries can be empty ellipsoids
%       if the corresponding intersection is empty.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;

if ~(isa(myEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'INTERSECTION_EA: first input argument must be ellipsoid.');
end
if ~(isa(objMat, 'ellipsoid')) && ~(isa(objMat, 'hyperplane')) ...
        && ~(isa(objMat, 'polytope'))
    fstErrMsg = 'INTERSECTION_EA: second input argument must be ';
    secErrMsg = 'ellipsoid, hyperplane or polytope.';
    throwerror('wrongInput', [fstErrMsg secErrMsg]);
end

[mEllRows, nEllCols] = size(myEllMat);
[mObjRows, nObjCols] = size(objMat);
nDimsMat  = dimension(myEllMat);

if isa(objMat, 'polytope')
    nObjDimsMat = [];
    for iRow = 1:mObjRows
        nObjDimsPartVec = [];
        for jCol = 1:nObjCols
            nObjDimsPartVec = [nObjDimsPartVec dimension(objMat(jCol))];
        end
        nObjDimsMat = [nObjDimsMat; nObjDimsPartVec];
    end
else
    nObjDimsMat = dimension(objMat);
end

minDim   = min(min(nDimsMat));
minObjDim   = min(min(nObjDimsMat));
maxDim   = max(max(nDimsMat));
maxObjDim   = max(max(nObjDimsMat));

if (minDim ~= maxDim) || (minObjDim ~= maxObjDim) ...
        || (maxDim ~= maxObjDim)
    if isa(objMat, 'hyperplane')
        fstErrMsg = 'INTERSECTION_EA: ellipsoids and hyperplanes ';
        secErrMsg = 'must be of the same dimension.';
        throwerror('wrongSizes', [fstErrMsg secErrMsg]);
    elseif isa(objMat, 'polytope')
        fstErrMsg = 'INTERSECTION_EA: ellipsoids and polytopes ';
        secErrMsg = 'must be of the same dimension.';
        throwerror('wrongSizes', [fstErrMsg secErrMsg]);
    else
        throwerror('wrongSizes', ...
            'INTERSECTION_EA: ellipsoids must be of the same dimension.');
    end
end

nEllipsoids = mEllRows * nEllCols;
nObjects = mObjRows * nObjCols;
if (nEllipsoids > 1) && (nObjects > 1) && ((mEllRows ~= mObjRows) ...
        || (nEllCols ~= nObjCols))
    if isa(objMat, 'hyperplane')
        fstErrMsg = 'INTERSECTION_EA: sizes of ellipsoidal and';
        secErrMsg = ' hyperplane arrays do not match.';
        throwerror('wrongSizes', [fstErrMsg secErrMsg]);
    elseif isa(objMat, 'polytope')
        fstErrMsg = 'INTERSECTION_EA: sizes of ellipsoidal and';
        secErrMsg = ' polytope arrays do not match.';
        throwerror('wrongSizes', [fstErrMsg secErrMsg]);
    else
        throwerror('wrongSizes', ...
            'INTERSECTION_EA: sizes of ellipsoidal arrays do not match.');
    end
end

outEllMat = [];
if (nEllipsoids > 1) && (nObjects > 1)
    for iRow = 1:mEllRows
        ellPartVec = [];
        for jCol = 1:nEllCols
            if isa(objMat, 'polytope')
                ellPartVec = [ellPartVec ...
                    l_polyintersect(myEllMat, objMat(jCol))];
            else
                ellPartVec = [ellPartVec ...
                    l_intersection_ea(myEllMat(iRow, jCol), ...
                    objMat(iRow, jCol))];
            end
        end
        outEllMat = [outEllMat; ellPartVec];
    end
elseif nEllipsoids > 0
    for iRow = 1:mEllRows
        ellPartVec = [];
        for jCol = 1:nEllCols
            if isa(objMat, 'polytope')
                ellPartVec = [ellPartVec ...
                    l_polyintersect(myEllMat, objMat)];
            else
                ellPartVec = [ellPartVec ...
                    l_intersection_ea(myEllMat(iRow, jCol), objMat)];
            end
        end
        outEllMat = [outEllMat; ellPartVec];
    end
else
    for iRow = 1:mObjRows
        ellPartVec = [];
        for jCol = 1:nObjCols
            if isa(objMat, 'polytope')
                ellPartVec = [ellPartVec ...
                    l_polyintersect(myEllMat, objMat(jCol))];
            else
                ellPartVec = [ellPartVec ...
                    l_intersection_ea(myEllMat, objMat(iRow, jCol))];
            end
        end
        outEllMat = [outEllMat; ellPartVec];
    end
end

end





%%%%%%%%

function outEll = l_intersection_ea(fstEll, secObj)
%
% L_INTERSECTION_EA - computes external ellipsoidal approximation of 
%                     intersection of single ellipsoid with single
%                     ellipsoid or halfspace.
%
% Input:
%   regular:
%       fsrEll: ellipsod [1, 1] - matrix of ellipsoids.
%       secObj: ellipsoid [1, 1]/hyperplane [1, 1] - ellipsoidal
%           matrix or matrix of hyperplanes of the same sizes.
%
% Output:
%    outEll: ellipsod [1, 1] - external approximating ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

fstEllCentVec = fstEll.center;
fstEllShMat = fstEll.shape;
if rank(fstEllShMat) < size(fstEllShMat, 1)
    fstEllShMat = ...
        ell_inv(ellipsoid.regularize(fstEllShMat,fstEll.absTol));
else
    fstEllShMat = ell_inv(fstEllShMat);
end

if isa(secObj, 'hyperplane')
    [normHypVec, hypScalar] = parameters(-secObj);
    hypScalar      = hypScalar/sqrt(normHypVec'*normHypVec);
    normHypVec      = normHypVec/sqrt(normHypVec'*normHypVec);
    if (normHypVec'*fstEllCentVec > hypScalar) ...
            && ~(intersect(fstEll, secObj))
        outEll = fstEll;
        return;
    end
    if (normHypVec'*fstEllCentVec < hypScalar) ...
            && ~(intersect(fstEll, secObj))
        outEll = ellipsoid;
        return;
    end
    hEig  = 2*sqrt(maxeig(fstEll));
    qSecVec = hypScalar*normHypVec + hEig*normHypVec;
    seqQMat = (normHypVec*normHypVec')/(hEig^2);
    
    [qCenterVec, shQMat] = parameters(hpintersection(fstEll, secObj));
    qSecVec     = qCenterVec + hEig*normHypVec;
else
    if fstEll == secObj
        outEll = fstEll;
        return;
    end
    if ~intersect(fstEll, secObj)
        outEll = ellipsoid;
        return;
    end
    qSecVec = secObj.center;
    seqQMat = secObj.shape;
    if rank(seqQMat) < size(seqQMat, 1)
        seqQMat = ell_inv(ellipsoid.regularize(seqQMat,secObj.absTol));
    else
        seqQMat = ell_inv(seqQMat);
    end
end

lambda = l_get_lambda(fstEllCentVec, fstEllShMat, qSecVec, ...]
    seqQMat, isa(secObj, 'hyperplane'));
xMat = lambda*fstEllShMat + (1 - lambda)*seqQMat;
xMat = 0.5*(xMat + xMat');
invXMat = ell_inv(xMat);
invXMat = 0.5*(invXMat + invXMat');
const = 1 - lambda*(1 - lambda)*(qSecVec - ...
    fstEllCentVec)'*seqQMat*invXMat*fstEllShMat*(qSecVec - fstEllCentVec);
qCenterVec = invXMat*(lambda*fstEllShMat*fstEllCentVec + ...
    (1 - lambda)*seqQMat*qSecVec);
shQMat = (1+fstEll.absTol)*const*invXMat;
outEll = ellipsoid(qCenterVec, shQMat);

end





%%%%%%%%

function lambda = l_get_lambda(fstEllCentVec, fstEllShMat, qSecVec, ...
    secQMat, isFlag)
%
% L_GET_LAMBDA - find parameter value for minimal volume ellipsoid.
%
% Input:
%   regular:
%       fstEllCentVec, qSecVec: double[nDims, 1]
%       fstEllShMat, secQMat: double[nDims, nDims]
%       isFlag: logical[1, 1]
%
% Output:
%    lambda: double[1, 1] - parameter value for minimal volume ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

[lambda, fVal] = fzero(@ell_fusionlambda, 0.5, [], ...
    fstEllCentVec, fstEllShMat, qSecVec, secQMat, size(fstEllCentVec, 1));

if (lambda < 0) || (lambda > 1)
    if isFlag || (det(fstEllShMat) > det(secQMat))
        lambda = 1;
    else
        lambda = 0;
    end
end

end





%%%%%%%%

function outEll = l_polyintersect(myEll, polyt)
%
% L_POLYINTERSECT - computes external ellipsoidal approximation of 
%                   intersection of single ellipsoid with single polytope.
%
% Input:
%   regular:
%       myEllMat: ellipsod [1, 1] - matrix of ellipsoids.
%       polyt: polytope [1, 1] - polytope.
%
% Output:
%    outEll: ellipsod [1, 1] - external approximating ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

outEll = myEll;
hyp = polytope2hyperplane(polyt);
nDimsHyp  = size(hyp, 2);

if isinside(myEll, polyt)
    outEll = getOutterEllipsoid(polyt);
    return;
end

for iElem = 1:nDimsHyp
    outEll = intersection_ea(outEll, hyp(iElem));
end

end
