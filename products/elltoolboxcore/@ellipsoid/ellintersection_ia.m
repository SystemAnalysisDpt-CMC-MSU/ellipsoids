function [E, S] = ellintersection_ia(EE)
%
% ELLINTERSECTION_IA - computes maximum volume ellipsoid that is contained
%                      in the intersection of given ellipsoids.
%
%
% Description:
% ------------
%
%    E = ELLINTERSECTIONIA(EE)  Among all ellipsoids that are contained
%                               in the intersection of ellipsoids in EE,
%                               find the one that has maximal volume.
%
%
%     We use YALMIP as interface to the optimization tools.
%     (http://control.ee.ethz.ch/~joloef/yalmip.php)
%
%
% Output:
% -------
%
%    E - resulting maximum volume ellipsoid.
%    S - (optional) status variable returned by YALMIP.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ELLUNION_EA
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Vadim Kaushanskiy <vkaushanskiy@gmail.com>
  
  import modgen.common.throwerror 
  import elltool.conf.Properties;


  dims = dimension(EE);
  mn   = min(min(dims));
  mx   = max(max(dims));

  if mn ~= mx
    error('ELLINTERSECTION_IA: all ellipsoids must be of the same dimension.');
  end

  [m, n] = size(EE);
  M      = m * n;
  EE     = reshape(EE, 1, M);
  zz     = zeros(mn, 1);
  I      = eye(mn);

  if Properties.getIsVerbose()
    fprintf('Invoking CVX...\n');
  end
absTolVec = getAbsTol(EE);
cvx_begin sdp
    variable cvxEllMat(mn,mn) symmetric
    variable cvxEllCenterVec(mn)
    variable cvxDirVec(M)
  
    maximize( det_rootn( cvxEllMat ) )
    subject to
        -cvxDirVec <= 0;
        for i = 1:M
            [q, Q] = double(EE(i));
            if rank(Q) < mn
                Q = ellipsoid.regularize(Q,absTolVec(i));
            end
            A     = ell_inv(Q);
            b     = -A * q;
            c     = q' * A * q - 1;
            [ (-cvxDirVec(i)-c+b'*Q*b), zeros(mn,1)', (cvxEllCenterVec + Q*b)' ;
              zeros(mn,1), cvxDirVec(i)*eye(mn), cvxEllMat;
              (cvxEllCenterVec + Q*b), cvxEllMat, Q] >= 0;
             
        end
        
cvx_end


  
  if strcmp(cvx_status,'Infeasible') || strcmp(cvx_status,'Inaccurate/Infeasible') || strcmp(cvx_status,'Failed')
      throwerror('cvxError','Cvx cannot solve the system');
  end;
 
  if rank(cvxEllMat) < mn
    cvxEllMat = ellipsoid.regularize(cvxEllMat,min(getAbsTol(EE(:))));
  end

  ellMat = cvxEllMat * cvxEllMat';
  ellMat = 0.5*(ellMat + ellMat');

  E = ellipsoid(cvxEllCenterVec, ellMat);

  if nargout < 2
    clear S;
  end