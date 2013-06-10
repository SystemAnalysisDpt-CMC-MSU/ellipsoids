function prec = gdtouchvecprec(qMat, touchVec, serCount, varargin)
% GDTOUCHVECOREC calculates precision of <touchVec, Q^{-1} * touchVec> 
% expression for good directions. qMat must be nondegenerate and 
% nonnegatively definite matrix. For good direction the touchVec ~ Q
% * l / <l, Q * l>^{0.5}.
% If the matrix is ill-conditioned then the result of epression will be
% inv(Q) * touchVec = (l + l1) / <l, Q * l>^{0.5}, where l1 is
% error vector. Vector Q * l1 / <l, Q * l>^{0.5} can be found as:
% v1 = Q * l1 / <l, Q * l>^{0.5} ~ Q * inv(Q) * touchVec - touchVec. The 
% first approximation of <touchVec, Q^{-1} * touchVec> will be:
% <touchVec, Q^{-1} * touchVec> = <Q * l, inv(Q) * touchVec> =
% =  <Q * l, l + l1> / <l, Q * l> = 1 + <Q * l, l1> / <l, Q * l> ~
% ~ 1 + <touchVec, inv(Q) * v1>.
%
% But we use inv(Q) and result for (inv(Q) * v1) can be also inaccurate.
% The second approximation can be founded as:
% inv(Q) * v1 = (l1 + l2) / <l, Q * l>^{0.5}. Then we build first
% approximation for v1... The precision is calculated as:
% pres = (abs(<Q * l, l1>) + abs(<Q * l, l2>) + ...) / <l, Q * l> ~
% ~ abs(<touchVec, inv(Q) * v1>) + abs(<touchVec, inv(Q) * v2>) + ...
%
% Input:
%     regular:
%         qMat: double[nDims, nDims] - ellipsoid shape matrix
%         touchVec: double[n, 1] - good dir support point vector
%         serCount: unsigned integer - count of series elements to calculate
%     optional:
%         minTol: double - minimal abs(<touchVec, inv(Q) * vk>) to be
%                 calculated
%         maxTol: double - maximal sum(abs(<touchVec, inv(Q) * vk>)) to be
%                 calculated
%       
%
% Output:
%   prec: double - precision not greater than maxTol (is defined)
%
%
%
% $Authors: Yuri Admiralsky  <swige.ide@gmail.com> $	$Date: 2013-06-10$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
prec = 0;
if nargin > 3
    minTol = varargin{1};
else
    minTol = -Inf;
end
if nargin > 4
    maxTol = varargin{2};
else
    maxTol = Inf;
end
%
curVec = touchVec;
for iSeries = 1:serCount
    invErrVec = qMat * (qMat \ curVec) - curVec;
    addInvPrecision = abs(dot(touchVec, qMat \ invErrVec));
    prec = prec + addInvPrecision;
    curVec = invErrVec;
    if addInvPrecision < minTol
        break;
    end
    if prec > maxTol
        prec = maxTol;
        break;
    end
end
end
