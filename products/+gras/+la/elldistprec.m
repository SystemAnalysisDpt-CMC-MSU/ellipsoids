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
%         nCount: positive integer - count (N) of error series elements to
%                   calculate.
%
%     optional:
%         minTol: double - minimal series element value to be calculated.
%
%         maxTol: double - maximal series sum value to be calculated.
%       
%
% Output:
%         prec: double - f(x, E(0, Q)) precision.
%
%
%
% $Authors: Yuri Admiralsky  <swige.ide@gmail.com> $	$Date: 2013-06-10$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
import modgen.common.throwerror;
%
if ~(size(qMat, 1) == size(qMat, 2)) || ~ismatrix(qMat)
    throwerror('wrongInput:nonSquareqMat', ['qMat is expected to be ', ...
        'square matrix']);
end
if (size(tchVec, 2) ~= 1) || ~isvector(tchVec)
    throwerror('wrongInput:nonVector', ['tchVec is expected to be ', ...
        'vector']);
end
if (size(tchVec, 1) ~= size(qMat, 2))
    throwerror('wrongInput:nonConsistent', ['qMat and tchVec are not ', ...
        'consistent']);
end
wrongCountErrMsg = 'nCount is expected to be positive integer';
if ~isscalar(nCount)
    throwerror('wrongInput:wrongCount', wrongCountErrMsg);
end
if (abs(nCount - round(nCount)) > 1e-10) || (nCount < 1)
    throwerror('wrongInput:wrongCount', wrongCountErrMsg);
end
prec = 0;
minTol = -Inf;
maxTol = Inf;
if nargin > 3
    if ~isempty(varargin{1})
        errMsg = ['minTol is expected to be a nonnegative scalar or ', ...
            'empty matrix'];
        if ~isscalar(varargin{1})
            throwerror('wrongInput:wrongMinTol', errMsg);
        end
        if (varargin{1} < 0)
            throwerror('wrongInput:wrongMinTol', errMsg);
        end
        minTol = varargin{1};
    end
end
if nargin > 4
    if ~isempty(varargin{2})
        errMsg = ['maxTol is expected to be a nonnegative scalar or ', ...
            'empty matrix'];
        if ~isscalar(varargin{2})
            throwerror('wrongInput:wrongMinTol', errMsg);
        end
        if (varargin{2} < 0)
            throwerror('wrongInput:wrongMinTol', errMsg);
        end
        if (varargin{2} < minTol)
            throwerror('wrongInput:wrongMaxTol', ['maxTol is expected', ...
                ' not to be lesser than minTol']);
        end
        maxTol = varargin{2};
    end
end
%
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
end
