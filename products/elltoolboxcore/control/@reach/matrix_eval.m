function M = matrix_eval(X, t)
%
% MATRIX_EVAL - evaluates symbolic matrix at given time instant.
%

  if ~(iscell(X))
    M = X;
    return;
  end

  k      = t;
  [m, n] = size(X);
  M      = zeros(m, n);
  for i = 1:m
    for j = 1:n
      M(i, j) = eval(X{i, j});
    end
  end

  return;
