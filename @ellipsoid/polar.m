function P = polar(E)
%
% POLAR - computes the polar ellipsoids.
%
%
% Description:
% ------------
%
%    P = POLAR(E)  Computes the polar ellipsoids for those ellipsoids in E,
%                  for which the origin is an interior point.
%                  For those ellipsoids in E, for which this condition
%                  does not hold, an empty ellipsoid is returned.
%
%
%    Given ellipsoid E(q, Q) where q is its center, and Q - its shape matrix,
%    the polar set to E(q, Q) is defined as follows:
%
%             P = { l in R^n  | <l, q> + sqrt(<l, Q l>) <= 1 }
%
%    If the origin is an interior point of ellipsoid E(q, Q),
%    then its polar set P is an ellipsoid.
%
%
% Output:
% -------
%
%    P - array of polar ellipsoids.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  if ~(isa(E, 'ellipsoid'))
    error('POLAR: input argument must be array of ellipsoids.');
  end

  [m, n] = size(E);
  P      = [];

  for i = 1:m
    PP = [];
    for j = 1:n
      if isdegenerate(E(i, j))
        PP = [PP ellipsoid];
      else
        [q, Q] = parameters(E(i, j));
        d      = size(Q, 2);
        z      = zeros(d, 1);
        chk    = (z' - q') * ell_inv(Q) * (z - q);
        if chk < 1
          M  = ell_inv(Q - q*q');
          M  = 0.5*(M + M');
          w  = -M * q;
          W  = (1 + q'*M*q)*M;
          PP = [PP ellipsoid(w, W)];
        else
          PP = [PP ellipsoid];
	end
      end
    end
    P = [P; PP];
  end

  return;
