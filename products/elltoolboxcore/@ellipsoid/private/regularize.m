function R = regularize(Q,absTol)
%
% REGULARIZE - regularization of singular symmetric matrix.
%

  import elltool.conf.Properties;

  if Q ~= Q'
    error('REGULARIZE: matrix must be symmetric.');
  end

  [m, n] = size(Q);
  r      = rank(Q);

  if r < n
    [U S V] = svd(Q);
    E       = absTol * eye(n - r);
    R       = Q + (U * [zeros(r, r) zeros(r, (n-r)); zeros((n-r), r) E] * U');
    R       = 0.5*(R + R');
  else
    R = Q;
  end

  return;
