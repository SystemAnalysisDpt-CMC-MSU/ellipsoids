function x = ellbndr_2d(E)
%
% ELLBNDR_2D - compute the boundary of 2D ellipsoid.
%

  global ellOptions;

  N      = ellOptions.plot2d_grid;
  phi    = linspace(0, 2*pi, N);
  l      = [cos(phi); sin(phi)];
  [~, x] = rho(E, l);
  x      = [x x(:, 1)];

end
