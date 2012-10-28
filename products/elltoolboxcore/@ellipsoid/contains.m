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
%

  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    error('CONTAINS: input arguments must be ellipsoids.');
  end

  [m, n] = size(E1);
  [k, l] = size(E2);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('CONTAINS: sizes of ellipsoidal arrays do not match.');
  end

  dims1 = dimension(E1);
  dims2 = dimension(E2);
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1) | (mn2 ~= mx2) | (mn1 ~= mn2)
    error('CONTAINS: ellipsoids must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Checking %d ellipsoid-in-ellipsoid containments...\n', max([t1 t2]));
    else
      fprintf('Checking ellipsoid-in-ellipsoid containment...\n');
    end
  end

  res = [];
  if (t1 > 1) & (t2 > 1)
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

  return;





%%%%%%%%

function res = l_check_containment(E1, E2)
%
% L_CHECK_CONTAINMENT - check if E2 is inside E1.
%

  global ellOptions;

  [q, Q] = double(E1);
  [r, R] = double(E2);
  
  Qi     = ell_inv(Q);
  Ri     = ell_inv(R);

  A      = [Qi -Qi*q; (-Qi*q)' (q'*Qi*q-1)];
  B      = [Ri -Ri*r; (-Ri*r)' (r'*Ri*r-1)];

  if ellOptions.verbose > 0
    fprintf('Invoking YALMIP...\n');
  end

  x      = sdpvar(1, 1);
  f      = 1;
  C      = set('A <= x*B');
  C      = C + set('x >= 0');
  ellOptions.sdpsettings = sdpsettings('solver','sdpt3');
  s      = solvesdp(C, f, ellOptions.sdpsettings);
  if s.problem == 0
    res = 1;
  else
    res = 0;
  end

  return;
