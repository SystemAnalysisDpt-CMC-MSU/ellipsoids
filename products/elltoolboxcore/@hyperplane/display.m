function display(H)
%
% Description:
% ------------
%
%    Displays hyperplane object.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  fprintf('\n');
  disp([inputname(1) ' =']);

  [m, n] = size(H);
  if (m > 1) | (n > 1)
    fprintf('%dx%d array of hyperplanes.\n\n', m, n);
    return;
  end

  fprintf('\n');
  fprintf('Normal:\n'); disp(H.normal);
  fprintf('Shift:\n'); disp(H.shift);

  d = dimension(H);  
  if d < 1
    fprintf('Empty hyperplane.\n\n');
  else
    fprintf('Hyperplane in R^%d.\n\n', d);
  end
  
  return;
