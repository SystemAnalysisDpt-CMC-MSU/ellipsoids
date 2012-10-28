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
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
%   
  global ellOptions;

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
% Literature: 
%   Stanley Chan, "Numerical method for Finding Minimum Distance to an
%   Ellipsoid". http://videoprocessing.ucsd.edu/~stanleychan/publication/unpublished/Ellipse.pdf
% 
 import modgen.common.throwerror 
 tic;
 [ellCenterVec, ellQMat] = double(ellObj);
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
     fDetermenativeFunction=@(x) -1+sum((qVec.*qVec).*(distEllVec./((1+distEllVec*x).^2)));
     %%Bisection for interval estimation
     aPoint=0;
     bPoint=2*x0;
     cPoint=aPoint+(bPoint-aPoint)/2;
     determenativeFunctionAtPointA=fDetermenativeFunction(aPoint);
     determenativeFunctionAtPointB=fDetermenativeFunction(bPoint);
     determenativeFunctionAtPointC=fDetermenativeFunction(cPoint);
     iIter=1;
     while( iIter < nMaxIter) && ((abs(determenativeFunctionAtPointA-...
             determenativeFunctionAtPointC)>absTol ||....
             abs(determenativeFunctionAtPointB-determenativeFunctionAtPointC)>absTol))
         cPoint=aPoint+(bPoint-aPoint)*0.5;
         determenativeFunctionAtPointA=fDetermenativeFunction(aPoint);
         determenativeFunctionAtPointB=fDetermenativeFunction(bPoint);
         determenativeFunctionAtPointC=fDetermenativeFunction(cPoint);
         if sign(determenativeFunctionAtPointA)~=sign(determenativeFunctionAtPointC)
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
         deltaF = fDetermenativeFunction(xVec(kIter))-fDetermenativeFunction(xVec(kIter-1));
         if abs(deltaF) <= absTol
             throwerror('notSecant','Secant method is not applicable.');
         else
             xVec(kIter+1)=xVec(kIter)-fDetermenativeFunction(xVec(kIter))*...
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

function [d, status] = l_elldist(E, X, flag)
%
% L_ELLDIST - distance from ellipsoid to ellipsoid.
%

  global ellOptions;

  [m, n] = size(E);
  [k, l] = size(X);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('DISTANCE: sizes of ellipsoidal arrays do not match.');
  end

  dims1 = dimension(E);
  dims2 = dimension(X);
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1) | (mn2 ~= mx2) | (mn1 ~= mn2)
    error('DISTANCE: ellipsoids must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Computing %d ellipsoid-to-ellipsoid distances...\n', max([t1 t2]));
    else
      fprintf('Computing ellipsoid-to-ellipsoid distance...\n');
    end
    fprintf('Invoking YALMIP...\n');
  end

  d      = [];
  status = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = double(E(i, j));
        [r, R] = double(X(i, j));
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        Ri     = ell_inv(R);
        Ri     = 0.5*(Ri + Ri');
        o      = struct('yalmiptime', [], 'solvertime', [], 'info', [], 'problem', [], 'dimacs', []);
        x      = sdpvar(mx1, 1);
        y      = sdpvar(mx1, 1);
        if flag
          f = (x - y)'*Qi*(x - y);
        else
          f = (x - y)'*(x - y);
        end
        C   = set(x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0);
        C   = C + set(y'*Ri*y + 2*(-Ri*r)'*y + (r'*Ri*r - 1) <= 0);
        o   = solvesdp(C, f, ellOptions.sdpsettings);
        dst = double(f);
        if dst < ellOptions.abs_tol
          dst = 0;
        end
        dst = sqrt(dst);
        dd  = [dd dst];
	sts = [sts o];
      end
      d      = [d; dd];
      status = [status sts];
    end
  elseif (t1 > 1)
    for i = 1:m
      dd  = [];
      sts = [];
      for j = 1:n
        [q, Q] = double(E(i, j));
        [r, R] = double(X);
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        Ri     = ell_inv(R);
        Ri     = 0.5*(Ri + Ri');
        o      = struct('yalmiptime', [], 'solvertime', [], 'info', [], 'problem', [], 'dimacs', []);
        x      = sdpvar(mx1, 1);
        y      = sdpvar(mx1, 1);
        if flag
          f = (x - y)'*Qi*(x - y);
        else
          f = (x - y)'*(x - y);
        end
        C   = set(x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0);
        C   = C + set(y'*Ri*y + 2*(-Ri*r)'*y + (r'*Ri*r - 1) <= 0);
        o   = solvesdp(C, f, ellOptions.sdpsettings);
        dst = double(f);
        if dst < ellOptions.abs_tol
          dst = 0;
        end
        dst = sqrt(dst);
        dd  = [dd dst];
	sts = [sts o];
      end
      d      = [d; dd];
      status = [status sts];
    end
  else
    for i = 1:k
      dd  = [];
      sts = [];
      for j = 1:l
        [q, Q] = double(E);
        [r, R] = double(X(i, j));
        Qi     = ell_inv(Q);
        Qi     = 0.5*(Qi + Qi');
        Ri     = ell_inv(R);
        Ri     = 0.5*(Ri + Ri');
        o      = struct('yalmiptime', [], 'solvertime', [], 'info', [], 'problem', [], 'dimacs', []);
        x      = sdpvar(mx1, 1);
        y      = sdpvar(mx1, 1);
        if flag
          f = (x - y)'*Qi*(x - y);
        else
          f = (x - y)'*(x - y);
        end
        C   = set(x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0);
        C   = C + set(y'*Ri*y + 2*(-Ri*r)'*y + (r'*Ri*r - 1) <= 0);
        options=sdpsettings;
        options.lmilab.reltol=ellOptions.abs_tol;
        o   = solvesdp(C, f, options);
        dst = double(f);
        if dst < ellOptions.abs_tol
          dst = 0;
        end
        dst = sqrt(dst);
        dd  = [dd dst];
	sts = [sts o];
      end
      d      = [d; dd];
      status = [status sts];
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
    fprintf('Invoking YALMIP...\n');
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
        x  = sdpvar(mx1, 1);
        y  = sdpvar(mx1, 1);
        if flag
          f  = (y - x)'*Q*(y - x);
        else
          f  = (y - x)'*(y - x);
        end
        C  = set(x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1) <= 0);
        C  = C + set(A*y - b <= 0);
        o  = solvesdp(C, f, ellOptions.sdpsettings);
        d1 = double(f);
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
	sts = [sts o];
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
        x  = sdpvar(mx1, 1);
        y  = sdpvar(mx1, 1);
        if flag
          f  = (y - x)'*Q*(y - x);
        else
          f  = (y - x)'*(y - x);
        end
        C  = set(x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1) <= 0);
        C  = C + set(A*y - b <= 0);
        o  = solvesdp(C, f, ellOptions.sdpsettings);
        d1 = double(f);
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
	sts = [sts o];
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
        x  = sdpvar(mx1, 1);
        y  = sdpvar(mx1, 1);
        if flag
          f  = (y - x)'*Q*(y - x);
        else
          f  = (y - x)'*(y - x);
        end
        C  = set(x'*Q*x + 2*(-Q*q)'*x + (q'*Q*q - 1) <= 0);
        C  = C + set(A*y - b <= 0);
        o  = solvesdp(C, f, ellOptions.sdpsettings);
        d1 = double(f);
        if d1 < ellOptions.abs_tol
          d1 = 0;
        end
        d1  = sqrt(d1);
        dd  = [dd d1];
	sts = [sts o];
      end
      d      = [d; dd];
      status = [status sts];
    end
  end

  return;
