function x = ellbndr_3d(E)
%
% ELLBNDR_3D - compute the boundary of 3D ellipsoid.
%

  global ellOptions;

  M   = ellOptions.plot3d_grid/2;
  N   = M/2;

  psy = linspace(0, pi, N);
  phi = linspace(0, 2*pi, M);

  l = zeros(3,M*(N-2));
  for i = 2:(N - 1)
    arr = cos(psy(i))*ones(1, M);
    l(:,((i-2)*M)+(1:M) )  = [cos(phi)*sin(psy(i)); sin(phi)*sin(psy(i)); arr];
  end

  [~, x] = rho(E, l);

end
