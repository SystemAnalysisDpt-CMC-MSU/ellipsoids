function [res, status] = isinside(fstEllArr, secObjArr, mode)
%
% ISINSIDE - checks if the intersection of ellipsoids contains the
%            union or intersection of given ellipsoids or polytopes.
%
%   res = ISINSIDE(fstEllArr, secEllArr, mode) Checks if the union
%       (mode = 'u') or intersection (mode = 'i') of ellipsoids in
%       secEllArr lies inside the intersection of ellipsoids in
%       fstEllArr. Ellipsoids in fstEllArr and secEllArr must be
%       of the same dimension. mode = 'u' (default) - union of
%       ellipsoids in secEllArr. mode = 'i' - intersection.
%   res = ISINSIDE(fstEllArr, secPolyArr, mode) Checks if the union
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
%   by the standard routine of MPT. If the vertices of this polytope
%   belong to the intersection of ellipsoids, then the polytope itself
%   belongs to this intersection.
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
import modgen.common.throwerror;
import modgen.common.checkmultvar;

ellipsoid.checkIsMe(fstEllArr,'first');
modgen.common.checkvar(secObjArr,@(x) isa(x, 'ellipsoid') ||...
    isa(x, 'hyperplane') || isa(x, 'polytope'),...
    'errorTag','wrongInput', 'errorMessage',...
    'second input argument must be ellipsoid,hyperplane or polytope.');

if (nargin < 3) || ~(ischar(mode))
    mode = 'u';
end

status = [];

if isa(secObjArr, 'polytope')
    if mode == 'i'
        xVec = {extreme(and(secObjArr))};
    else
        [nRows nCols] = size(secObjArr);
        xVec = cell(nRows,nCols);
        for iCols = 1:nCols
            xVec{iCols} = extreme(secObjArr(iCols));
        end;
    end
    if all(cellfun(@(x) isempty(x), xVec))
        res = -1;
    else
        res = min(cellfun(@(x) min(isinternal(fstEllArr, x', 'i')),xVec));
    end
   
    if nargout < 2
        clear status;
    end
   
    return;
end


if mode == 'u'
    res = 1;
    isContain = arrayfun(@(x) all(all(contains(x, secObjArr))), fstEllArr);
    if ~all( isContain(:) )
        res=0;
        return;
    end
elseif isscalar(secObjArr)
    res = 1;
    if ~all(all(contains(fstEllArr, secObjArr)))
        res = 0;
    end
else
    nFstEllDimsMat = dimension(fstEllArr);
    nSecEllDimsMat = dimension(secObjArr);
    checkmultvar('(x1(1)==x2(1))&&all(x1(:)==x1(1))&&all(x2(:)==x2(1))',...
        2,nFstEllDimsMat,nSecEllDimsMat,...
        'errorTag','wrongSizes',...
        'errorMessage','input arguments must be of the same dimension.');
    if Properties.getIsVerbose()
        fprintf('Invoking CVX...\n');
    end
    res = 1;
    resMat  =arrayfun (@(x) qcqp(secObjArr,x), fstEllArr);
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

absTolScal = getAbsTol(secObj);
[qVec, paramMat] = parameters(secObj);
if size(paramMat, 2) > rank(paramMat)
    if Properties.getIsVerbose()
        fprintf('QCQP: Warning! Degenerate ellipsoid.\n');
        fprintf('      Regularizing...\n');
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
        [qVec, invQMat] = parameters(fstEllArr(iCount));
        if isdegenerate(fstEllArr(iCount))
            invQMat = ...
                ellipsoid.regularize(invQMat,getAbsTol(fstEllArr(iCount)));
        end
        invQMat = ell_inv(invQMat);
        invQMat = 0.5*(invQMat + invQMat');
        xVec'*invQMat*xVec + 2*(-invQMat*qVec)'*xVec + ...
            (qVec'*invQMat*qVec - 1) <= 0;
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

if (xVec'*invQMat*xVec + 2*(-invQMat*qVec)'*xVec + ...
        (qVec'*invQMat*qVec - 1)) < min(getAbsTol(fstEllArr(:)))
    res = 1;
else
    res = 0;
end

end

