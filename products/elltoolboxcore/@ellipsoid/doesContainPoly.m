function doesContain = doesContainPoly(ellArr,poly,varargin)
% DOESELLCONTAINPOLY -- privat function, used by doesContain and
%   doesIntersection contain, to check, if intersection of ellipsids in
%   ellArr contains polytope poly.
%   
%   To ensure, if polytope belongs to 
%   intersection of ellipsoids we can either check if the vertices of this 
%   polytope belong to every ellipsoid in the intersection, or, if polytope
%   and ellipsoid are not degenerate, check, find intenal point of intP
%   intersectionthen of ellipsoid with the polytope(if it does not exist,
%   then polytope does not belong to intersection), change coordinates
%   newX = oldX - intP
%   and then check if polar of ellipsoids in new coordinates belogs to
%   polar of polytope.
%
% Input:
%   regular:
%       ellArr: ellipsoid [nDims1,nDims2,...,nDimsN]/[1,1] - first
%           array of ellipsoids.
%       poly: polytope[1,1] - single polytope
%
%    properties:
%       computeMode: char[1,] - 'highDimFast' or 'lowDimFast'. Determines, 
%           which way function is computed, when secObjArr is polytope. If 
%           secObjArr is ellipsoid computeMode is ignored. 'highDimFast' 
%           works  faster for  high dimensions, 'lowDimFast' for low. If
%           this property is omitted if dimension of ellipsoids is greater
%           then 10, then 'hightDimFast' is choosen, otherwise -
%           'lowDimFast'
%
% Output:
%   isPosArr: logical[nDims1,nDims2,...,nDimsN],
%       resArr(iCount) = true - firstEllArr(iCount)
%       contains secondObjArr(iCount), false - otherwise.
varargin = varargin{:};
[~,~,compMode,isCompModeSpec] = modgen.common.parseparext(varargin,'computeMode');
if ~isCompModeSpec || ~(ischar(compMode))||...
        ~(strcmp(compMode,'highDimFast') ||...
          strcmp(compMode,'lowDimFast'))
    if dimension(ellArr(1)) > 10
        computeMode = 'highDimFast';
    else
        computeMode = 'lowDimFast';
    end
else
    computeMode = compMode;
end

isAnyEllDeg = any(isdegenerate(ellArr(:)));
isPolyDeg = ~isfulldim(poly);
isBnd = isbounded(poly);
if ~isBnd || (isAnyEllDeg && isPolyDeg)
    doesContain = false;
else
    if isAnyEllDeg || isPolyDeg || ...
                    strcmp(computeMode,'lowDimFast')
        doesContain = doesContainLowDim(ellArr,poly);
    else
        doesContain = doesContainHighDim(ellArr,poly);
    end
end
end

function doesContain = doesContainLowDim(ellArr,poly)
xVec = extreme(poly);
doesContain = min(isinternal(ellArr, xVec', 'i'));
end

function doesContain = doesContainHighDim(ellArr,poly)
[isFeasible, internalPoint] = findInternal(ellArr,poly);
if ~isFeasible
    doesContain = false;
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
doesContain = all(isInsideArr(:));
end
%
function [isFeasible internalPoint] = findInternal(ellArr,poly)
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
if strcmp(cvx_status,'Inaccurate/Solved')
    if ~isinternal(ellArr,internalPoint,'i') || ~isinside(poly,internalPoint)
        throwerror('cvxError','internal point found incorrectly');
    end
end
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
function polar = getPolar(ell)
[cVec shMat] = double(ell);
invShMat = inv(shMat);
normConst = cVec'*(shMat\cVec);
polarCVec = -(shMat\cVec)/(1-normConst);
polarShMat = invShMat/(1-normConst) + polarCVec*polarCVec';
polar = ellipsoid(polarCVec,polarShMat);
end


    
                