function display(E)
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

  fprintf('\n');
  disp([inputname(1) ' =']);

  [m, n] = size(E);
  if (m > 1) || (n > 1)
    fprintf('%dx%d array of ellipsoids.\n\n', m, n);
    return;
  end

  fprintf('\n');
  fprintf('Center:\n'); disp(E.center);
  fprintf('Shape Matrix:\n'); disp(E.shape);

  if isempty(E)
    fprintf('Empty ellipsoid.\n\n');
    return;
  end

  [s, e]    = dimension(E);  
  if e < s
    fprintf('Degenerate (rank %d) ellipsoid in R^%d.\n\n', e, s);
  else
    fprintf('Nondegenerate ellipsoid in R^%d.\n\n', s);
  end
  
end
