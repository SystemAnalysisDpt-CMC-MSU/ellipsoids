function prec = elldistprec(qMat, tchVec, nCount, varargin)
% ELLDISTPREC - calculates the precision of distance function between
% ellipsoid and vector.
%
% The distance function between ellipsoid and vector:
%
%   f(x | E(q, Q)) = abs(<x - q, Q^{-1} * (x - q)> - 1)
%
% We assume that q = 0. In MATLAB the function f(x, E) can be calculated
% as:
%
%   f(x | E(0, Q)) = abs(<x, inv(Q) * x> - 1);    <inv>
%   f(x | E(0, Q)) = abs(<x, Q \ x> - 1);         <mdivide>
%
% If the matrix Q is ill-conditioned, then (inv(Q) * x) may be not
% precise.  The result of multiplication may be presented as:
%
%   inv(Q) * x = Q^{-1} x + x1,
%
% where x1 is error vector. The function may be presented as:
%
%   f(x | E(0, Q)) = abs(<x, Q^{-1} * x> + <x, Q * Q^{-1} * x1> - 1);
% 
% To find the precision we calculate the first order approximation:
%
%   f(x | E(0, Q)) = abs(<x, Q^{-1} * x> + <x, inv(Q) * Q * x1> - 1);
%
% The error will be ~ abs(<x, inv(Q) * Q * x1>). For convinience we define:
%
%   v1 = Q * x1 = Q *(inv(Q) * x) - x;
%
% So the first order approximation  can be presented as 
% abs(<x, inv(Q) * v1). To find the second order approximation we assume
% that:
%
%   inv(Q) * v1 = inv(Q) * Q * x1 = x1 + x2,
%
% where x2 is error vector for inv(Q) * v1. Then we processing this
% expression as we did it for inv(Q) * x and get the second order
% approximation for error:
%
%   abs(<x, inv(Q) * v1>) + abs(<x, inv(Q) * v2>)
%
% Finally we get the whole precision estimation:
%
%   f(x | E(0, Q)) = abs(<x, Q^{-1} * x> - 1) +- 
%               +- (abs(<x, inv(Q) * v1>) + abs(<x, inv(Q) * v2>) + ...)
%
% We calculate first N elements of error series. We also can calculate
% until:
%   abs(<x, inv(Q) * vk>) < minTol,
% or
%   (abs(<x, inv(Q) * v1>) + ... + abs(<x, inv(Q) * vk>)) > maxTol,
%
% where k <= N.
% 
% Input:
%     regular:
%         qMat: double[nDims, nDims] - ellipsoid shape matrix Q.
%
%         tchVec: double[n, 1] - good dir support point vector x.
%
%         nCount: double[1, 1] - positive integer - count (N) of error 
%                                series elements to calculate.
%
%     optional:
%         minTol: double[1, 1] - minimal series element value to be 
%                                calculated.
%
%         maxTol: double[1, 1] - maximal series sum value to be calculated.
%       
%
% Output:
%         prec: double[1, 1] - f(x, E(0, Q)) precision.
%
%
% Example:
%
%         gras.la.elldistprec(eye(2), [1;1], 1)
%
%         gras.la.elldistprec(eye(4), [1;0;0;0], 3, 1e-6)
%
%         gras.la.elldistprec(eye(3), [0;1;0], 5, [], 1e-3)
%
%
% $Authors: Yuri Admiralsky  <swige.ide@gmail.com> $	$Date: 2013-06-10$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
import modgen.common.checkvar;
import modgen.common.checkmultvar;
%
INTEGER_TOL = 1e-10;
%
checkvar(qMat, '(size(x,1)==size(x,2))&&(size(x,1)>1)&&ismatrix(x)', ...
    'errorTag', 'wrongInput:nonSquareqMat', 'ErrorMessage', ...
    'qMat expected to be a square matrix.');
%
checkvar(tchVec, '(size(x,2)==1)&&isvector(x)', 'errorTag', ...
    'wrongInput:nonVector', 'ErrorMessage', ...
    'tchVec is expected to be a vector.');
checkmultvar('size(x1,2)==size(x2,1)', 2, qMat, tchVec, 'errorTag', ...
    'wrongInput:notConsistent', 'ErrorMessage', ...
    'qMat and tchVec are not consistent.');
%
checkmultvar(['isscalar(x1)&&isnumeric(x1)&&(x1>0)&&', ...
    '(abs(round(x1)-x1)<x2)'], 2, nCount, INTEGER_TOL, 'errorTag', ...
    'wrongInput:wrongCount', 'ErrorMessage', ...
    'nCount is expected to be a positive integer.');
%
minTol = -Inf;
maxTol = Inf;
if nargin > 3
    checkTol(varargin{1}, 'minTol', 0, '0');
    if ~isempty(varargin{1})
        minTol = varargin{1};
    end
end
if nargin > 4
    checkGrList = {'0', 'minTol'};
    [maxVal, maxInd] = max([0, minTol]);
    checkTol(varargin{2}, 'maxTol', maxVal, checkGrList{maxInd});
    if ~isempty(varargin{2})
        maxTol = varargin{2};
    end
end
%
prec = 0;
curVec = tchVec;
for iSeries = 1:nCount
    invErrVec = qMat * (qMat \ curVec) - curVec;
    addInvPrecision = abs(dot(tchVec, qMat \ invErrVec));
    prec = prec + addInvPrecision;
    curVec = invErrVec;
    if (addInvPrecision < minTol) || (prec > maxTol)
        break;
    end
end

function checkTol(tol, tolStr, checkGreater, checkGreaterStr)
    import modgen.common.checkvar;
    import modgen.common.checkmultvar;
    %
    errTag = horzcat('wrongInput:wrong', tolStr);
    errMsg = horzcat(tolStr, [' is expected to be a positive scalar', ...
        ' or empty matrix.']);
    errMsg2 = horzcat(tolStr, ' is expected to be greater than ', ...
        checkGreaterStr, '.');
    checkvar(tol, '(isscalar(x)&&isnumeric(x))||isempty(x)', ...
        'ErrorTag', errTag, 'ErrorMessage', errMsg);
    if ~isempty(tol)
        checkmultvar('(x1>x2)', 2, tol, checkGreater, 'ErrorTag', errTag, ...
            'ErrorMessage', errMsg2);
    end
end
end