function R = ell_regularize(Q, delta)
%
% ELL_REGULARIZE - regularization of singular matrix.
%

  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  [m, n] = size(Q);
  if m ~= n
    R = Q;
    return;
  end

  if nargin < 2
    delta = ellOptions.abs_tol;
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
