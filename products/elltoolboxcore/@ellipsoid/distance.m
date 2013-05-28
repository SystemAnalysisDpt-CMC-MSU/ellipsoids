function [distValArray, statusArray] = distance(ellObjArr, objArr, isFlagOn)
%
% DISTANCE - computes distance between the given ellipsoid (or array of 
%            ellipsoids) to the specified object (or arrays of objects):
%            vector, ellipsoid, hyperplane or polytope.
%            
% Input:
%   regular:
%       ellObjArr: ellipsoid [nDims1, nDims2,..., nDimsN] -  array of  
%          ellipsoids of the same dimension.
%       objArray: double / ellipsoid / hyperplane / polytope [nDims1, 
%           nDims2,..., nDimsN] - array of vectors or ellipsoids or
%           hyperplanes or polytopes. If number of elements in objArray
%           is more than 1, then it must be equal to the number of elements 
%           in ellObjArr.
%
%   optional:
%       isFlagOn: logical[1,1] - if true then distance is  computed in  
%           ellipsoidal metric, if false - in Euclidean metric (by default 
%           isFlagOn=false).
%
% Output:
%   regular:
%     distValArray: double [nDims1, nDims2,..., nDimsN] - array of pairwise 
%           calculated distances.
%           Negative distance value means
%               for ellipsoid and vector: vector belongs to the ellipsoid,
%               for ellipsoid and hyperplane: ellipsoid intersects the 
%                   hyperplane.
%               Zero distance value means for ellipsoid and vector: vector 
%                   is aboundary point of the ellipsoid,
%               for ellipsoid and hyperplane: ellipsoid  touches the 
%                   hyperplane.
%   optional:
%       statusArray: double [nDims1, nDims2,..., nDimsN] - array of time of 
%           computation of ellipsoids-vectors or ellipsoids-ellipsoids
%           distances, or status of cvx solver for ellipsoids-polytopes
%           distances.
%
% Literature:
%  1. Lin, A. and Han, S. On the Distance between Two Ellipsoids.
%     SIAM Journal on Optimization, 2002, Vol. 13, No. 1 : pp. 298-308
%  2. Stanley Chan, "Numerical method for Finding Minimum Distance to an
%     Ellipsoid". 
%     http://videoprocessing.ucsd.edu/~stanleychan/publication/...
%     unpublished/Ellipse.pdf
% 
% Example:
%   ellObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   tempMat = [1 1; 1 -1; -1 1; -1 -1]';
%   distVec = ellObj.distance(tempMat)
% 
%   distVec =
% 
%        2.3428    1.0855    1.3799    -1.0000
%
%
% $Author: Alex Kurzhanskiy  <akurzhan@eecs.berkeley.edu> $    
% $Date: 2004-2008 $
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    
% $Date: 31-10-2012 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

%
import modgen.common.throwerror

if nargin < 3
    isFlagOn = 0;
end

ellipsoid.checkIsMe(ellObjArr,'errorTag','wrongInput',...
    strcat('DISTANCE: first input argument must be ellipsoid or',...
    ' array of ellipsoids.'));

if isa(objArr, 'double')
    [distValArray, statusArray] = computeEllPointsDist(ellObjArr, objArr,...
        isFlagOn);
elseif isa(objArr, 'ellipsoid')
    [distValArray, statusArray] = computeEllEllDist(ellObjArr, objArr,...
        isFlagOn);
elseif isa(objArr, 'hyperplane')
    [distValArray, statusArray] = computeEllHpDist(ellObjArr, objArr,...
        isFlagOn);
elseif isa(objArr, 'polytope')
    [distValArray, statusArray] = computeEllPolytDist(ellObjArr, objArr,isFlagOn);
else
    throwerror('wrongInput',strcat('second argument must be array of vectors, ',...
        'ellipsoids, hyperplanes or polytopes.'));
end
end

function [ellDist timeOfCalculation] = findEllMetDistance(ellObj1,ellObj2,nMaxIter,absTol)
% FINDEELLELLDISTANCE - computes the distance between two ellipsoids
%                       in ellipsoidal metric
% Input:
%       ellObj1:  ellipsoid: [1,1] - first ellipsoid,
%       ellObj2: ellipsoid: [1,1] - second ellipsoid,
%       nMaxIter: int8[1,1] - maximal number of iterations,
%       absTol: double[1,1] - absolute tolerance,
% Output:
%       ellDist: double[1,1]  - computed distance
%       timeOfComputation: double[1,1] - time of computation
%
% Vitaly Baranov  <vetbar42@gmail.com> $	$Date: 2012-11-19 $
% Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
%
[cen1Vec ellQ1Mat]=double(ellObj1);
[cen2Vec ellQ2Mat]=double(ellObj2);
if rank(ellQ1Mat) < size(ellQ1Mat, 2)
    ellQ1Mat = ellipsoid.regularize(ellQ1Mat,ellObj1.absTol);
end
sqrQ1Mat=gras.la.sqrtmpos(ellQ1Mat,ellObj1.absTol);
sqrInvQ1Mat=sqrQ1Mat\eye(size(sqrQ1Mat));
newQ1Mat=eye(size(ellQ1Mat));
newCen1Vec=sqrInvQ1Mat*cen1Vec;
newQ2Mat=sqrInvQ1Mat*ellQ2Mat*sqrInvQ1Mat;
newCen2Vec=sqrInvQ1Mat*cen2Vec;
newQ2Mat=0.5*(newQ2Mat+newQ2Mat.');
[ellDist timeOfCalculation]=...
    computeEllEllDistance(ellipsoid(newCen1Vec,newQ1Mat),...
    ellipsoid(newCen2Vec,newQ2Mat),nMaxIter,absTol);
end
%

function [ellDist timeOfCalculation] = computeEllEllDistance(ellObj1,ellObj2,nMaxIter,absTol)
% COMPUTEELLELLDISTANCE - computes the distance between two ellipsoids
% Input:
%       ellObj1:  ellipsoid: [1,1] - first ellipsoid,
%       ellObj2: ellipsoid: [1,1] - second ellipsoid,
%       nMaxIter: int8[1,1] - maximal number of iterations,
%       absTol: double[1,1] - absolute tolerance,
% Output:
%       ellDist: double[1,1]  - computed distance
%       timeOfComputation: double[1,1] - time of computation
%
%
% Vitaly Baranov  <vetbar42@gmail.com> $	$Date: 2012-10-28 $
% Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
%
tic;
[ellCenter1Vec, ellQ1Mat] = double(ellObj1);
[ellCenter2Vec, ellQ2Mat] = double(ellObj2);
if rank(ellQ1Mat) < size(ellQ1Mat, 2)
    ellQ1Mat = ellipsoid.regularize(ellQ1Mat,ellObj1.absTol);
end
if rank(ellQ2Mat) < size(ellQ2Mat, 2)
    ellQ2Mat = ellipsoid.regularize(ellQ2Mat,ellObj2.absTol);
end

%
ellQ1Mat=ellQ1Mat\eye(size(ellQ1Mat));
ellQ2Mat=ellQ2Mat\eye(size(ellQ2Mat));
%
if (isinternal(ellObj1,ellCenter2Vec)||isinternal(ellObj2,ellCenter1Vec))
    ellDist=0;
else
    %initial centerVecs of circle inside the ellipsoids
    circleCenter1Vec=ellCenter1Vec;
    circleCenter2Vec=ellCenter2Vec;
    %
    fAngleFunc=@(xVec,yVec) acos(xVec.'*yVec/(norm(xVec)*norm(yVec)));
    fSquareFunc=@(a,b,c) (@(t) a*t^2+b*t+c);
    kIter=1;
    isDone=false;
    ellDist=inf;
    %find stepsizes that determine the points on the interval formed by
    %centerVecs of circles, and that points should belong to the boundaries of
    %corresponding ellipsoids
    while (kIter<=nMaxIter) &&(~isDone)
        %solve two one dimentional qudratic equations of the type ax^2+bx+c=0 to get the stepsizes
        circleCentersDiffVec=circleCenter2Vec-circleCenter1Vec;
        ellCircleCentersDiff1Vec=circleCenter1Vec-ellCenter1Vec;
        ellCircleCentersDiff2Vec=circleCenter1Vec-ellCenter2Vec;
        aCoeff1=circleCentersDiffVec.'*ellQ1Mat*circleCentersDiffVec;
        bCoeff1=2*circleCentersDiffVec.'*ellQ1Mat*ellCircleCentersDiff1Vec;
        cCoeff1=ellCircleCentersDiff1Vec.'*ellQ1Mat*ellCircleCentersDiff1Vec-1;
        aCoeff2=circleCentersDiffVec.'*ellQ2Mat*circleCentersDiffVec;
        bCoeff2=2*circleCentersDiffVec.'*ellQ2Mat*ellCircleCentersDiff2Vec;
        cCoeff2=ellCircleCentersDiff2Vec.'*ellQ2Mat*ellCircleCentersDiff2Vec-1;
        %
        stepSize1=fzero(fSquareFunc(aCoeff1,bCoeff1,cCoeff1),[0,1]);
        stepSize2=fzero(fSquareFunc(aCoeff2,bCoeff2,cCoeff2),[0,1]);
        if (stepSize2-stepSize1<=absTol)
            %in this case the interval between the centerVecs of circles
            %belongs to the ellipsoids and we obtain intersection
            ellDist=0;
            isDone=true;
        else
            %define new points on the boader of the ellipsoids
            newPoint1Vec=circleCenter1Vec+stepSize1.*circleCentersDiffVec;
            newPoint2Vec=circleCenter1Vec+stepSize2.*circleCentersDiffVec;
            newPointsDiffVec=newPoint2Vec-newPoint1Vec;
            %Auxilliary vectors, if ellipsoid is q(x)=0.5x'Ax+b'x+c then
            %auxilliary vectors equal to Ax+b, but in our case we have to
            %determine A from input Q, since we have x'Q^(-1)x as input
            %representation of ellipsoid
            auxilliary1Vec=ellQ1Mat*newPoint1Vec-ellQ1Mat*ellCenter1Vec;
            auxilliary2Vec=ellQ2Mat*newPoint2Vec-ellQ2Mat*ellCenter2Vec;
            newCircle1Vec=auxilliary1Vec+auxilliary1Vec;
            newCircle2Vec=auxilliary2Vec+auxilliary2Vec;
            %
            angleEll1=fAngleFunc(newPointsDiffVec,newCircle1Vec);
            angleEll2=fAngleFunc(-newPointsDiffVec,newCircle2Vec);
            if (angleEll1<absTol) && (angleEll2<absTol)
                ellDist=norm(newPointsDiffVec);
                isDone=true;
            else
                %the form of these constans is proved in the article cited
                %at the title
                gamma1Coeff=1/norm(2*ellQ1Mat);
                gamma2Coeff=1/norm(2*ellQ2Mat);
                %finally we calculate new centerVecs of circles
                circleCenter1Vec=newPoint1Vec-gamma1Coeff*(newCircle1Vec);
                circleCenter2Vec=newPoint2Vec-gamma2Coeff*(newCircle2Vec);
            end
        end
        kIter=kIter+1;
    end
end
timeOfCalculation=toc;
end

%%%%%%%%
function [ distEllVec timeOfComputation ] = computeEllVecDistance(ellObj,...
    vectorVec,nMaxIter,absTol, relTol,isFlagOn)
% COMPUTEELLVECDISTANCE - computes the distance between an ellipsoid and a
%                         vector
% Input:
%       ellObj:  ellipsoid: [1,1] - an object of class ellipsoid,
%       vectorVec: double[mVectorVec,1] - vector,
%       nMaxIter: double[1,1] - maximal number of iterations,
%       absTol: double[1,1] - absolute tolerance,
%       relTol: double[1,1] - relative tolerance
% Output:
%       distEllVec: double[1,1]  - computed distance,
%       timeOfComputation: double[1,1] - time of computation
%
%
% Author:    Vitaly Baranov  <vetbar42@gmail.com> $	$Date: 2012-10-28 $
% Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror
tic;
[ellCenterVec, ellQMat] = double(ellObj);
if rank(ellQMat) < size(ellQMat, 2)
    ellQMat = ellipsoid.regularize(ellQMat,absTol);
end
ellQMat=ellQMat\eye(size(ellQMat));
vectorVec=vectorVec-ellCenterVec;
vectorEllVal=vectorVec'*ellQMat*vectorVec;
if ( vectorEllVal < (1-absTol) )
    distEllVec=-1;
elseif (abs(vectorEllVal-1)<absTol)
    distEllVec=0;
elseif ~isFlagOn
    [unitaryMat diagMat]=eig(ellQMat);
    unitaryMat=transpose(unitaryMat);
    distEllVec=diag(diagMat);
    qVec=unitaryMat*vectorVec;
    dMean=mean(distEllVec);
    vectorNorm=norm(vectorVec);
    x0=realsqrt((dMean*vectorNorm*vectorNorm)-1)/dMean;
    %%Bisection for interval estimation
    aPoint=0;
    bPoint=x0+x0;
    cPoint=aPoint+0.5*(bPoint-aPoint);
    detFunctionAtPointA=fDetFunction(aPoint);
    detFunctionAtPointB=fDetFunction(bPoint);
    detFunctionAtPointC=fDetFunction(cPoint);
    iIter=1;
    while( iIter < nMaxIter) && ((abs(detFunctionAtPointA-...
            detFunctionAtPointC)>absTol ||....
            abs(detFunctionAtPointB-detFunctionAtPointC)>absTol))
        cPoint=aPoint+(bPoint-aPoint)*0.5;
        detFunctionAtPointA=fDetFunction(aPoint);
        detFunctionAtPointB=fDetFunction(bPoint);
        detFunctionAtPointC=fDetFunction(cPoint);
        if sign(detFunctionAtPointA)~=sign(detFunctionAtPointC)
            bPoint=cPoint;
        else
            aPoint=cPoint;
        end
        iIter=iIter+1;
    end
    %%Secant Method, search for zeros
    intervalHalfLength=10*realsqrt(relTol);
    xVec=zeros(1,nMaxIter);
    xVec(1)=cPoint-intervalHalfLength;
    xVec(2)=cPoint+intervalHalfLength;
    oneStepError=Inf;
    kIter=2;
    while( kIter < nMaxIter ) && ( oneStepError > relTol )
        deltaF = fDetFunction(xVec(kIter))-fDetFunction(xVec(kIter-1));
        if abs(deltaF) <= absTol
            throwerror('notSecant','Secant method is not applicable.');
        else
            xVec(kIter+1)=xVec(kIter)-fDetFunction(xVec(kIter))*...
                (xVec(kIter)-xVec(kIter-1))/deltaF;
            oneStepError=abs(xVec(kIter)-xVec(kIter-1))^2;
        end
        kIter=kIter+1;
    end
    lambda=xVec(kIter);
    auxilliaryVec = (eye(size(ellQMat))+lambda*ellQMat)\vectorVec;
    distEllVec = norm(auxilliaryVec-vectorVec);
else
    % (y-x)'A(y-x) -> min s.t. x'Ax=1
    % Lagrangian: L=(y-x)'A(y-x) + lambda (1 - x'Ax) =>
    % A(y-x)+lambda Ax=0 => y=(1+lambda) x =>
    % 1+lambda=1/(y'Ay)^(1/2) => find lambda and
    % find (y-x)'A(y-x).
    distPlus=(realsqrt(vectorEllVal)+1);
    distMinus=abs(realsqrt(vectorEllVal)-1);
    distEllVec=min(distPlus, distMinus);
end
timeOfComputation=toc;

    function res=fDetFunction(xPoint)
        tmpVec=1+distEllVec*xPoint;
        res= -1+sum((qVec.*qVec).*(distEllVec./...
            (tmpVec.*tmpVec)));
    end
end


function [distArray, timeArray] = computeEllPointsDist(ellObjArray, ...
    vecArray, isFlagOn)
%
% COMPUTEELLPOINTSDIST - compute distance between array of ellipsoid and
%                        array of vectors.
%
% input:
%   regular:
%       ellObjArray: ellipsoid / ellipsoid [nDims1, nDims2,..., nDimsN] -
%           single ellipsoid or array of ellipsoids
%       vecArray: double[spaceDim,nDim1,nDim2,..., nDimN] - array of vectors,
%           where spaceDim is the dimension of all the vectors in the
%           array. Three cases are available:
%               1. If ellObjArray is single ellipsoid then vecArray is
%               single vector or arbitrary array of vectors .
%               2. If ellObjArray is an array of ellipsoids then vecArray
%               is a single vector or array of vectors of the same dimensions
%               as ellObjArray.
%           Distance is computed pairwise.
%       isFlagOn: logical[1,1] if true distance is computed in ellipsoidal
%           metric otherwise in Euclidean
% output:
%   regular:
%       distArray: double[nDims1, nDims2,... nDimsN] - array of computed
%           pairwise distance between ellipsoids in the ellObjArray and
%           vectors in vecArray
%       timeArray: double[nDims1, nDims2,..., nDimsN]
import elltool.conf.Properties;
import modgen.common.throwerror;
persistent logger;
%
vecArrSizeVec = size(vecArray);
ellSizeVec=size(ellObjArray);
nEllObj = numel(ellObjArray);
nVec=numel(vecArray(1,:));
if length(vecArrSizeVec)>2
    vecSizeVec=vecArrSizeVec(2:end);
else
    vecSizeVec=vecArrSizeVec;
    vecSizeVec(1)=1;
end
vecDim=vecArrSizeVec(1);
if (nEllObj > 1) && (nVec > 1) && (((~(nEllObj==nVec) || ...
        (~(length(ellSizeVec)==length(vecSizeVec))) ||...
        (~all(ellSizeVec==vecSizeVec)))))
    throwerror('wrongInput',...
        'number of ellipsoids does not match the number of vectors.');
end
%
dimsArray = dimension(ellObjArray);
if ~all(dimsArray(1)==dimsArray(:))
    throwerror('wrongInput',...
        'DISTANCE: ellipsoids must be of the same dimension.')
end
dimSpace=dimsArray(1);
if dimSpace ~= vecDim
    throwerror('wrongInput',...
        'DISTANCE: dimensions of ellipsoid an vector do not match.');
end
%
if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if (nEllObj > 1) || (nVec > 1)
        logger.info(sprintf('Computing %d ellipsoid-to-vector distances...', max([nEllObj nVec])));
    else
        logger.info('Computing ellipsoid-to-vector distance...');
    end
end
%
N_MAX_ITER=50;
absTolArray = getAbsTol(ellObjArray);
relTolArray = getRelTol(ellObjArray);
if (nEllObj > 1) && (nEllObj == nVec)
    augxCArray=num2cell(vecArray,1);
    vecCArray=reshape(augxCArray(1,:),ellSizeVec);
    fComposite=@(ellObj,xVec,absTol,relTol)computeEllVecDistance(...
        ellObj,xVec{1},N_MAX_ITER,absTol,relTol,isFlagOn);
    [distArray timeArray] =arrayfun(fComposite,ellObjArray,vecCArray,...
        absTolArray,relTolArray);
elseif (nEllObj > 1)
    fCompositeOneVec=@(ellObj,absTol,relTol)computeEllVecDistance(...
        ellObj,vecArray,N_MAX_ITER,absTol,relTol,isFlagOn);
    [distArray timeArray] =arrayfun(fCompositeOneVec,ellObjArray,...
        absTolArray,relTolArray);
else
    vecCArray=num2cell(vecArray,1);
    if length(vecSizeVec)>1
        vecCArray=reshape(vecCArray(1,:),vecSizeVec);
    end
    fCompositeOneEll=@(xVec)computeEllVecDistance(ellObjArray,...
        xVec{1},N_MAX_ITER,absTolArray,relTolArray,isFlagOn);
    [distArray timeArray] =arrayfun(fCompositeOneEll,vecCArray);
end
end

%%%%%%%%

function [distEllEllArray, timeOfCalculationArray] = computeEllEllDist(...
    ellObj1Array, ellObj2Array, isFlagOn)
%
% COMPUTEELLELLDIST - compute distance between two arrays of ellipsoids
%
import elltool.conf.Properties;
import modgen.common.throwerror
import elltool.logging.Log4jConfigurator;
persistent logger;

ell1SizeVec = size(ellObj1Array);
ell2SizeVec = size(ellObj2Array);
nEllObj1=numel(ellObj1Array);
nEllObj2=numel(ellObj2Array);
if (nEllObj1 > 1) && (nEllObj2 > 1) && ((~(nEllObj1==nEllObj2) || ...
        (~(length(ell1SizeVec)==length(ell2SizeVec))) ||...
        (~all(ell1SizeVec==ell2SizeVec))))
    throwerror('wrongInput','DISTANCE: sizes of ellipsoidal arrays do not match.');
end
if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if (nEllObj1 > 1) || (nEllObj2 > 1)
        logger.info(sprintf('Computing %d ellipsoid-to-ellipsoid distances...',...
            max([nEllObj1 nEllObj2])));
    else
        logger.info('Computing ellipsoid-to-ellipsoid distance...');
    end
end
dim1Array=dimension(ellObj1Array);
dim2Array=dimension(ellObj2Array);
if (~all(dim1Array(:)==dim2Array(:)))
    throwerror('wrongInput','DISTANCE: dimesions mismatch.');
end
N_MAX_ITER=10000;
if (nEllObj1 > 1) && (nEllObj2 > 1)
    absTolArray = getAbsTol(ellObj1Array);
    fCompositeFlagOn=@(ellObj1,ellObj2,absTol)findEllMetDistance(...
        ellObj1,ellObj2,N_MAX_ITER,absTol);
    fCompositeFlagOff=@(ellObj1,ellObj2,absTol)computeEllEllDistance(...
        ellObj1,ellObj2,N_MAX_ITER,absTol);
    if isFlagOn
        [distEllEllArray timeOfCalculationArray] =arrayfun(...
            fCompositeFlagOn,ellObj1Array,ellObj2Array,absTolArray);
    else
        [distEllEllArray timeOfCalculationArray] =arrayfun(...
            fCompositeFlagOff,ellObj1Array,ellObj2Array,absTolArray);
    end
elseif (nEllObj1 > 1)
    absTolArray = getAbsTol(ellObj1Array);
    fCompositeOneEll2FlagOn=@(ellObj1,absTol)findEllMetDistance(...
        ellObj1,ellObj2Array,N_MAX_ITER,absTol);
    fCompositeOneEll2FlagOff=@(ellObj1,absTol)computeEllEllDistance(...
        ellObj1,ellObj2Array,N_MAX_ITER,absTol);
    if isFlagOn
        [distEllEllArray timeOfCalculationArray] =arrayfun(...
            fCompositeOneEll2FlagOn,ellObj1Array,absTolArray);
    else
        [distEllEllArray timeOfCalculationArray] =arrayfun(...
            fCompositeOneEll2FlagOff,ellObj1Array,absTolArray);
    end
else
    absTolArray = getAbsTol(ellObj2Array);
    fCompositeOneEll1FlagOn=@(ellObj2,absTol)findEllMetDistance(...
        ellObj1Array,ellObj2,N_MAX_ITER,absTol);
    fCompositeOneEll1FlagOff=@(ellObj2,absTol)computeEllEllDistance(...
        ellObj1Array,ellObj2,N_MAX_ITER,absTol);
    if isFlagOn
        [distEllEllArray timeOfCalculationArray] =arrayfun(...
            fCompositeOneEll1FlagOn,ellObj2Array,absTolArray);
    else
        [distEllEllArray timeOfCalculationArray] =arrayfun(...
            fCompositeOneEll1FlagOff,ellObj2Array,absTolArray);
    end
end
end
%
%%%%%%%%
%
function distEllHpVal = findEllHpDist(ellObj, hpObj,isFlagOn)
[vPar, cPar] = parameters(hpObj);
if cPar < 0
    cPar = -cPar;
    vPar = -vPar;
end
if isFlagOn
    sr = realsqrt(vPar' * (ellObj.shapeMat) * vPar);
else
    sr = realsqrt(vPar' * vPar);
end
if (vPar' * ellObj.centerVec) < cPar
    distEllHpVal = (cPar - rho(ellObj, vPar))/sr;
else
    distEllHpVal = (-cPar - rho(ellObj, -vPar))/sr;
end
end
%
%
%
function [distEllHpArray, status] = computeEllHpDist(ellObjArray, ...
    hpObjArray, isFlagOn)
%
%   COMPUTEELLHPDIST - compute distance between array of ellipsoids and
%   array of hyperplanes.
%

import elltool.conf.Properties;
import modgen.common.throwerror
import elltool.logging.Log4jConfigurator;
persistent logger;
  import modgen.common.throwerror

ellArrSizeVec=size(ellObjArray);
hpArrSizeVec=size(hpObjArray);
nEllObj=numel(ellObjArray);
nHpObj=numel(hpObjArray);
if (nEllObj > 1) && (nHpObj > 1) && (~(nEllObj==nHpObj)||...
        ~(length(ellArrSizeVec)==length(hpArrSizeVec))||...
        ~all(ellArrSizeVec==hpArrSizeVec))
    throwerror('wrongInput',...
        'sizes of ellipsoidal and hyperplane arrays do not match.');
end

ellDimArray = dimension(ellObjArray);
hpDimArray = dimension(hpObjArray);
  
if (~all(ellDimArray(1)==ellDimArray(:)))
    throwerror('wrongInput',...
        'ellipsoids must be of the same dimension.');
end
if (~all(hpDimArray(1)==hpDimArray(:)))
    throwerror('wrongInput',...
        'hyperplanes must be of the same dimension.');
end
if (hpDimArray(1) ~= ellDimArray(1))
    throwerror('wrongInput','ellipsoids and hyperplanes must be of the same dimension.');
end

if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if (nEllObj > 1) || (nHpObj > 1)
        logger.info(sprintf('Computing %d ellipsoid-to-hyperplane distances...',...
            max([nEllObj nHpObj])));
    else
        logger.info('Computing ellipsoid-to-hyperplane distance...');
    end
end

if (nEllObj > 1) && (nHpObj > 1)
    fComputeDist=@(ellObj,hpObj) findEllHpDist(ellObj,hpObj,isFlagOn);
    distEllHpArray=arrayfun(fComputeDist,ellObjArray,hpObjArray);
elseif (nEllObj > 1)
    fComputeDist=@(ellObj) findEllHpDist(ellObj,hpObjArray,isFlagOn);
    distEllHpArray=arrayfun(fComputeDist,ellObjArray);
else
    fComputeDist=@(hpObj) findEllHpDist(ellObjArray,hpObj,isFlagOn);
    distEllHpArray=arrayfun(fComputeDist,hpObjArray);
end

status = [];

end

%%%%%%%%
function [ distVal, cvxStat] = findEllPolDist(ellObj,polObj,isFlagOn)
absTol=ellObj.getAbsTol();
[qPar, QPar] = parameters(ellObj);
[aMat, bVec] = double(polObj);
if size(QPar, 2) > rank(QPar)
    QPar = ellipsoid.regularize(QPar,absTol);
end
QPar  = ell_inv(QPar);
QPar  = 0.5*(QPar + QPar');
mx1=dimension(ellObj);

cvx_begin sdp
variable x(mx1, 1)
variable y(mx1, 1)
if isFlagOn
    f = (x - y)'*QPar*(x - y);
else
    f = (x - y)'*(x - y);
end
minimize(f)
subject to
x'*QPar*x + 2*(-QPar*qPar)'*x + (qPar'*QPar*qPar - 1) <= 0
aMat*y - bVec <= 0
cvx_end

distVal = f;
if distVal <absTol
    distVal = 0;
end
distVal  = realsqrt(distVal);
cvxStat={cvx_status};
end


function [distEllPolArray, statusArray] = computeEllPolytDist(ellObjArray, polObj,isFlagOn)
%
%   COMPUTEELLPOLYTDIST - compute distance between arrays of ellipsoids and
%   polytop.
%   Distance between ellipsoid E and polytope X is the optimal value
%   of the following problem:
%                               min |x - y|
%                  subject to:  x belongs to E, y belongs to X.
%   Zero distance means that intersection of E and X is nonempty.
%

import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;
persistent logger;
  import modgen.common.throwerror

ellArrSizeVec = size(ellObjArray);
polArrSizeVec = size(polObj);
nEllObj=numel(ellObjArray);
nPolObj=prod(polArrSizeVec);
if (nEllObj > 1) && (nPolObj > 1) && (~(nEllObj==nPolObj)||...
        ~(length(ellArrSizeVec)==length(polArrSizeVec))||...
        ~all(ellArrSizeVec==polArrSizeVec))
    throwerror('wrongInput','sizes of ellipsoidal and polytope arrays do not match.');
end

dimEllArray=dimension(ellObjArray);
dimPolArray=zeros(size(polObj));
for iPolytopes = 1:size(dimPolArray,2)
	dimPolArray(iPolytopes) = dimension(polObj(iPolytopes));
end

if ~all(dimEllArray(1)==dimEllArray(:))
    throwerror('wrongInput','ellipsoids must be of the same dimension.');
end
if ~all(dimPolArray(1)==dimPolArray(:))
    throwerror('wrongInput','polytopes must be of the same dimension.');
end
if ~(dimPolArray(1) == dimEllArray(1))
	 throwerror('wrongInput','polytopes and ellips must be of the same dimension.');
end

if Properties.getIsVerbose()
    if isempty(logger)
        logger=Log4jConfigurator.getLogger();
    end
    if (nEllObj > 1) || (nPolObj > 1)
        logger.info(sprintf('Computing %d ellipsoid-to-polytope distances...', ...
            max([nEllObj nPolObj])));
    else
        logger.info('Computing ellipsoid-to-polytope distance...');
    end
    logger.info('Invoking CVX...');
end

if (nEllObj > 1) && (nPolObj > 1)
    distEllPolArray = zeros(size(polArrSizeVec));
    statusArray = cell(size(polArrSizeVec));
    for iObj = 1:nPolObj
    [distEllPolArray(iObj), statusArray{iObj}]=...
        findEllPolDist(ellObjArray(iObj),polObj(iObj),isFlagOn);
    end
elseif (nPolObj > 1)
    distEllPolArray = zeros(size(polArrSizeVec));
    statusArray = cell(size(polArrSizeVec));
    for iObj = 1:nPolObj
    [distEllPolArray(iObj), statusArray{iObj}]=...
        findEllPolDist(ellObjArray,polObj(iObj),isFlagOn);
    end
else
    fComputeDist=@(ellObj) findEllPolDist(ellObj,polObj,isFlagOn);
    [distEllPolArray, statusArray]=...
        arrayfun(fComputeDist,ellObjArray);
end
end



