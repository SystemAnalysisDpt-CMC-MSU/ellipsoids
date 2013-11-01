function E = ell_enclose(V)
%
% ELL_ENCLOSE - computes minimum volume ellipsoid that
%               contains given vectors.
%
%
% Description:
% ------------
%
%    E = ELL_ENCLOSE(V)  Given vectors specified as columns
%                 of matrix V, compute minimum  volume 
%                 ellipsoid E that contains them.
%
%
% Output:
% -------
%
%    E - computed ellipsoid.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ISINTERNAL, ELLUNION_EA;
%    POLYTOPE/getOutterEllipsoid.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Vadim Kaushanskiy <vkaushanskiy@gmail.com>

import modgen.common.throwerror
import elltool.conf.Properties;
import elltool.logging.Log4jConfigurator;

persistent logger;

if nargin < 1
  E = ellipsoid;
  return;
end

[m, n] = size(V);

if Properties.getIsVerbose()
  if isempty(logger)
    logger=Log4jConfigurator.getLogger();
  end
  logger.info('Invoking CVX...');
end


cvx_begin sdp
    variable cvxEllMat(m,m) symmetric
    variable cvxEllCenterVec(m)
    
    maximize( det_rootn( cvxEllMat ) )
    subject to
        cvxEllMat >= 0
        for i = 1:n
            norm(cvxEllMat*V(:, i)+cvxEllCenterVec)<=1
        end
cvx_end

if strcmp(cvx_status,'Infeasible') || strcmp(cvx_status,'Inaccurate/Infeasible') || strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx cannot solve the system');
end;

sqrtEllMat = cvxEllMat;
ellCenterVec = cvxEllCenterVec;

ellMat  = ell_inv(sqrtEllMat' * sqrtEllMat);
ellMat  = 0.5 * (ellMat' + ellMat);
ellCenterVec  = -inv(sqrtEllMat) * ellCenterVec;

E  = ellipsoid(ellCenterVec, ellMat);

end