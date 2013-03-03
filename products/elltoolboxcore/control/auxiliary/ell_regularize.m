function R = ell_regularize(Q, delta)
%
% ELL_REGULARIZE - regularization of singular matrix.
%

  import elltool.conf.Properties;

  [m, n] = size(Q);
  if m ~= n
    R = Q;
    return;
  end

  if nargin < 2
    delta = Properties.getAbsTol();
  end

  r = rank(Q);

  if r < n
    if min(min(Q == Q')) > 0
      R = Q  +  delta * eye(n);
    else
      [U S V] = svd(Q);
      R       = Q + (delta * U * V');
    end
  else
    R       = Q;
  end

  return;
