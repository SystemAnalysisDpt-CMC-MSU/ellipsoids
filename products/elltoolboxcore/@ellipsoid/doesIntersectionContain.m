function [res, status] = doesIntersectionContain(fstEllArr, secObjArr,...
    varargin) %#ok<STOUT>
% DOESINTERSECTIONCONTAIN - checks if the intersection of ellipsoids
%                           contains the union or intersection of given
%                           ellipsoids or Polyhedrons.
%
%   res = DOESINTERSECTIONCONTAIN(fstEllArr, secEllArr, mode)
%       Checks if the union
%       (mode = 'u') or intersection (mode = 'i') of ellipsoids in
%       secEllArr lies inside the intersection of ellipsoids in
%       fstEllArr. Ellipsoids in fstEllArr and secEllArr must be
%       of the same dimension. mode = 'u' (default) - union of
%       ellipsoids in secEllArr. mode = 'i' - intersection.
%   res = DOESINTERSECTIONCONTAIN(fstEllArr, secPolyArr, mode)
%        Checks if the union
%       (mode = 'u') or intersection (mode = 'i')  of Polyhedrons in
%       secPolyArr lies inside the intersection of ellipsoids in
%       fstEllArr. Ellipsoids in fstEllArr and Polyhedrons in secPolyArr
%       must be of the same dimension. mode = 'u' (default) - union of
%       Polyhedrons in secPolyMat. mode = 'i' - intersection.
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
%   The intersection of Polyhedrons is a Polyhedron, which is computed
%   by the standard routine of MPT. How checked if intersection of
%   ellipsoids contains Polyhedron is explained in doesContainPoly.
%
%   Checking if the union of Polyhedrons belongs to the intersection
%   of ellipsoids is the same as checking if its convex hull belongs
%   to this intersection.
%
% Input:
%   regular:
%       fstEllArr: ellipsoid [nDims1,nDims2,...,nDimsN] - array of ellipsoids
%           of the same size.
%       secEllArr: ellipsoid /
%           Polyhedron [nDims1,nDims2,...,nDimsN] - array of ellipsoids or
%           Polyhedrons of the same sizes.
%
%           note: if mode == 'i', then fstEllArr, secEllVec should be
%               array.
%
%   properties:
%       mode: char[1, 1] - 'u' or 'i', go to description.
%       computeMode: char[1,] - 'highDimFast' or 'lowDimFast'. Determines,
%           which way function is computed, when secObjArr is Polyhedron. If
%           secObjArr is ellipsoid computeMode is ignored. 'highDimFast'
%           works  faster for  high dimensions, 'lowDimFast' for low. If
%           this property is omitted if dimension of ellipsoids is greater
%           then 10, then 'hightDimFast' is choosen, otherwise -
%           'lowDimFast'
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
% Example:
%   firstEllObj = [0 ; 0] + ellipsoid(eye(2, 2));
%   secEllObj = [0 ; 0] + ellipsoid(2*eye(2, 2));
%   thirdEllObj = [1; 0] + ellipsoid(0.5 * eye(2, 2));
%   secEllObj.doesIntersectionContain([firstEllObj secEllObj], 'i')
%
%   ans =
%
%        1
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
%
checkDoesContainArgs(fstEllArr,secObjArr);
%
if ~isa(secObjArr,'Polyhedron')
    nElem = numel(secObjArr);
    secObjVec  = reshape(secObjArr, 1, nElem);
end
%
[~,modeNameAndVal] = modgen.common.parseparams(varargin,'mode');
if isempty(modeNameAndVal) || ~(ischar(modeNameAndVal{2})) ||...
        ~(strcmp(modeNameAndVal{2},'u') || strcmp(modeNameAndVal{2},'i'))
    mode = 'u';
else
    mode = modeNameAndVal{2};
end
%
if isa(secObjArr,'Polyhedron')
    isAnyEllDeg = any(isdegenerate(fstEllArr(:)));
    if mode == 'i'
        secObjArr_size = size(secObjArr);
        nElems = secObjArr_size(2);
        polyVec = secObjArr(1);
        for iElem = 2:nElems
            polyVec = and(polyVec,secObjArr(iElem));
        end
    else
        polyVec = secObjArr;
    end
    [~, nCols] = size(polyVec);
    isBndVec = false(1,nCols);
    isPolyDegVec = false(1,nCols);
    for iCols = 1:nCols
        isBndVec(iCols) = polyVec(iCols).isBounded();
        isPolyDegVec(iCols) = ~any(polyVec(iCols).isFullDim());
    end;
    isEmpty = polyVec(1).isEmptySet();
    
    if isEmpty
        res = -1;
    elseif ~(all(isBndVec(:))) || (isAnyEllDeg && ~all(isPolyDegVec(:)))
        res = 0;
    else
        isInsideVec = false(1,nCols);
        for iCols = 1:nCols
            isInsideVec(iCols) = doesContainPoly(fstEllArr,...
                polyVec(iCols),varargin);
        end
        res = all(isInsideVec);
    end
    %
    if nargout < 2
        clear status;
    end
else
    if mode == 'u'
        res = 1;
        isContain = arrayfun(@(x) all(all(doesContain(x, secObjVec))), fstEllArr);
        if ~all( isContain(:) )
            res=0;
        end
    elseif isscalar(secObjVec)
        res = 1;
        isContain = arrayfun(@(x) all(all(doesContain(x, secObjVec))), fstEllArr);
        if ~all( isContain(:) )
            res = 0;
        end
    else
        throwerror('notSupportedMode',['ET for now does not support' ...
            'solving non-convex QCQP problems.' ...
            'This functionality will be implemented in the future']);
    end
end
end
%
function [res, status] = qcqp(secEllArr, fstEll) %#ok<DEFNU>
% QCQP - formulate quadratically constrained quadratic programming
%        problem and invoke external solver.
%
% Input:
%   regular:
%       fstEllArr: ellipsod [nDims1,nDims2,...,nDimsN] - array of ellipsoids.
%       secObj: ellipsoid [1, 1] - ellipsoid.
%               or
%               Polyhedron [1, 1] - Polyhedron.
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
import elltool.logging.Log4jConfigurator;
import gras.geom.ell.invmat;
import gras.geom.ell.quadmat;
%
persistent logger;
[~, absTolScal] = getAbsTol(fstEll);
[qVec, qMat] = parameters(fstEll);
if size(qMat, 2) > rank(qMat)
    if Properties.getIsVerbose()
        if isempty(logger)
            logger=Log4jConfigurator.getLogger();
        end
        logger.info('QCQP: Warning! Degenerate ellipsoid.');
        logger.info('      Regularizing...');
    end
    qMat = ellipsoid.regularize(qMat,absTolScal);
end
invQMat = invmat(qMat);
invQMat = 0.5*(invQMat + invQMat');
%
nNumel = numel(secEllArr);
%
cvx_begin sdp
variable xVec(length(invQMat), 1)
%
minimize(xVec'*invQMat*xVec + 2*(-invQMat*qVec)'*xVec + ...
    (qVec'*invQMat*qVec - 1))
subject to
for iCount = 1:nNumel
    [qiVec, invQiMat] = parameters(secEllArr(iCount));
    if isdegenerate(secEllArr(iCount))
        invQiMat = ...
            ellipsoid.regularize(invQiMat,getAbsTol(secEllArr(iCount)));
    end
    invQiMat = invmat(invQiMat);
    invQiMat = 0.5*(invQiMat + invQiMat');
    xVec'*invQiMat*xVec + 2*(-invQiMat*qiVec)'*xVec + ...
        (qiVec'*invQiMat*qiVec - 1) <= 0; %#ok<VUNUS>
end
cvx_end
%
status = 1;
if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
end;
if strcmp(cvx_status,'Infeasible') ...
        || strcmp(cvx_status,'Inaccurate/Infeasible')
    % problem is infeasible, or global minimum cannot be found
    res = -1;
    status = 0;
else
    [~, fstAbsTol] = secEllArr.getAbsTol();
    if (quadmat(invQMat,xVec) + 2*(-invQMat*qVec)'*xVec + ...
            (quadmat(invQMat,qVec) - 1)) < fstAbsTol
        res = 1;
    else
        res = 0;
    end
end
end