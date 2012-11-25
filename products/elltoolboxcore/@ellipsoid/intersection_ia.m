function outEllMat = intersection_ia(myEllMat, objMat)
%
% INTERSECTION_IA - internal ellipsoidal approximation of the intersection
%                   of of ellipsoid and ellipsoid, or ellipsoid and
%                   halfspace, or ellipsoid and polytope.
%
%   E = INTERSECTION_IA(E1, E2) Given two ellipsoidal arrays of equal
%       sizes, E1 and E2, or, alternatively, E1 or E2 must be
%       a single ellipsoid, comuptes the internal
%       ellipsoidal approximations of intersections of
%       two corresponding ellipsoids from E1 and from E2.
%   E = INTERSECTION_IA(E1, H) Given array of ellipsoids E1 and array of
%       hyperplanes H whose sizes match, computes
%       the internal ellipsoidal approximations of
%       intersections of ellipsoids and halfspaces
%       defined by hyperplanes in H.
%       If v is normal vector of hyperplane and c - shift,
%       then this hyperplane defines halfspace
%                  <v, x> <= c.
%   E = INTERSECTION_IA(E1, P) Given array of ellipsoids E1 and array of
%       polytopes P whose sizes match, computes
%       the internal ellipsoidal approximations of
%       intersections of ellipsoids E1 and polytopes P.
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
%       myEllMat: ellipsod [mRows, nCols] - matrix of ellipsoids.
%       objMat: ellipsoid [mRows, nCols] / hyperplane [mRows, nCols] /
%           / polytope [mRows, nCols]  - matrix of ellipsoids or
%           hyperplanes or polytopes of the same sizes.
%
% Output:
%    outEllMat: ellipsod [mRows, nCols] - matrix of internal approximating
%       ellipsoids; entries can be empty ellipsoids if the corresponding
%       intersection is empty.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;

if ~(isa(myEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'INTERSECTION_IA: first input argument must be ellipsoid.');
end
if ~(isa(objMat, 'ellipsoid')) && ~(isa(objMat, 'hyperplane')) ...
        && ~(isa(objMat, 'polytope'))
    fstErrMsg = 'INTERSECTION_IA: second input argument must be ';
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
        fstErrMsg = 'INTERSECTION_IA: ellipsoids and hyperplanes ';
        secErrMsg = 'must be of the same dimension.';
        throwerror('wrongSizes', [fstErrMsg secErrMsg]);
    elseif isa(objMat, 'polytope')
        fstErrMsg = 'INTERSECTION_IA: ellipsoids and polytopes ';
        secErrMsg = 'must be of the same dimension.';
        throwerror('wrongSizes', [fstErrMsg secErrMsg]);
    else
        throwerror('wrongSizes', ...
            'INTERSECTION_IA: ellipsoids must be of the same dimension.');
    end
end

nEllipsoids     = mEllRows * nEllCols;
nObjects     = mObjRows * nObjCols;
if (nEllipsoids > 1) && (nObjects > 1) && ((mEllRows ~= mObjRows) ...
        || (nEllCols ~= nObjCols))
    if isa(objMat, 'hyperplane')
        fstErrMsg = 'INTERSECTION_IA: sizes of ellipsoidal and';
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
                    l_polyintersect(myEllMat(iRow, jCol), objMat(jCol))];
            else
                ellPartVec = [ellPartVec ...
                    l_intersection_ia(myEllMat(iRow, jCol), ...
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
                    l_polyintersect(myEllMat(iRow, jCol), objMat)];
            else
                ellPartVec = [ellPartVec ...
                    l_intersection_ia(myEllMat(iRow, jCol), objMat)];
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
                    l_polyintersect(myEllMat(iRow, jCol), objMat(jCol))];
            else
                ellPartVec = [ellPartVec ...
                    l_intersection_ia(myEllMat, objMat(iRow, jCol))];
            end
        end
        outEllMat = [outEllMat; ellPartVec];
    end
end

end





%%%%%%%%

function outEll = l_intersection_ia(fstEll, secObj)
%
% L_INTERSECTION_IA - computes internal ellipsoidal approximation
%                     of intersection of single ellipsoid with single
%                     ellipsoid or halfspace.
%
% Input:
%   regular:
%       fsrEll: ellipsod [1, 1] - matrix of ellipsoids.
%       secObj: ellipsoid [1, 1] - ellipsoidal matrix
%               of the same size.
%           Or
%           hyperplane [1, 1] - matrix of hyperplanes
%               of the same size.
%
% Output:
%    outEll: ellipsod [1, 1] - internal approximating ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

if isa(secObj, 'ellipsoid')
    if fstEll == secObj
        outEll = fstEll;
    elseif ~intersect(fstEll, secObj)
        outEll = ellipsoid;
    else
        outEll = ellintersection_ia([fstEll secObj]);
    end
    return;
end

fstEllCentVec = fstEll.center;
fstEllShMat = fstEll.shape;
if rank(fstEllShMat) < size(fstEllShMat, 1)
    fstEllShMat = ell_inv(ellipsoid.regularize(fstEllShMat,...
        fstEll.absTol));
else
    fstEllShMat = ell_inv(fstEllShMat);
end

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

[intEllCentVec, intEllShMat] = parameters(hpintersection(fstEll, ...
    secObj));
[~, boundVec] = rho(fstEll, normHypVec);
hEig      = 2*sqrt(maxeig(fstEll));
secCentVec     = intEllCentVec + hEig*normHypVec;
secMat     = (normHypVec*normHypVec')/(hEig^2);
fstCoeff     = (fstEllCentVec - ...
    intEllCentVec)'*fstEllShMat*(fstEllCentVec - intEllCentVec);
secCoeff = (secCentVec - boundVec)'*secMat*(secCentVec - boundVec);
fstEllCoeff  = (1 - secCoeff)/(1 - fstCoeff*secCoeff);
secEllCoeff = (1 - fstCoeff)/(1 - fstCoeff*secCoeff);
intEllShMat      = fstEllCoeff*fstEllShMat + secEllCoeff*secMat;
intEllShMat      = 0.5*(intEllShMat + intEllShMat');
intEllCentVec      = ell_inv(intEllShMat)*...
    (fstEllCoeff*fstEllShMat*fstEllCentVec + ...
    secEllCoeff*secMat*secCentVec);
intEllShMat      = intEllShMat/(1 - ...
    (fstEllCoeff*fstEllCentVec'*fstEllShMat*fstEllCentVec + ...
    secEllCoeff*secCentVec'*secMat*secCentVec - ...
    intEllCentVec'*intEllShMat*intEllCentVec));
intEllShMat      = ell_inv(intEllShMat);
intEllShMat      = (1-fstEll.absTol)*0.5*(intEllShMat + intEllShMat');
outEll      = ellipsoid(intEllCentVec, intEllShMat);

end





%%%%%%%%

function outEll = l_polyintersect(myEll, polyt)
%
% L_POLYINTERSECT - computes internal ellipsoidal approximation of
%                   intersection of single ellipsoid with single polytope.
%
% Input:
%   regular:
%       myEllMat: ellipsod [1, 1] - matrix of ellipsoids.
%       polyt: polytope [1, 1] - polytope.
%
% Output:
%    outEll: ellipsod [1, 1] - internal approximating ellipsoid.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $


outEll = myEll;
hyp = polytope2hyperplane(polyt);
nDimsHyp  = size(hyp, 2);

for iDim = 1:nDimsHyp
    outEll = intersection_ia(outEll, hyp(iDim));
end

if isinside(myEll, polyt)
    outEll = getInnerEllipsoid(polyt);
    return;
end

end
