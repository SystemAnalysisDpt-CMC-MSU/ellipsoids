function QQ = fix_iesm(Q, d)
%
% FIX_IESM - returns values for (Q' * Q).
%

  n  = size(Q, 2);
  QQ = [];
  
  for i = 1:n
    M  = reshape(Q(:, i), d, d);
    QQ = [QQ reshape(M'*M, d*d, 1)];
  end

  return;
