function I = inv(E)
%
% INV - inverts shape matrices of ellipsoids in the given array.
%
%
% Description:
% ------------
%
%    I = INV(E)  Inverts shape matrices of ellipsoids in the array E.
%                In case shape matrix is sigular, it is ellipsoid.regularized before inversion.
%
%
% Output:
% -------
%
%    I - array of ellipsoids with inverted shape matrices.
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
    error('INV: input argument must be array of ellipsoids.');
  end

  I      = E;
  [m, n] = size(I);

  absTolMat = getAbsTol(I);
  for i = 1:m
    for j = 1:n
      if isdegenerate(I(i, j))
        Q = ellipsoid.regularize(I(i, j).shape,absTolMat(i,j));
      else
        Q = I(i, j).shape;
      end
      Q             = ell_inv(Q);
      I(i, j).shape = 0.5*(Q + Q');
    end
  end

end
