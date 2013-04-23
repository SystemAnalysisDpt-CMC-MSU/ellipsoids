function [sd, dirType] = compute_direction(Z, H, gf, nvars, f)
%
% COMPUTE_DIRECTION - computes a search direction in a 
%                     subspace defined by Z.
%

  Newton       = 1;
  NegCurv      = 2;
  SteepDescent = 3;
  projH        = Z'*H*Z;
  [R, p]       = chol(projH);

  if ~p
    sd      = - Z*(R \ ( R'\(Z'*gf)));
    dirType = Newton;
  else
    [L, sn] = choltr(projH);
    if ~isempty(sn) & (sn'*projH*sn < -realsqrt(eps))
      sd      = Z*sn;
      dirType = NegCurv;
    else
      sd      = - Z*(Z'*gf);
      dirType = SteepDescent;
    end
  end

  if gf'*sd > 0
    sd = -sd;
  end

  return;





%%%%%%%%
function [L, sn] = choltr(A)
%
% CHOLTR - computes Cholesky factor or direction of negative curvature.
%

  sn = [];
  n    = size(A, 1);
  L    = eye(n);
  tol  = 0;

  for k = 1:(n - 1)
    if A(k, k) <= tol
      elem       = zeros(length(A), 1); 
      elem(k, 1) = 1;
      sn         = L'\elem;
    else
      L(k, k) = realsqrt(A(k, k));
      s       = (k + 1):n;
      L(s, k) = A(s, k)/L(k, k);
      for j = (k + 1):n
        A(j:n, j) = A(j:n, j) - L(j:n, k)*L(j, k);
      end
    end
  end

  if A(n, n) <= tol
    elem       = zeros(length(A), 1); 
    elem(n, 1) = 1;
    sn         = L'\elem;
  else
    L(n, n) = realsqrt(A(n, n));
  end

  return;

