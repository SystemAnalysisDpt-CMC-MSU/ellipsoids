function I = uminus(E)
%
% Description:
% ------------
%
%    Changes the sign of the center of ellipsoid.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  if ~(isa(E, 'ellipsoid'))
    error('UMINUS: input argument must be array of ellipsoids.');
  end

  I      = E;
  [m, n] = size(I);

  for i = 1:m
    for j = 1:n
      I(i, j).center = - I(i, j).center;
    end
  end

end
