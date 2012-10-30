function [E, S] = ellunion_ea(EE)
%
% ELLUNION_EA - computes minimum volume ellipsoid that contains union
%               of given ellipsoids.
%
%
% Description:
% ------------
%
%    E = ELLUNION_EA(EE)  Among all ellipsoids that contain the union
%                         of ellipsoids in the ellipsoidal array EE,
%                         find the one that has minimal volume.
%
%
%     We use YALMIP as interface to the optimization tools.
%     (http://control.ee.ethz.ch/~joloef/yalmip.php)
%
%
% Output:
% -------
%
%    E - resulting minimum volume ellipsoid.
%    S - (optional) status variable returned by YALMIP.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ELLINTERSECTION_IA.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Vadim Kaushanskiy <vkaushanskiy@gmail.com>

  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  dims = dimension(EE);
  mn   = min(min(dims));
  mx   = max(max(dims));

  if mn ~= mx
    error('ELLUNION_EA: all ellipsoids must be of the same dimension.');
  end

  [m, n] = size(EE);
  M      = m * n;
  EE     = reshape(EE, 1, M);
  zz     = zeros(mn, mn);

  if ellOptions.verbose > 0
    fprintf('Invoking CVX...\n');
  end
  

cvx_begin sdp
    variable cvxEllMat(mn,mn) symmetric
    variable cvxEllCenterVec(mn)
    variable cvxDirVec(M)
    maximize( det_rootn( cvxEllMat ) )
    subject to
        cvxDirVec >= 0
        for i = 1:M
            [q, Q] = double(EE(i));
            Q = (Q + Q')*0.5;
            if rank(Q) < mn
                Q = regularize(Q);
            end
    
            Q     = ell_inv(Q);
            Q = (Q + Q')*0.5;
            bb    = -Q * q;
            cc    = q' * Q * q - 1;
           
            [ -(cvxEllMat - cvxDirVec(i)*Q), -(cvxEllCenterVec - cvxDirVec(i)*bb), zeros(mn, mn);
              -(cvxEllCenterVec - cvxDirVec(i)*bb)', -(- 1 - cvxDirVec(i)*cc), -cvxEllCenterVec';
               zeros(mn,mn), -cvxEllCenterVec, cvxEllMat] >= 0;
        end
cvx_end
 
  ellMat = inv(cvxEllMat);
  ellMat = 0.5*(ellMat+ellMat.');
  invCvxEllMat = ell_inv(cvxEllMat);
  ellCenterVec = -invCvxEllMat * cvxEllCenterVec;

  E = ellipsoid(ellCenterVec, ellMat);

  if nargout < 2
    clear S;
  end


