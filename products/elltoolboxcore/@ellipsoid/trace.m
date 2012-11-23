function T = trace(E)
%
% TRACE - returns the trace of the ellipsoid.
%
%
% Description:
% ------------
%
%    T = TRACE(E)  Computes the trace of ellipsoids in ellipsoidal array E.
%
%
% Output:
% -------
%
%    T - array of trace values, same size as E.
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
  
  if ~(isa(E, 'ellipsoid'))
    error('TRACE: input argument must be ellipsoid.')
  end
  
  [m, n] = size(E);
  T      = zeros(m, n);

  for i = 1:m
    for j = 1:n
      if isempty(E(i,j))
          throwerror('wrongInput:emptyEllipsoid','TRACE: input argument is empty.');
      end
      T(i, j) = trace(double(E(i, j)));
    end
  end

end
