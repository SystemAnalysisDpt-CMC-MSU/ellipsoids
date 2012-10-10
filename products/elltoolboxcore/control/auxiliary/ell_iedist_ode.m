function dXdt = ell_iesm_ode(t, X, l0, mydata, n, back)
%
% ELL_IEDIST_ODE - ODE for the shape matrix of the internal ellipsoid
%                  for system with disturbance.
%

  global ellOptions;

  if back > 0
    t = -t;
    F = ell_value_extract(mydata.Phi, t, [n n]);
    s = -1;
  else
    F = ell_value_extract(mydata.Phinv, t, [n n]);	  
    s = 1;
  end

  I     = eye(n);
  A     = ell_value_extract(mydata.A, t, [n n]);
  BPBsr = ell_value_extract(mydata.BPBsr, t, [n n]);
  GQG   = ell_value_extract(mydata.GQG, t, [n n]);
  %GQGsr = ell_value_extract(mydata.GQGsr, t, [n n]);
  X     = reshape(X, n, n);
  Y     = sqrtm(X);
  Y     = 0.5*(Y + Y);
  mu    = 0;
  p1    = sqrt(l0' * F * GQG * F' * l0);
  p2    = sqrt(l0' * F * X * F' * l0);

  if abs(p1) < ellOptions.abs_tol
    p1 = ellOptions.abs_tol;
  end
  if abs(p2) < ellOptions.abs_tol
    p2 = ellOptions.abs_tol;
  end

  pp1 = p1/p2;
  pp2 = p2/p1;
  l1  = Y * F' * l0;
  l2  = BPBsr * F' * l0;
  %l3  = F' * l0;

  if (norm(l1) < ellOptions.abs_tol) | (norm(l2) < ellOptions.abs_tol)
    S1 = I;
  else
    S1 = ell_valign(l1, l2);
  end
  %if (norm(l1) < ellOptions.abs_tol) | (norm(l3) < ellOptions.abs_tol)
  %  S2 = I;
  %else
  %  S2 = ell_valign(l1, l3);
  %end

  Z    = Y * S1 * BPBsr;
  %W    = Y * S2;
  %dXdt = A*X + X*A' + Z + Z' + mu*(W + W') - pp1*X - pp2*GQG;
  dXdt = s*A*X + s*X*A' + Z + Z' - pp1*X - pp2*GQG;
  dXdt = 0.5*(dXdt + dXdt');

  %mn   = min(eig(dXdt));
  %if (min(eig(X)) < ellOptions.abs_tol) & (mn < 0)
  %  mn   = abs(mn);
  %  ee   = min(svd(W + W'));
  %  nu   = (mn + ellOptions.abs_tol)/ee;
  %  mu   = mu + nu;
  %  dXdt = dXdt + nu*(W + W');
  %end
  
  dXdt = reshape(dXdt, n*n, 1);

  return;
