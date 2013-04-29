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

  r = rank(Q);

  if r < n
    if ~gras.la.ismatsymm(Q)
      R = Q  +  delta * eye(n);
    else
      [uMat, ~] = eig(Q);
      R = Q + delta * (uMat * uMat');
    end
  else
    R       = Q;
  end

  return;
