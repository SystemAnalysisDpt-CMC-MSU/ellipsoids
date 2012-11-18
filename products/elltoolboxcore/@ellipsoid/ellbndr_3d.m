function x = ellbndr_3d(E)
%
% ELLBNDR_3D - compute the boundary of 3D ellipsoid.
%
  M   = E.nPlot3dPoints/2;
  N   = M/2;

  psy = linspace(0, pi, N);
  phi = linspace(0, 2*pi, M);

  l   = [];
  for i = 2:(N - 1)
    arr = cos(psy(i))*ones(1, M);
    l   = [l [cos(phi)*sin(psy(i)); sin(phi)*sin(psy(i)); arr]];
  end

  [r, x] = rho(E, l);

  return;
