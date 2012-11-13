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
  import modgen.common.throwerror;
  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  if ~(isa(E, 'ellipsoid'))
    error('VOLUME: input argument must be ellipsoid.');
  end

  [m, n] = size(E);
  V=zeros(m,n);
  for i = 1:m
    for j = 1:n
      if isempty(E(i,j))
          throwerror('wrongInput:emptyEllipsoid','VOLUME: input argument is empty.');
      end
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
      V(i,j)= S*sqrt(det(Q));
    end
  end

  return;
