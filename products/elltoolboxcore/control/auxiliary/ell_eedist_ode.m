function dXdt = ell_eesm_ode(t, X, l0, mydata, n, back)
%
% ELL_EEDIST_ODE - ODE for the shape matrix of the external ellipsoid
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
  BPB   = ell_value_extract(mydata.BPB, t, [n n]);
  GQG   = ell_value_extract(mydata.GQG, t, [n n]);
  GQGsr = ell_value_extract(mydata.GQGsr, t, [n n]);
  X     = reshape(X, n, n);
  Y     = sqrtm(X);
  Y     = 0.5*(Y + Y);
  mu    = 0;
  p1    = sqrt(l0' * F * BPB * F' * l0);
  p2    = sqrt(l0' * F * X * F' * l0);

  if abs(p1) < ellOptions.abs_tol
    p1 = ellOptions.abs_tol;
  end
  if abs(p2) < ellOptions.abs_tol
    p2 = ellOptions.abs_tol;
  end

  pp1 = p1/p2;
  pp2 = p2/p1;

  %g1  = mu * sqrt(l0' * F * F' * l0);
  %g2  = sqrt(l0' * F * GQG * F' * l0);

  %if abs(g2) < ellOptions.abs_tol
  %  g2 = ellOptions.abs_tol;
  %end

  %gg1 = g1/g2;

  %if mu == 0
  %  gg2 = 0;
  %elseif abs(g1) < ellOptions.abs_tol
  %  g1  = ellOptions.abs_tol;
  %  gg2 = mu * mu * (g2/g1);
  %else
  %  gg2 = mu * mu * (g2/g1);
  %end
  
  abs_tol_solver = ellOptions.abs_tol;

  l1 = Y * F' * l0;
  l2 = GQGsr * F' * l0;
  if (norm(l1) < abs_tol_solver) | (norm(l2) < abs_tol_solver) %
    S = I;
  else
    S = ell_valign(l1, l2);
  end

  Z    = Y * S * GQGsr;
  %dXdt = A*X + X*A' + (pp1 + gg1)*X + pp2*BPB + gg2*I - Z - Z';
  dXdt = s*A*X + s*X*A' + pp1*X + pp2*BPB - Z - Z';
  dXdt = 0.5*(dXdt + dXdt');
  %mn   = min(eig(dXdt));

  %if mn < 0
  %  mn = abs(mn);
  %  g1 = sqrt(l0' * F * F' * l0);
  %  if abs(g1) < ellOptions.abs_tol
  %    g1 = ellOptions.abs_tol;
  %  end
  %  gg   = g2/g1;
  %  ee   = min(svd(X));
  %  nu   = (mn + ellOptions.abs_tol)/(gg + ee);
  %  mu   = mu + nu;
  %  dXdt = dXdt + nu*X + nu*gg*I;
  %  dXdt = 0.5*(dXdt + dXdt');
  %end
  
  dXdt = reshape(dXdt, n*n, 1);

  return;
