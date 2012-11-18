function M = mineig(E)
%
% MINEIG - return the minimal eigenvalue of the ellipsoid.
%
%
% Description:
% ------------
%
%    M = MINEIG(E)  Returns the smallest eigenvalues of ellipsoids in the array E.
%
%
% Output:
% -------
%
%    M - array of minimal eigenvalues of ellipsoids in the input array E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISDEGENERATE, MAXEIG.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
  import modgen.common.throwerror;
  import elltool.conf.Properties;

  if ~(isa(E, 'ellipsoid'))
    error('MINEIG: input argument must be ellipsoid.')
  end

  [m, n] = size(E);
  M = zeros(m,n);
  for i = 1:m
    for j = 1:n
      if isempty(E(i,j))
          throwerror('wrongInput:emptyEllipsoid','MINEIG: input argument is empty.');
      end
      if isdegenerate(E(i, j))
        M(i,j)=0;
      else
        M(i,j) = min(eig(E(i, j).shape));
      end
    end
  end

end
