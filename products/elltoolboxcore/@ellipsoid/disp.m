function disp(E)
%
% Description:
% ------------
%
%    Displays ellipsoid object.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  fprintf('Ellipsoid with parameters\n');

  [m, n] = size(E);
  if (m > 1) | (n > 1)
    fprintf('%dx%d array of ellipsoids.\n\n', m, n);
    return;
  end

  fprintf('Center:\n'); disp(E.center);
  fprintf('Shape Matrix:\n'); disp(E.shape);

  if isempty(E)
    fprintf('Empty ellipsoid.\n\n');
    return;
  end

  return;
