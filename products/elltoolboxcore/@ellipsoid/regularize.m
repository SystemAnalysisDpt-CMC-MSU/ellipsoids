function regQMat = regularize(qMat,absTol)
%
% REGULARIZE - regularization of singular symmetric matrix.
%
  import gras.la.ismatsymm;  
 
  if ~ismatsymm(qMat)
    error('REGULARIZE: matrix must be symmetric.');
  end

  [~, n] = size(qMat);
  r      = rank(qMat);

  if r < n
    [U, ~, ~] = svd(qMat);
    E       = absTol * eye(n - r);
    regQMat       = qMat + (U * [zeros(r, r) zeros(r, (n-r)); zeros((n-r), r) E] * U');
    regQMat       = 0.5*(regQMat + regQMat');
  else
    regQMat = qMat;
  end
