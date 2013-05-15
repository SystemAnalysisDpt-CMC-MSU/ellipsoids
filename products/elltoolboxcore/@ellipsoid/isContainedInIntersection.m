function [res, status] = isContainedInIntersection(fstEllArr, secObjArr,...
                            mode,computeMode)
%
% ISCONTAINEDININTERSECTION - checks if the intersection of
%                             ellipsoids contains the union
%                             or intersection of given 
%                             ellipsoids or polytopes.
%
%   res = ISCONTAINEDININTERSECTION(fstEllArr, secEllArr, mode) 
%       Checks if the union
%       (mode = 'u') or intersection (mode = 'i') of ellipsoids in
%       secEllArr lies inside the intersection of ellipsoids in
%       fstEllArr. Ellipsoids in fstEllArr and secEllArr must be
%       of the same dimension. mode = 'u' (default) - union of
%       ellipsoids in secEllArr. mode = 'i' - intersection.
%   res = ISCONTAINEDININTERSECTION(fstEllArr, secPolyArr, mode) 
%        Checks if the union
%       (mode = 'u') or intersection (mode = 'i')  of polytopes in
%       secPolyArr lies inside the intersection of ellipsoids in
%       fstEllArr. Ellipsoids in fstEllArr and polytopes in secPolyArr
%       must be of the same dimension. mode = 'u' (default) - union of
%       polytopes in secPolyMat. mode = 'i' - intersection.
%
%   To check if the union of ellipsoids secEllArr belongs to the
%   intersection of ellipsoids fstEllArr, it is enough to check that
%   every ellipsoid of secEllMat is contained in every
%   ellipsoid of fstEllArr.
%   Checking if the intersection of ellipsoids in secEllMat is inside
%   intersection fstEllMat can be formulated as quadratically
%   constrained quadratic programming (QCQP) problem.
%
%   Let fstEllArr(iEll) = E(q, Q) be an ellipsoid with center q and shape
%   matrix Q. To check if this ellipsoid contains the intersection of
%   ellipsoids in secObjArr:
%   E(q1, Q1), E(q2, Q2), ..., E(qn, Qn), we define the QCQP problem:
%                     J(x) = <(x - q), Q^(-1)(x - q)> --> max
%   with constraints:
%                     <(x - q1), Q1^(-1)(x - q1)> <= 1   (1)
%                     <(x - q2), Q2^(-1)(x - q2)> <= 1   (2)
%                     ................................
%                     <(x - qn), Qn^(-1)(x - qn)> <= 1   (n)
%
%   If this problem is feasible, i.e. inequalities (1)-(n) do not
%   contradict, or, in other words, intersection of ellipsoids
%   E(q1, Q1), E(q2, Q2), ..., E(qn, Qn) is nonempty, then we can find
%   vector y such that it satisfies inequalities (1)-(n)
%   and maximizes function J. If J(y) <= 1, then ellipsoid E(q, Q)
%   contains the given intersection, otherwise, it does not.
%
%   The intersection of polytopes is a polytope, which is computed
%   by the standard routine of MPT. To ensure, if polytope bolngs to 
%   intersection of ellipsoids we can either check if the vertices of this 
%   polytope belong to every ellipsoid in the intersection, or, if polytope
%   and ellipsoid are not degenerate, check, find intenal point of intP
%   intersectionthen of ellipsoid with the polytope(if it does not exist,
%   then polytope does not belong to intersection), change coordinates
%   newX = oldX - intP
%   and then check if polar of ellipsoids in new coordinates belogs to
%   polar of polytope.
%
%   Checking if the union of polytopes belongs to the intersection
%   of ellipsoids is the same as checking if its convex hull belongs
%   to this intersection.
%
% Input:
%   regular:
%       fstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%           of the same size.
%       secEllArr: ellipsoid /
%           polytope [nDims1,nDims2,...,nDimsN] - array of ellipsoids or
%           polytopes of the same sizes.
%
%           note: if mode == 'i', then fstEllArr, secEllVec should be
%               array.
%
%   optional:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%       computeMode: char[1,] - 'extreme' or 'polar'. determines, which way
%                       function is computed, when secObjArr is polytope.
%                       If secObjArr is ellipsoid computeMode is ignored
%                       'polar' works faster for not a big amount of 
%                       ellipsoid in fstEllArr and big dimensions. In case
%                       of low dimensions consider 'extreme'. 'extreme' is
%                       default.
%                       
%
% Output:
%   res: double[1, 1] - result:
%       -1 - problem is infeasible, for example, if s = 'i',
%           but the intersection of ellipsoids in E2 is an empty set;
%       0 - intersection is empty;
%       1 - if intersection is nonempty.
%   status: double[0, 0]/double[1, 1] - status variable. status is empty
%       if mode == 'u' or mSecRows == nSecCols == 1.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Vadim Kaushanskiy <vkaushanskiy@gmail.com>$ $Date: 10-11-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
import modgen.common.throwerror;
import modgen.common.checkmultvar;

persistent logger;

ellipsoid.checkIsMe(fstEllArr,'first');
modgen.common.checkvar(secObjArr,@(x) isa(x, 'ellipsoid') ||...
    isa(x, 'hyperplane') || isa(x, 'polytope'),...
    'errorTag','wrongInput', 'errorMessage',...
    'second input argument must be ellipsoid,hyperplane or polytope.');

modgen.common.checkvar( fstEllArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');

modgen.common.checkvar( fstEllArr,'all(~isempty(x(:)))','errorTag', ...
    'wrongInput:emptyEllipsoid', 'errorMessage', ...
    'Array should not have empty ellipsoid.');

modgen.common.checkvar( secObjArr , 'numel(x) > 0', 'errorTag', ...
    'wrongInput:emptyArray', 'errorMessage', ...
    'Each array must be not empty.');
status = [];

nElem = numel(secObjArr);
secObjVec  = reshape(secObjArr, 1, nElem);

nFstEllDimsMat = dimension(fstEllArr);
nSecEllDimsMat = dimension(secObjVec);
checkmultvar('(x1(1)==x2(1))&&all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
    2,nFstEllDimsMat,nSecEllDimsMat,...
    'errorTag','wrongSizes',...
    'errorMessage','input arguments must be of the same dimension.');


if isa(secObjArr, 'polytope')
    isEmptyArr = true(size(secObjArr));
    [~, nCols] = size(secObjArr);
    for iCols = 1:nCols
        isEmptyArr(iCols) = isempty(secObjArr(iCols));
    end
    isAnyObjEmpty = any(isEmptyArr);
else
    isAnyObjEmpty = any(isempty(secObjArr(:)));
end
if isAnyObjEmpty
    throwerror('wrongInput:emptyObject',...
    'Array should not have empty ellipsoid, hyperplane or polytope.');
end

if (nargin < 3) || ~(ischar(mode))
    mode = 'u';
end
if (nargin < 4) || ~(ischar(computeMode))||...
        ~(strcmp(computeMode,'polar') ||strcmp(computeMode,'extreme'))
    computeMode = 'extreme';
end
    
if isa(secObjVec, 'polytope')
    
    isAnyEllDeg = any(isdegenerate(fstEllArr(:)));
    if mode == 'i'
        polyVec = and(secObjArr);
    else
        polyVec = secObjArr; 
    end
    [~, nCols] = size(polyVec);
    isBndVec = false(1,nCols);
    isPolyDegVec = false(1,nCols);
    isEmptyVec = false(1,nCols);
    for iCols = 1:nCols
        isBndVec(iCols) = isbounded(polyVec(iCols));
        isPolyDegVec(iCols) = ~isfulldim(polyVec(iCols));
        isEmptyVec(iCols) = isempty(double(polyVec(iCols)));
    end;
    
    if all(isEmptyVec)
        res = -1;
    elseif ~(all(isBndVec(:))) || (isAnyEllDeg && ~all(isPolyDegVec(:)))
        res = 0;
    else
        isInsideVec = false(1,nCols);
        for iCols = 1:nCols
            if isEmptyVec(iCols)
                isInsideVec(icols) = true;
            elseif isAnyEllDeg || isPolyDegVec(iCols) || ...
                    strcmp(computeMode,'extreme')
                isInsideVec(iCols) = ...
                    degPolyIsInside(fstEllArr,polyVec(iCols));
            else
                isInsideVec(iCols) = ...
                    nonDegPolyIsInside(fstEllArr,polyVec(iCols));
            end    
        end
        res = all(isInsideVec);
    end
    
    if nargout < 2
        clear status;
    end
    return;
end


if mode == 'u'
    res = 1;
    isContain = arrayfun(@(x) all(all(contains(x, secObjVec))), fstEllArr);
    if ~all( isContain(:) )
        res=0;
        return;
    end
elseif isscalar(secObjVec)
    res = 1;
    isContain = arrayfun(@(x) all(all(contains(x, secObjVec))), fstEllArr);
    if ~all( isContain(:) )
        res = 0;
    end
else    
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('Invoking CVX...');
    end
    res = 1;
    resMat  =arrayfun (@(x) qcqp(secObjVec,x), fstEllArr);
    if any(resMat(:)<1)
        res = 0;
        if any(resMat(:)==-1)
            res = -1;
            status = 0;
        end
        return;
    end
end

end





%%%%%%%%

function [res, status] = qcqp(fstEllArr, secObj)
%
% QCQP - formulate quadratically constrained quadratic programming
%        problem and invoke external solver.
%
% Input:
%   regular:
%       fstEllArr: ellipsod [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%       secObj: ellipsoid [1, 1] - ellipsoid.
%               or
%               polytope [1, 1] - polytope.
%
% Output:
%   res: double[1, 1]
%   status: double[1, 1]
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;

persistent logger;
[~, absTolScal] = getAbsTol(secObj);
[qVec, paramMat] = parameters(secObj);
if size(paramMat, 2) > rank(paramMat)
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('QCQP: Warning! Degenerate ellipsoid.');
        logger.info('      Regularizing...');
    end
    paramMat = ellipsoid.regularize(paramMat,absTolScal);
end
invQMat = ell_inv(paramMat);
invQMat = 0.5*(invQMat + invQMat');

nNumel = numel(fstEllArr);

cvx_begin sdp
variable xVec(length(invQMat), 1)

minimize(xVec'*invQMat*xVec + 2*(-invQMat*qVec)'*xVec + ...
    (qVec'*invQMat*qVec - 1))
subject to
for iCount = 1:nNumel
        [qiVec, invQiMat] = parameters(fstEllArr(iCount));
        if isdegenerate(fstEllArr(iCount))
            invQiMat = ...
                ellipsoid.regularize(invQiMat,getAbsTol(fstEllArr(iCount)));
        end
        invQiMat = ell_inv(invQiMat);
        invQiMat = 0.5*(invQiMat + invQiMat');
        xVec'*invQiMat*xVec + 2*(-invQiMat*qiVec)'*xVec + ...
            (qiVec'*invQiMat*qiVec - 1) <= 0;
end
cvx_end


status = 1;
if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
end;
if strcmp(cvx_status,'Infeasible') ...
        || strcmp(cvx_status,'Inaccurate/Infeasible')
    % problem is infeasible, or global minimum cannot be found
    res = -1;
    status = 0;
    return;
end

[~, fstAbsTol] = fstEllArr.getAbsTol();
if (xVec'*invQMat*xVec + 2*(-invQMat*qVec)'*xVec + ...
        (qVec'*invQMat*qVec - 1)) < fstAbsTol
    res = 1;
else
    res = 0;
end

end
%
%
function isInside = degPolyIsInside(ellArr, polytope)
xVec = extreme(polytope);
if isempty(xVec)
    isInside = -1;
else
    isInside = min(isinternal(ellArr, xVec', 'i'));
end
end
%
%
function isInside = nonDegPolyIsInside(ellArr,poly)
[isFeasible, internalPoint] = findInternal(poly,ellArr);
if ~isFeasible
    isInside = false;
    return;
end
[constrMat, constrConstVec] = double(poly);
[nConstr,nDims] = size(constrMat);
newConstrConstVec = constrConstVec - constrMat*internalPoint;
newConstrMat = zeros(nConstr,nDims);
for iConstr = 1:nConstr
    newConstrMat(iConstr,:) = constrMat(iConstr,:)/newConstrConstVec(iConstr);
end
[normalsMat constVec] = findNormAndConst(newConstrMat);
[~,absTol] = ellArr.getAbsTol;
isInsideArr = arrayfun(@(x) isEllPolInPolyPol(x,normalsMat, constVec,...
    internalPoint,absTol),ellArr);
isInside = all(isInsideArr(:));
end
%
function [isFeasible internalPoint] = findInternal(poly,ellArr)
[constrMat, constrConstVec] = double(poly);
[nConstraints,nDims] = size(constrMat);
basisMat = [eye(nDims); -eye(nDims)];
maxVecsMat = zeros(nDims);
[cVecCArr, shMatCArr] = arrayfun(@(x) double(x),ellArr,'UniformOutput',false);
nEll = numel(ellArr);
for iDims = 1:2*nDims
    basisVec = basisMat(iDims,:);
    cvx_begin sdp
        variable x(nDims)
        maximize( basisVec*x)
        subject to    
            for iConstraints = 1:nConstraints
                constrMat(iConstraints,:)*x <= constrConstVec(iConstraints);
            end
            for iEll = 1:nEll
                (x-cVecCArr{iEll})' * shMatCArr{nEll} * (x-cVecCArr{iEll})...
                    <= 1;
            end
    cvx_end
    maxVecsMat(iDims,:) = x';
end
internalPoint = sum(maxVecsMat)'/(2*nDims);
if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
end;
if strcmp(cvx_status,'Infeasible') ...
        || strcmp(cvx_status,'Inaccurate/Infeasible')
    % problem is infeasible, or global minimum cannot be found
    isFeasible = false;
else
    isFeasible = true;
end
end
%
function [normMat,constVec] = findNormAndConst(pointsMat)
normIndexes = convhulln(pointsMat);
[nFacets nDims] = size(normIndexes);
normMat = zeros(nFacets,nDims);
constVec = zeros(nFacets,1);
inFacetVecsMat = zeros(nDims,nDims);
for iFacets = 1:nFacets
    for iDims = 1:nDims-1
        inFacetVecsMat(iDims,:) = pointsMat(normIndexes(iFacets,iDims+1),:)-...
            pointsMat(normIndexes(iFacets,iDims),:);
    end
    norm = (null(inFacetVecsMat))';    
    constVec(iFacets) = norm*(pointsMat(normIndexes(iFacets,1),:))';
    if constVec(iFacets) < 0
        constVec(iFacets) = -constVec(iFacets);
        norm = -norm;
    end
    normMat(iFacets,:) = norm;
end
end
%
function res = isEllPolInPolyPol(ell,normalsMat, constVec,internalPoint,absTol)
polarEll = getPolar(ell-internalPoint);
suppFuncVec = rho(polarEll,normalsMat');
res = all(suppFuncVec' <= constVec+absTol);
end
function polar = getPolar(obj)
[cVec shMat] = double(obj);
invShMat = inv(shMat);
normConst = cVec'*(shMat\cVec);
polarCVec = -(shMat\cVec)/(1-normConst);
polarShMat = invShMat/(1-normConst) + polarCVec*polarCVec';
polar = ellipsoid(polarCVec,polarShMat);
end
