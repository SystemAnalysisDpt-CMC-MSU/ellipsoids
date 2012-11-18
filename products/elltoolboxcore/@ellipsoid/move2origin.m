function EO = move2origin(E)
%
% MOVE2ORIGIN - moves ellipsoids in the given array to the origin.
%
%
% Description:
% ------------
%
%    EO = MOVE2ORIGIN(E)  Replaces the centers of ellipsoids in E with zero vectors.
%
%
% Output:
% -------
%
%    EO - array of ellipsoids with the same shapes as in E centered at the origin.
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
    error('MOVE2ORIGIN: argument must be array of ellipsoids.');
  end

  EO     = E;
  [m, n] = size(EO);

  for i = 1:m
    for j = 1:n
      d               = dimension(EO(i, j));
      EO(i, j).center = zeros(d, 1);
    end
  end

end
