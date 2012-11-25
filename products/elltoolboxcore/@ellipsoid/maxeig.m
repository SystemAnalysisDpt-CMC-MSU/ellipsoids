function M = maxeig(E)
%
% MAXEIG - return the maximal eigenvalue of the ellipsoid.
%
%
% Description:
% ------------
%
%    M = MAXEIG(E)  Returns the largest eigenvalues of ellipsoids in the array E.
%
%
% Output:
% -------
%
%    M - array of maximal eigenvalues of ellipsoids in the input array E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISDEGENERATE, MINEIG.
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
    error('MAXEIG: input argument must be ellipsoid.')
  end

  [m, n] = size(E);
  M      = zeros(m,n);
  for i = 1:m
    for j = 1:n
      if isempty(E(i,j))
          throwerror('wrongInput:emptyEllipsoid','MAXEIG: input argument is empty.');
      end  
      M(i,j) = max(eig(E(i, j).shape));
    end
  end

end
