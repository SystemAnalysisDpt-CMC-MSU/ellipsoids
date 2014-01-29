function res = ell_value_extract(X, t, dims)
%
% ELL_VALUE_EXTRACT - extracts matrix value from ppform or 
%                     vector array.
%

  if isstruct(X)
    res = reshape(ppval(X, t), dims(1), dims(2));
  else
    [m, n] = size(X);
    if (dims(1) == m) & (dims(2) == n)
      res = X;
    else
      res = reshape(X(:, t), dims(1), dims(2));
    end
  end

  return;
