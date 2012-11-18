function res = contains(E1, E2)
%
% CONTAINS - checks if one ellipsoid contains the other.
%
%
% Description:
% ------------
%
%    RES = CONTAINS(E1, E2)  Checks if ellipsoid E1 contains ellipsoid E2.
%                            E1 and E2 must be ellipsoidal arrays of the same
%                            size, or, alternatively, E1 or E2 should be a single
%                            ellipsoid.
%
%    The condition for E1 to contain E2 is 
%                min(rho(l | E1) - rho(l | E2)) > 0,
%    subject to
%                <l, l> = 1.
%
%
% Output:
% -------
%
%    1 - E1 contains E2, 0 - otherwise.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISINSIDE, ISINTERNAL, ISBIGGER, RHO.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%    Vadim Kaushanskiy <vkaushanskiy@gmail.com>

  import elltool.conf.Properties;
  
  if ~(isa(E1, 'ellipsoid')) || ~(isa(E2, 'ellipsoid'))
    error('CONTAINS: input arguments must be ellipsoids.');
  end

  [m, n] = size(E1);
  [k, l] = size(E2);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) && (t2 > 1) && ((m ~= k) || (n ~= l))
    error('CONTAINS: sizes of ellipsoidal arrays do not match.');
  end

  dims1 = dimension(E1);
  dims2 = dimension(E2);
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1) || (mn2 ~= mx2) || (mn1 ~= mn2)
    error('CONTAINS: ellipsoids must be of the same dimension.');
  end

  if Properties.getIsVerbose()
    if (t1 > 1) || (t2 > 1)
      fprintf('Checking %d ellipsoid-in-ellipsoid containments...\n', max([t1 t2]));
    else
      fprintf('Checking ellipsoid-in-ellipsoid containment...\n');
    end
  end

  res = [];
  if (t1 > 1) && (t2 > 1)
    for i = 1:m
      r = [];
      for j = 1:n
        r = [r l_check_containment(E1(i, j), E2(i, j))];
      end
      res = [res; r];
    end
  elseif (t1 > 1)
    for i = 1:m
      r = [];
      for j = 1:n
        r = [r l_check_containment(E1(i, j), E2)];
      end
      res = [res; r];
    end
  else
    for i = 1:k
      r = [];
      for j = 1:l
        r = [r l_check_containment(E1, E2(i, j))];
      end
      res = [res; r];
    end
  end

end





%%%%%%%%

function res = l_check_containment(E1, E2)
%
% L_CHECK_CONTAINMENT - check if E2 is inside E1.
%

  import elltool.conf.Properties;
  import modgen.common.throwerror;
  [q, Q] = double(E1);
  [r, R] = double(E2);
  if size(Q, 2) > rank(Q)
      Q = ellipsoid.regularize(Q,E1.absTol);
  end
  if size(R, 2) > rank(R)
      R = ellipsoid.regularize(R,E2.absTol);
  end
  Qi     = ell_inv(Q);
  Ri     = ell_inv(R);
  AMat      = [Qi -Qi*q; (-Qi*q)' (q'*Qi*q-1)];
  BMat      = [Ri -Ri*r; (-Ri*r)' (r'*Ri*r-1)];

  AMat = 0.5*(AMat + AMat');
  BMat = 0.5*(BMat + BMat');
  if Properties.getIsVerbose()
    fprintf('Invoking CVX...\n');
  end
  cvx_begin sdp
    variable cvxxVec(1, 1)
    AMat <= cvxxVec*BMat
    cvxxVec >= 0
  cvx_end

  if strcmp(cvx_status,'Failed')
    throwerror('cvxError','Cvx failed');
  end;
  if strcmp(cvx_status,'Solved') || strcmp(cvx_status, 'Inaccurate/Solved')
    res = 1;
  else
    res = 0;
  end
end