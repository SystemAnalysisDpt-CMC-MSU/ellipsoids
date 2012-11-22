function [q, Q] = double(E)
%
% DOUBLE - returns parameters of the ellipsoid.
%
%
% Description:
% ------------
%
%    [q, Q] = DOUBLE(E)  Extracts the values of the center q and
%                        the shape matrix Q from the ellipsoid object E.
%
%
% Output:
% -------
%
%    q - center of the ellipsoid E.
%    Q - shape matrix of the ellipsoid E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, DIMENSION, ISDEGENERATE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  [m, n] = size(E);
  if (m > 1) || (n > 1)
    error('DOUBLE: the argument of this function must be single ellipsoid.');
  end
  
  if nargout < 2
    q = E.shape;
  else
    q = E.center;
    Q = E.shape;
  end
  
  