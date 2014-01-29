function [resArr, statusArr] = intersect(myEllArr, objArr, mode)
%
% INTERSECT - checks if the union or intersection of ellipsoids intersects
%             given ellipsoid, hyperplane or polytope.
%
%   resArr = INTERSECT(myEllArr, objArr, mode) - Checks if the union
%       (mode = 'u') or intersection (mode = 'i') of ellipsoids
%       in myEllArr intersects with objects in objArr.
%       objArr can be array of ellipsoids, array of hyperplanes,
%       or array of polytopes.
%       Ellipsoids, hyperplanes or polytopes in objMat must have
%       the same dimension as ellipsoids in myEllArr.
%       mode = 'u' (default) - union of ellipsoids in myEllArr.
%       mode = 'i' - intersection.
%
%   If we need to check the intersection of union of ellipsoids in
%   myEllArr (mode = 'u'), or if myEllMat is a single ellipsoid,
%   it can be done by calling distance function for each of the
%   ellipsoids in myEllArr and objMat, and if it returns negative value,
%   the intersection is nonempty. Checking if the intersection of
%   ellipsoids in myEllArr (with size of myEllMat greater than 1)
%   intersects with ellipsoids or hyperplanes in objArr is more
%   difficult. This problem can be formulated as quadratically
%   constrained quadratic programming (QCQP) problem.
%
%   Let objArr(iObj) = E(q, Q) be an ellipsoid with center q and shape 
%   matrix Q. To check if this ellipsoid intersects (or touches) the 
%   intersection of ellipsoids in meEllArr: E(q1, Q1), E(q2, Q2), ...,
%   E(qn, Qn), we define the QCQP problem:
%                     J(x) = <(x - q), Q^(-1)(x - q)> --> min
%   with constraints:
%                      <(x - q1), Q1^(-1)(x - q1)> <= 1   (1)
%                      <(x - q2), Q2^(-1)(x - q2)> <= 1   (2)
%                      ................................
%                      <(x - qn), Qn^(-1)(x - qn)> <= 1   (n)
%
%   If this problem is feasible, i.e. inequalities (1)-(n) do not
%   contradict, or, in other words, intersection of ellipsoids
%   E(q1, Q1), E(q2, Q2), ..., E(qn, Qn) is nonempty, then we can find
%   vector y such that it satisfies inequalities (1)-(n) and minimizes
%   function J. If J(y) <= 1, then ellipsoid E(q, Q) intersects or touches
%   the given intersection, otherwise, it does not. To check if E(q, Q)
%   intersects the union of E(q1, Q1), E(q2, Q2), ..., E(qn, Qn),
%   we compute the distances from this ellipsoids to those in the union.
%   If at least one such distance is negative,
%   then E(q, Q) does intersect the union.
%
%   If we check the intersection of ellipsoids with hyperplane
%   objArr = H(v, c), it is enough to check the feasibility
%   of the problem
%                       1'x --> min
%   with constraints (1)-(n), plus
%                     <v, x> - c = 0.
%
%   Checking the intersection of ellipsoids with polytope
%   objArr = P(A, b) reduces to checking if there any x, satisfying
%   constraints (1)-(n) and 
%                        Ax <= b.
%
% Input:
%   regular:
%       myEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of 
%            ellipsoids.
%       objArr: ellipsoid / hyperplane /
%           / polytope [nDims1,nDims2,...,nDimsN] - array of ellipsoids or
%           hyperplanes or polytopes of the same sizes.
%
%   optional:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%
%           note: If mode == 'u', then mRows, nCols should be equal to 1.
%
% Output:
%   resArr: double[nDims1,nDims2,...,nDimsN] - return:
%       resArr(iCount) = -1 in case parameter mode is set
%           to 'i' and the intersection of ellipsoids in myEllArr
%           is empty.
%       resArr(iCount) = 0 if the union or intersection of
%           ellipsoids in myEllArr does not intersect the object
%           in objArr(iCount).
%       resArr(iCount) = 1 if the union or intersection of
%           ellipsoids in myEllArr and the object in objArr(iCount)
%           have nonempty intersection.
%   statusArr: double[0, 0]/double[nDims1,nDims2,...,nDimsN] - status
%       variable. statusArr is empty if mode = 'u'.
%
% Example:
%   firstEllObj = ellipsoid([-2; -1], [4 -1; -1 1]);
%   secEllObj = firstEllObj + [5; 5];
%   hypObj  = hyperplane([1; -1]);
%   ellVec = [firstEllObj secEllObj];
%   ellVec.intersect(hypObj)
% 
%   ans =
% 
%        1
% 
%   ellVec.intersect(hypObj, 'i')
% 
%   ans =
% 
%       -1
% 
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
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    
% $Date: March-2013 $
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics 
%             and Computer Science,
%             System Analysis Department 2013$
%

import elltool.conf.Properties;
import modgen.common.throwerror;
import modgen.common.checkmultvar;
import elltool.logging.Log4jConfigurator;

persistent logger;

ellipsoid.checkIsMe(myEllArr,'first');
modgen.common.checkvar(objArr,@(x) isa(x, 'ellipsoid') ||...
    isa(x, 'hyperplane') || isa(x, 'polytope'),...
    'errorTag','wrongInput', 'errorMessage',...
    'second input argument must be ellipsoid,hyperplane or polytope.');

if (nargin < 3) || ~(ischar(mode))
    mode = 'u';
end
absTolArr = getAbsTol(myEllArr);
resArr = [];
statusArr = [];

if isempty(logger)
    logger=Log4jConfigurator.getLogger();
end

if mode == 'u'
    if ~isa(objArr,'polytope')
        auxArr = arrayfun(@(x,y) distance(myEllArr, x), objArr,'UniformOutput',false);
    else
        auxArr = cell(size(objArr));
        [~, nCols] = size(objArr);
        for iCols = 1:nCols
            auxArr{iCols} = distance(myEllArr,objArr(iCols));
        end
    end
    res = cellfun(@(x) double(any(x(:) <= absTolArr(:))),auxArr);
    status = [];
elseif isa(objArr, 'ellipsoid')
   
    fCheckDims(dimension(myEllArr),dimension(objArr));
   
    if Properties.getIsVerbose()
        logger.info('Invoking CVX...\n');
    end
   
    [resArr statusArr] = arrayfun(@(x) qcqp(myEllArr, x), objArr);
elseif isa(objArr, 'hyperplane')
   
    fCheckDims(dimension(myEllArr),dimension(objArr));
   
    if Properties.getIsVerbose()
        logger.info('Invoking CVX...\n');
    end
   
    [resArr statusArr] = arrayfun(@(x) lqcqp(myEllArr, x), objArr);
else
    nDimsArr = zeros(size(objArr));
    [~, nCols] = size(objArr);
    for iCols = 1:nCols
        nDimsArr(iCols) = dimension(objArr(iCols));
    end
    fCheckDims(dimension(myEllArr),nDimsArr);
   
    if Properties.getIsVerbose()
        logger.info('Invoking CVX...\n');
    end
    
    resArr = zeros(size(objArr));
    statusArr = zeros(size(objArr));
    for iCols = 1:nCols
        [resArr(iCols) statusArr(iCols)] = lqcqp2(myEllArr, objArr(iCols));
    end
end

if isempty(resArr)
    resArr = res;
end

if isempty(statusArr)
    statusArr = status;
end

resArr = double(resArr);

    function fCheckDims(nDims1Arr,nDims2Arr)
        modgen.common.checkmultvar...
            ('(x1(1)==x2(1))&&all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
            2,nDims1Arr,nDims2Arr,...
            'errorTag','wrongSizes',...
            'errorMessage','input arguments must be of the same dimension.');
    end
end





%%%%%%%%

function [res, status] = qcqp(fstEllArr, secEll)
%
% QCQP - formulate quadratically constrained quadratic programming
%        problem and invoke external solver.
%
% Input:
%   regular:
%       fstEllArr: ellipsod [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%       secEll: ellipsoid [1, 1] - ellipsoid.
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

status = 1;
[secEllCentVec, secEllShMat] = parameters(secEll);

if isempty(logger)
    logger=Log4jConfigurator.getLogger();
end

if isdegenerate(secEll)
    if Properties.getIsVerbose()
        logger.info('QCQP: Warning! Degenerate ellipsoid.\n');
        logger.info('      Regularizing...\n');
    end
    secEllShMat = ...
        ellipsoid.regularize(secEllShMat,getAbsTol(secEll));
end
secEllShMat = ell_inv(secEllShMat);
secEllShMat = 0.5*(secEllShMat + secEllShMat');
secEllShDublMat = secEllShMat;
secEllCentDublVec = secEllCentVec;
%cvx
nNumel = numel(fstEllArr);


absTolArr = getAbsTol(fstEllArr);
cvx_begin sdp
variable cvxExprVec(length(secEllShMat), 1)
minimize(cvxExprVec'*secEllShMat*cvxExprVec + ...
    2*(-secEllShMat*secEllCentVec)'*cvxExprVec + ...
    (secEllCentVec'*secEllShMat*secEllCentVec - 1))
subject to
for iCount = 1:nNumel
        [secEllCentVec, secEllShMat] = ...
            parameters(fstEllArr(iCount));
        if isdegenerate(fstEllArr(iCount))
            secEllShMat = ellipsoid.regularize(secEllShMat,...
                absTolArr(iCount));
        end
        invSecEllShMat = ell_inv(secEllShMat);
        invSecEllShMat = 0.5*(invSecEllShMat + invSecEllShMat');
        cvxExprVec'*invSecEllShMat*cvxExprVec +...
            2*(-invSecEllShMat*secEllCentVec)'*cvxExprVec + ...
            (secEllCentVec'*invSecEllShMat*secEllCentVec - 1) <= 0;
end

cvx_end
if strcmp(cvx_status,'Infeasible') ||...
        strcmp(cvx_status,'Inaccurate/Infeasible')
    res = -1;
    return;
end
[~, fstAbsTol] = fstEllArr.getAbsTol();
if cvxExprVec'*secEllShDublMat*cvxExprVec + ...
        2*(-secEllShDublMat*secEllCentDublVec)'*cvxExprVec + ...
        (secEllCentDublVec'*secEllShDublMat*secEllCentDublVec - 1) ...
        <= fstAbsTol
    res = 1;
else
    res = 0;
end;


end





%%%%%%%%

function [res, status] = lqcqp(myEllArr, hyp)
%
% LQCQP - formulate quadratic programming problem with linear and
%         quadratic constraints, and invoke external solver.
%
% Input:
%   regular:
%       fstEllArr: ellipsod [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%       hyp: hyperplane [1, 1] - hyperplane.
%
% Output:
%   res: double[1, 1]
%   status: double[1, 1]
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

import modgen.common.throwerror;
import elltool.conf.Properties;
status = 1;
[normHypVec, hypScalar] = parameters(hyp);
if hypScalar < 0
    hypScalar = -hypScalar;
    normHypVec = -normHypVec;
end

%cvx
nNumel = numel(myEllArr);


absTolArr = getAbsTol(myEllArr);
cvx_begin sdp
variable cvxExprVec(size(normHypVec, 1), 1)
minimize(abs(normHypVec'*cvxExprVec - hypScalar))
subject to
for iCount = 1:nNumel
        [ellCentVec, ellShMat] = parameters(myEllArr(iCount));
        if isdegenerate(myEllArr(iCount))
            ellShMat = ...
                ellipsoid.regularize(ellShMat,absTolArr(iCount));
        end
        invEllShMat  = ell_inv(ellShMat);
        cvxExprVec'*invEllShMat*cvxExprVec - ...
            2*ellCentVec'*invEllShMat*cvxExprVec + ...
            (ellCentVec'*invEllShMat*ellCentVec - 1) <= 0;
end

cvx_end
if strcmp(cvx_status,'Infeasible') || ...
        strcmp(cvx_status, 'Inaccurate/Infeasible')
    res = -1;
    return;
end;

[~, myAbsTol] = myEllArr.getAbsTol(); 
if abs(normHypVec'*cvxExprVec - hypScalar) <= myAbsTol
    res = 1;
else
    res = 0;
end;

end





%%%%%%%%

function [res, status] = lqcqp2(myEllArr, polyt)
%
% LQCQP2 - formulate quadratic programming problem with
%          linear and quadratic constraints, and invoke external solver.
%
% Input:
%   regular:
%       fstEllArr: ellipsod [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%       polyt: polytope [1, 1] - polytope.
%
% Output:
%   res: double[1, 1]
%   status: double[1, 1]
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%

import modgen.common.throwerror;
import elltool.conf.Properties;
status = 1;
[aMat, bVec] = double(polyt);
nNumel = numel(myEllArr);

absTolArr = getAbsTol(myEllArr);
cvx_begin sdp
variable cvxExprVec(size(aMat, 2), 1)
minimize(max(aMat*cvxExprVec-bVec))
subject to
for iCount = 1:nNumel
        [ellCentVec, ellShMat] = parameters(myEllArr(iCount));
        if isdegenerate(myEllArr(iCount))
            ellShMat = ...
                ellipsoid.regularize(ellShMat,absTolArr(iCount));
        end
        invEllShMat  = ell_inv(ellShMat);
        invEllShMat  = 0.5*(invEllShMat + invEllShMat');
        cvxExprVec'*invEllShMat*cvxExprVec - ...
            2*ellCentVec'*invEllShMat*cvxExprVec + ...
            (ellCentVec'*invEllShMat*ellCentVec - 1) <= 0;
end

cvx_end

if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
end;
if strcmp(cvx_status,'Infeasible') || ...
        strcmp(cvx_status,'Inaccurate/Infeasible')
    res = -1;
    return;
end;
if max(aMat*cvxExprVec-bVec) <= min(getAbsTol(myEllArr(:)))
    res = 1;
else
    res = 0;
end;
end
