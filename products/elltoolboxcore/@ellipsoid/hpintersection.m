function I = hpintersection(E, H)
%
% HPINTERSECTION - computes the intersection of ellipsoid with hyperplane.
%
%
% Description:
% ------------
%
%    I = HPINTERSECTION(E, H)  Given array of ellipsoids E and array of hyperplane
%                              structures H of the same size, or, alternatively,
%                              E can be single ellipsoid or H - single hyperplane,
%                              compute intersections of ellipsoids with
%                              hyperplanes pairwise.
%
%
% Output:
% -------
%
%    I - array of ellipsoids resulting from intersections.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, DISTANCE, INTERSECT, HYPERPLANE/HYPERPLANE.
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

  if ~(isa(E, 'ellipsoid')) | ~(isa(H, 'hyperplane'))
    error('HPINTERSECTION: first argument must be ellipsoid, second argument - hyperplane.');
  end 

  [m, n] = size(E);
  [k, l] = size(H);
  t1     = m * n;
  t2     = k * l;
  if (t1 > 1) & (t2 > 1) & ((m ~= k) | (n ~= l))
    error('HPINTERSECTION: sizes of ellipsoidal and hyperplane arrays do not match.');
  end

  dims1 = dimension(E);
  dims2 = dimension(H);
  mn1   = min(min(dims1));
  mn2   = min(min(dims2));
  mx1   = max(max(dims1));
  mx2   = max(max(dims2));
  if (mn1 ~= mx1)
    error('HPINTERSECTION: ellipsoids must be of the same dimension.');
  end
  if (mn2 ~= mx2)
    error('HPINTERSECTION: hyperplanes must be of the same dimension.');
  end

  if ellOptions.verbose > 0
    if (t1 > 1) | (t2 > 1)
      fprintf('Computing %d ellipsoid-hyperplane intersections...\n', max([t1 t2]));
    else
      fprintf('Computing ellipsoid-hyperplane intersection...\n');
    end
  end

  I = [];
  if (t1 > 1) & (t2 > 1)
    for i = 1:m
      Q = [];
      for j = 1:n
        if distance(E(i, j), H(i, j)) > 0
          Q = [Q ellipsoid];
	else
          Q = [Q l_compute1intersection(E(i, j), H(i, j), mx1)];
	end
      end
      I = [I; Q];
    end
  elseif (t1 > 1)
    for i = 1:m
      Q = [];
      for j = 1:n
        if distance(E(i, j), H) > 0
          Q = [Q ellipsoid];
	else
          Q = [Q l_compute1intersection(E(i, j), H, mx1)];
	end
      end
      I = [I; Q];
    end
  else
    for i = 1:k
      Q = [];
      for j = 1:l
        if distance(E, H(i, j)) > 0
          Q = [Q ellipsoid];
	else
          Q = [Q l_compute1intersection(E, H(i, j), mx1)];
	end
      end
      I = [I; Q];
    end
  end

  return;





%%%%%%%%

function I = l_compute1intersection(E, H, n)
%
% L_COMPUTE1INTERSECTION - computes intersection of single ellipsoid with
%                          single hyperplane.
%

  global ellOptions;

  [v, c] = parameters(H);
  if c < 0
    v = - v;
    c = - c;
  end
  T = ell_valign([1; zeros(n-1, 1)], v);
  f = (c*T*v)/(v'*v);
  E = T*E - f;
  q = E.center;
  Q = E.shape;

  if rank(Q) < n
    if ellOptions.verbose > 0
      fprintf('HPINTERSECTION: Warning! Degenerate ellipsoid.\n');
      fprintf('                Regularizing...\n');
    end
    Q = regularize(Q);
  end

  W   = ell_inv(Q);
  W   = 0.5*(W + W');
  w   = W(2:n, 1);
  w11 = W(1, 1);
  W   = ell_inv(W(2:n, 2:n));
  W   = 0.5*(W + W');
  h   = (q(1, 1))^2 * (w11 - w'*W*w);

  z   = q + q(1, 1)*[-1; W*w];
  Z   = (1 - h) * [0 zeros(1, n-1); zeros(n-1, 1) W];
  I   = ellipsoid(z, Z);
  I   = ell_inv(T)*(I + f);

  return;
