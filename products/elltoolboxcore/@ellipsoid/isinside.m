function [res, status] = isinside(fstEllMat, secObjMat, mode)
%
% ISINSIDE - checks if the intersection of ellipsoids contains the
%            union or intersection of given ellipsoids or polytopes.
%
%   res = ISINSIDE(fstEllMat, secEllMat, mode) Checks if the union
%       (mode = 'u') or intersection (mode = 'i') of ellipsoids in
%       secEllMat lies inside the intersection of ellipsoids in
%       fstEllMat. Ellipsoids in fstEllMat and secEllMat must be
%       of the same dimension. mode = 'u' (default) - union of
%       ellipsoids in secEllMat. mode = 'i' - intersection.
%   res = ISINSIDE(fstEllMat, secPolyMat, mode) Checks if the union
%       (mode = 'u') or intersection (mode = 'i')  of polytopes in
%       secPolyMat lies inside the intersection of ellipsoids in
%       fstEllMat. Ellipsoids in fstEllMat and polytopes in secPolyMat
%       must be of the same dimension. mode = 'u' (default) - union of
%       polytopes in secPolyMat. mode = 'i' - intersection.
%
%   To check if the union of ellipsoids secEllMat belongs to the
%   intersection of ellipsoids fstEllMat, it is enough to check that
%   every ellipsoid of secEllMat is contained in every
%   ellipsoid of fstEllMat.
%   Checking if the intersection of ellipsoids in secEllMat is inside
%   intersection fstEllMat can be formulated as quadratically
%   constrained quadratic programming (QCQP) problem.
%
%   Let fstEllMat(iEll) = E(q, Q) be an ellipsoid with center q and shape
%   matrix Q. To check if this ellipsoid contains the intersection of
%   ellipsoids in secObjMat:
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
%       fstEllMat: ellipsoid [mRows, mCols] - matrix of ellipsoids
%           of the same size.
%       secEllMat: ellipsoid [mSecRows, nSecCols] / 
%           polytope [mSecRows, nSecCols] - matrix of ellipsoids or
%           polytopes of the same sizes.
%
%           note: if mode == 'i', then fstEllMat, secEllVec should be
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

if ~(isa(fstEllMat, 'ellipsoid'))
    throwerror('wrongInput', ...
        'ISINSIDE: first input argument must be ellipsoid.');
end

if ~(isa(secObjMat, 'ellipsoid')) && ~(isa(secObjMat, 'polytope'))
    fstStr = 'ISINSIDE: second input arguments must be ';
    secStr = 'ellipsoids or polytope.';
    throwerror('wrongInput', [fstStr secStr]);
end

if (nargin < 3) || ~(ischar(mode))
    mode = 'u';
end

status = [];

if isa(secObjMat, 'polytope')
    [~, nCols] = size(secObjMat);
    if mode == 'i'
        poly = secObjMat(1);
        for jCol = 1:nCols
            poly = poly & secObjMat(jCol);
        end
        xVec = extreme(poly);
    else
        xVec = [];
        for jCol = 1:nCols
            xVec = [xVec; extreme(secObjMat(jCol))];
        end
    end
    if isempty(xVec)
        res = -1;
    else
        res = min(isinternal(fstEllMat, xVec', 'i'));
    end
    
    if nargout < 2
        clear status;
    end
    
    return;
end

if mode == 'u'
    [mRows, nCols] = size(fstEllMat);
    res    = 1;
    for iRow = 1:mRows
        for jCol = 1:nCols
            if min(min(contains(fstEllMat(iRow, jCol), secObjMat))) < 1
                res = 0;
                if nargout < 2
                    clear status;
                end
                return;
            end
        end
    end
elseif min(size(secObjMat) == [1 1]) == 1
    res = 1;
    if min(min(contains(fstEllMat, secObjMat))) < 1
        res = 0;
    end
else
    nFstEllDimsMat = dimension(fstEllMat);
    minFstEllDim    = min(min(nFstEllDimsMat));
    maxFsrEllDim    = max(max(nFstEllDimsMat));
    nSecEllDimsMat = dimension(secObjMat);
    minSecEllDim    = min(min(nSecEllDimsMat));
    maxSecEllDim    = max(max(nSecEllDimsMat));
    if (minFstEllDim ~= maxFsrEllDim) || (minSecEllDim ~= maxSecEllDim)...
            || (minSecEllDim ~= minFstEllDim)
        throwerror('wrongSizes', ...
            'ISINSIDE: ellipsoids must be of the same dimension.');
    end
    if Properties.getIsVerbose()
        fprintf('Invoking CVX...\n');
    end
    [mRows, nCols] = size(fstEllMat);
    res    = 1;
    for iRow = 1:mRows
        for jCol = 1:nCols
            [res, status] = qcqp(secObjMat, fstEllMat(iRow, jCol));
            if res < 1
                if nargout < 2
                    clear status;
                end
                return;
            end
        end
    end
end

if nargout < 2
    clear status;
end

end





%%%%%%%%

function [res, status] = qcqp(fstEllMat, secObj)
%
% QCQP - formulate quadratically constrained quadratic programming
%        problem and invoke external solver.
%
% Input:
%   regular:
%       fstEllMat: ellipsod [mEllRows, nEllCols] - matrix of ellipsoids.
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
[qVec, paramMat] = parameters(secObj(1, 1));
if size(paramMat, 2) > rank(paramMat)
    if Properties.getIsVerbose()
        fprintf('QCQP: Warning! Degenerate ellipsoid.\n');
        fprintf('      Regularizing...\n');
    end
    paramMat = ellipsoid.regularize(paramMat,absTolScal(1,1));
end
invQMat = ell_inv(paramMat);
invQMat = 0.5*(invQMat + invQMat');

[mRows, nCols] = size(fstEllMat);

cvx_begin sdp
variable xVec(length(invQMat), 1)

minimize(xVec'*invQMat*xVec + 2*(-invQMat*qVec)'*xVec + ...
    (qVec'*invQMat*qVec - 1))
subject to
for iRow = 1:mRows
    for jCol = 1:nCols
        [qVec, invQMat] = parameters(fstEllMat(iRow, jCol));
        if size(invQMat, 2) > rank(invQMat)
            invQMat = ...
                ellipsoid.regularize(invQMat,absTolScal(iRow,jCol));
        end
        invQMat = ell_inv(invQMat);
        invQMat = 0.5*(invQMat + invQMat');
        xVec'*invQMat*xVec + 2*(-invQMat*qVec)'*xVec + ...
            (qVec'*invQMat*qVec - 1) <= 0;
    end
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
        (qVec'*invQMat*qVec - 1)) < min(getAbsTol(fstEllMat(:)))
    res = 1;
else
    res = 0;
end

end
