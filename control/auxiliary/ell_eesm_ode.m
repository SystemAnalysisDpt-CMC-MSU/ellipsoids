function dXdt = ell_eesm_ode(t, X, l0, mydata, n, back)
%
% ELL_EESM_ODE - ODE for the shape matrix of the external ellipsoid.
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

  A   = ell_value_extract(mydata.A, t, [n n]);
  BPB = ell_value_extract(mydata.BPB, t, [n n]);
  X   = reshape(X, n, n);

  p1 = sqrt(l0' * F * BPB * F' * l0);
  p2 = sqrt(l0' * F * X * F' * l0);

  if abs(p1) < ellOptions.abs_tol
    p1 = ellOptions.abs_tol;
  end
  if abs(p2) < ellOptions.abs_tol
    p2 = ellOptions.abs_tol;
  end

  pp1 = p1/p2;
  pp2 = p2/p1;
  
  AX = A*X;
  dXdt = s*AX + s*AX' + pp1*X + pp2*BPB;
  dXdt = reshape(0.5*(dXdt + dXdt'), n*n, 1);

  return;
