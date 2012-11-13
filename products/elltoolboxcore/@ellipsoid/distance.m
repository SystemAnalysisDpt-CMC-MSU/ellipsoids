function [d, status] = distance(E, X, flag)
%
% DISTANCE - computes distance from the given ellipsoid to the specified object:
%            vector, ellipsoid, hyperplane or polytope.
%
%
% Description:
% ------------
%
%      D = DISTANCE(E, Y)  Given array of ellipsoids E and array of vectors defined
%                          by matrix Y (vectors are columns of Y), so that number
%                          of ellipsoids in E is the same as number of vectors in Y,
%                          or, alternatively, E being single ellipsoid or Y being
%                          single vector, compute the distance from ellipsoids in E
%                          to vectors in Y.
%    D = DISTANCE(E1, E2)  Given two ellipsoidal arrays of the same size, E1 and E2,
%                          or, alternatively, E1 or E2 being single ellipsoid,
%                          compute the distance pairwise.
%      D = DISTANCE(E, H)  Given array of ellipsoids E, and array of hyperplanes H
%                          of the same size, or, alternatively, E being single
%                          ellipsoid or H - single hyperplane structure, 
%                          compute the distance from ellipsoids to hyperplanes pairwise.
%      D = DISTANCE(E, P)  Given array of ellipsoids E, and array of polytopes P
%                          of the same size, or, alternatively, E being single
%                          ellipsoid or P - single polytope object, 
%                          compute the distance from ellipsoids to polytopes pairwise.
%                          Requires Multi-Parametric Toolbox.
%   D = DISTANCE(E, X, F)  Optional parameter F, if set to 1, indicates that
%                          the distance should be computed in the metric
%                          of ellipsoids in E. By default (F = 0), the distance
%                          is computed in Euclidean metric.
%
%    Negative distance value means
%      for ellipsoid and vector: vector belongs to the ellipsoid,
%      for ellipsoid and hyperplane: ellipsoid intersects the hyperplane.
%    Zero distance value means
%      for ellipsoid and vector: vector is a boundary point of the ellipsoid,
%      for ellipsoid and hyperplane: ellipsoid touches the hyperplane.
%
%    Distance between ellipsoid E and ellipsoid or polytope X is the optimal value
%    of the following problem:
%                               min |x - y|
%                  subject to:  x belongs to E, y belongs to X.
%    Zero distance means that intersection of E and X is nonempty.
%
%
% Output:
% -------
%
%    D - array of distances. 
%    S - (optional) status variable returned by YALMIP.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISINSIDE, ISINTERNAL, INTERSECT,
%    HYPERPLANE/HYPERPLANE,
%    POLYTOPE/POLYTOPE.
%

%
% $Author: Alex Kurzhanskiy  <akurzhan@eecs.berkeley.edu> $    $Date: 2004-2008 $
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author:  Vitaly Baranov  <vetbar42@gmail.com> $    $Date: 31-10-2012 $
% $Copyright: Lomonosov Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
% Literature: 
%    1. Lin, A. and Han, S. On the Distance between Two Ellipsoids. 
%       SIAM Journal on Optimization, 2002, Vol. 13, No. 1 : pp. 298-308
%    2. Stanley Chan, "Numerical method for Finding Minimum Distance to an
%       Ellipsoid". http://videoprocessing.ucsd.edu/~stanleychan/publication/unpublished/Ellipse.pdf
%   
  global ellOptions;
  import modgen.common.throwerror
if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  if nargin < 3
    flag = 0;
  end

  if ~(isa(E, 'ellipsoid'))
    error('DISTANCE: first argument must be ellipsoid or array of ellipsoids.');
  end


  if isa(X, 'double')
    [d, status] = computePointsEllDist(E, X, flag);
    if nargout < 2
      clear status;
    end
    return;
  end

  if isa(X, 'ellipsoid')
    [d, status] = l_elldist(E, X, flag);
    if nargout < 2
      clear status;
    end
    return;
  end

  if isa(X, 'hyperplane')
    [d, status] = l_hpdist(E, X, flag);
    if nargout < 2
      clear status;
    end
    return;
  end
  
  if isa(X, 'polytope')
    [d, status] = l_polydist(E, X);
    if nargout < 2
      clear status;
    end
    return;
  end

  error('DISTANCE: second argument must be array of vectors, ellipsoids, hyperplanes or polytopes.');

  return;



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
    ellQ1Mat = regularize(ellQ1Mat);
end
if rank(ellQ2Mat) < size(ellQ2Mat, 2)
    ellQ2Mat = regularize(ellQ2Mat);
end

%
ellQ1Mat=ellQ1Mat\eye(size(ellQ1Mat));
ellQ2Mat=ellQ2Mat\eye(size(ellQ2Mat));
%
if (isinternal(ellObj1,ellCenter2Vec)||isinternal(ellObj2,ellCenter1Vec))
    ellDist=0;
else
    %initial centers of circle inside the ellipsoids
    circleCenter1Vec=ellCenter1Vec;
    circleCenter2Vec=ellCenter2Vec;
    %
    fAngleFunc=@(xVec,yVec) acos(xVec.'*yVec/(norm(xVec)*norm(yVec)));
    fSquareFunc=@(a,b,c) (@(t) a*t^2+b*t+c);
    kIter=1;
    isDone=false;  
    ellDist=inf;
    %find stepsizes that determine the points on the interval formed by
    %centers of circles, and that points should belong to the boundaries of
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
        if (stepSize2<=stepSize1)
            %in this case the interval between the centers of circles
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
                %finally we calculate new centers of circles
                circleCenter1Vec=newPoint1Vec-gamma1Coeff*(newCircle1Vec);
                circleCenter2Vec=newPoint2Vec-gamma2Coeff*(newCircle2Vec);
            end
        end 
        kIter=kIter+1;   
    end
end
timeOfCalculation=toc;

%%%%%%%%
function [ distEllVec timeOfComputation ] = computeEllVecDistance(ellObj,vectorVec,nMaxIter,absTol, relTol)
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
 ellQMat=ellQMat\eye(size(ellQMat));
 vectorVec=vectorVec-ellCenterVec;
 vectorEllVal=vectorVec'*ellQMat*vectorVec;
 if ( vectorEllVal< 1)
     distEllVec=-1;
 elseif (vectorEllVal==1)
     distEllVec=0;
 else
     [unitaryMat diagMat]=eig(ellQMat);
     unitaryMat=transpose(unitaryMat);
     distEllVec=diag(diagMat);
     qVec=unitaryMat*vectorVec;
     dMean=mean(distEllVec);
     vectorNorm=norm(vectorVec);
     x0=sqrt((dMean*vectorNorm*vectorNorm)-1)/dMean;
     fDetFunction=@(x) -1+sum((qVec.*qVec).*(distEllVec./...
         ((1+distEllVec*x).*(1+distEllVec*x))));
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
     intervalHalfLength=10*sqrt(relTol);
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
 end
 timeOfComputation=toc;
 

  
function [distMat, timeMat] = computePointsEllDist(ellObjMat, vecArray, flag)
%
% L_POINTDIST - distance from ellipsoid to vector.
%
  global ellOptions;
%
  [mSize, lSize] = size(ellObjMat);
  [kSize, nVec] = size(vecArray);
  nEllObj      = mSize * lSize;
  if (nEllObj > 1) && (nVec > 1) && (nEllObj ~= nVec)
    error('DISTANCE: number of ellipsoids does not match the number of vectors.');
  end
%
  dimsMat = dimension(ellObjMat);
  minDim   = min(min(dimsMat));
  maxDim   = max(max(dimsMat));
  if minDim ~= maxDim
    error('DISTANCE: ellipsoids must be of the same dimension.')
  end
  if maxDim ~= kSize
    error('DISTANCE: dimensions of ellipsoid an vector do not match.');
  end
%
  if ellOptions.verbose > 0
    if (nEllObj > 1) || (nVec > 1)
      fprintf('Computing %d ellipsoid-to-vector distances...\n', max([nEllObj nVec]));
    else
      fprintf('Computing ellipsoid-to-vector distance...\n');
    end
  end
%
%  
  N_MAX_ITER=50;
  ABS_TOL=ellOptions.abs_tol;
  REL_TOL=ellOptions.rel_tol;     
  if (nEllObj > 1) && (nEllObj == nVec)
    distMat=zeros(mSize,lSize);
    timeMat=zeros(mSize,lSize);
    for i = 1:mSize
      for j = 1:lSize
        yVec      = vecArray(:, i*j);
        [dist time] = computeEllVecDistance(ellObjMat(i,j),yVec,N_MAX_ITER,ABS_TOL,REL_TOL);
        distMat(i,j) = dist;
        timeMat(i,j) = time;
      end
    end
  elseif (nEllObj > 1)
    distMat=zeros(mSize,lSize);
    timeMat=zeros(mSize,lSize);
    for i = 1:mSize
      for j = 1:lSize
       yVec=vecArray;
       [dist time] = computeEllVecDistance(ellObjMat(i,j),yVec,N_MAX_ITER,ABS_TOL,REL_TOL);
       distMat(i,j) = dist;
       timeMat(i,j) = time;
      end
    end
  else
    distMat=zeros(1,nVec);
    timeMat=zeros(1,nVec);
    for i = 1:nVec        
      yVec= vecArray(:, i); 
      [dist time]= computeEllVecDistance(ellObjMat,yVec,N_MAX_ITER,ABS_TOL,REL_TOL);
      distMat(i) = dist;
      timeMat(i) = time;
    end
  end
return;


%%%%%%%%

function [distEllEll, timeOfCalculation] = l_elldist(ellObj1, ellObj2, flag)
%
% L_ELLDIST - distance from ellipsoid to ellipsoid.
%
    global ellOptions;

    [mSize1, kSize1] = size(ellObj1);
    [mSize2, kSize2] = size(ellObj2);
    nEllObj1     = mSize1 * kSize1;
    nEllObj2     = mSize2 * kSize2;
    if (nEllObj1 > 1) && (nEllObj2 > 1) && ((mSize1 ~= mSize2) || (kSize1 ~= kSize2))
        throwerror('DISTANCE: sizes of ellipsoidal arrays do not match.');
    end
    if ellOptions.verbose > 0
        if (nEllObj1 > 1) || (nEllObj2 > 1)
          fprintf('Computing %d ellipsoid-to-ellipsoid distances...\n', max([nEllObj1 nEllObj2]));
        else
          fprintf('Computing ellipsoid-to-ellipsoid distance...\n');
        end
    end
    N_MAX_ITER=10000;
    ABS_TOL=ellOptions.abs_tol;
    if (nEllObj1 > 1) && (nEllObj2 > 1)
        distEllEll=zeros(mSize1,kSize1);  
        timeOfCalculation=zeros(mSize1,kSize1);
        for i = 1:mSize1
            for j = 1:kSize1
                [distEllEll(i,j) timeOfCalculation(i,j)]=...
                computeEllEllDistance(ellObj1(i,j),ellObj2(i,j),...
                N_MAX_ITER,ABS_TOL);
            end
        end
    elseif (nEllObj1 > 1)
        distEllEll=zeros(mSize2,kSize2);  
        timeOfCalculation=zeros(mSize2,kSize2);
        for i = 1:mSize1
            for j = 1:kSize1
                [distEllEll(i,j) timeOfCalculation(i,j)]=...
                    computeEllEllDistance(ellObj1(i,j),ellObj2,...
                    N_MAX_ITER,ABS_TOL);      
            end
        end
    else
        distEllEll=zeros(mSize2,kSize2);  
        timeOfCalculation=zeros(mSize2,kSize2);
        for i = 1:mSize2
          for j = 1:kSize2        
            [distEllEll(mSize2,kSize2) timeOfCalculation(mSize2,kSize2)]=...
                computeEllEllDistance(ellObj1,ellObj2(i,j),...
                N_MAX_ITER,ABS_TOL);
          end
        end
    end

  return;





%%%%%%%%

function [d, status] = l_hpdist(E, X, flag)
%
% L_HPDIST - distance from ellipsoid to hyperplane.
%

  global ellOptions;

  [m, n] = size(E);
  [k, l] = size(X);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('DISTANCE: sizes of ellipsoidal and hyperplane arrays do not match.');
  end

  dims1 = dimension(E);
  dims2 = dimension(X);
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1)
    error('DISTANCE: ellipsoids must be of the same dimension.');
  end
  if (mn2 ~= mx2)
    error('DISTANCE: hyperplanes must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Computing %d ellipsoid-to-hyperplane distances...\n', max([t1 t2]));
    else
      fprintf('Computing ellipsoid-to-hyperplane distance...\n');
    end
  end

  d = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd = [];
      for j = 1:n
        [v, c] = parameters(X(i, j));
        if c < 0
          c = -c;
          v = -v;
        end
        if flag
          sr = sqrt(v' * (E(i, j).shape) * v);
	else
          sr = sqrt(v' * v);
	end
        if (v' * E(i, j).center) < c
          d1 = (c - rho(E(i, j), v))/sr;
        else
          d1 = (-c - rho(E(i, j), -v))/sr;
        end
        dd = [dd d1];
      end
      d = [d; dd];
    end
  elseif (t1 > 1)
    [v, c] = parameters(X);
    if c < 0
      c = -c;
      v = -v;
    end
    for i = 1:m
      dd = [];
      for j = 1:n
        if flag
          sr = sqrt(v' * (E(i, j).shape) * v);
	else
          sr = sqrt(v' * v);
	end
        if (v' * E(i, j).center) < c
          d1 = (c - rho(E(i, j), v))/sr;
        else
          d1 = (-c - rho(E(i, j), -v))/sr;
        end
        dd = [dd d1];
      end
      d = [d; dd];
    end
  else
    for i = 1:k
      dd = [];
      for j = 1:l
        [v, c] = parameters(X(i, j));
        if c < 0
          c = -c;
          v = -v;
        end
        if flag
          sr = sqrt(v' * (E.shape) * v);
	else
          sr = sqrt(v' * v);
	end
        if (v' * E.center) < c
          d1 = (c - rho(E, v))/sr;
        else
          d1 = (-c - rho(E, -v))/sr;
        end
        dd = [dd d1];
      end
      d = [d; dd];
    end
  end

  status = [];

  return;





%%%%%%%%

function [d, status] = l_polydist(E, X)
%
% L_POLYDIST - distance from ellipsoid to polytope.
%

  global ellOptions;

  [m, n] = size(E);
  [k, l] = size(X);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('DISTANCE: sizes of ellipsoidal and polytope arrays do not match.');
  end

  dims1 = dimension(E);
  dims2 = [];
  for i = 1:k;
    dd = [];
    for j = 1:l
      dd = [dd dimension(X(j))];
    end
    dims2 = [dims2; dd];
  end
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1)
    error('DISTANCE: ellipsoids must be of the same dimension.');
  end
  if (mn2 ~= mx2)
    error('DISTANCE: polytopes must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Computing %d ellipsoid-to-polytope distances...\n', max([t1 t2]));
    else
      fprintf('Computing ellipsoid-to-polytope distance...\n');
    end
    fprintf('Invoking CVX...\n');
  end

  d      = [];
  status = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = parameters(E(i, j));
        %[A, b] = double(X(i, j));
        [A, b] = double(X(j));
        if size(Q, 2) > rank(Q)
          Q = regularize(Q);
        end
        Q  = ell_inv(Q);
        Q  = 0.5*(Q + Q');
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                A*y - b <= 0
        cvx_end

        d1 = f;
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
        sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  elseif (t1 > 1)
    [A, b] = double(X);
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = parameters(E(i, j));
        if size(Q, 2) > rank(Q)
          Q = regularize(Q);
        end
        Q  = ell_inv(Q);
        Q  = 0.5*(Q + Q');
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                A*y - b <= 0
        cvx_end

        d1 = f;
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
        sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  else
    [q, Q] = parameters(E);
    if size(Q, 2) > rank(Q)
      Q = regularize(Q);
    end
    Q = ell_inv(Q);
    Q = 0.5*(Q + Q');
    for i = 1:k
      dd  = [];
      sts = [];
      for j = 1:l
        %[A, b] = double(X(i, j));
        [A, b] = double(X(j));
        cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                A*y - b <= 0
        cvx_end

        d1 = f;
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
        sts = [sts cvx_status];
      end
      d      = [d; dd];
      status = [status sts];
    end
  end

  return;