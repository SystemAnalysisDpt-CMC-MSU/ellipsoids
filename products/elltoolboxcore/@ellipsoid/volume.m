function V = volume(E)
%
% VOLUME - returns the volume of the ellipsoid.
%
%
% Description:
% ------------
%
%    V = VOLUME(E)  Computes the volume of ellipsoids in ellipsoidal array E.
%
%    The volume of ellipsoid E(q, Q) with center q and shape matrix Q is given by
%                  V = S sqrt(det(Q))
%    where S is the volume of unit ball.
%
%
% Output:
% -------
%
%    V - array of volume values, same size as E.
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

  import elltool.conf.Properties;

  if ~(isa(E, 'ellipsoid'))
    error('VOLUME: input argument must be ellipsoid.');
  end

  [m, n] = size(E);
  V      = [];
  for i = 1:m
    v = [];
    for j = 1:n
      Q = E(i, j).shape;
      if isdegenerate(E(i, j))
        S = 0;
      else
        N = size(Q, 1) - 1;
        if mod(N, 2) > 0
          k = (N + 1)/2;
          S = (pi^k)/factorial(k);
        else
          k = N/2;
          S = ((2^(2*k + 1))*(pi^k)*factorial(k))/factorial(2*k + 1);
        end
      end
      v = [v S*sqrt(det(Q))];
    end
    V = [V; v];
  end

  return;
