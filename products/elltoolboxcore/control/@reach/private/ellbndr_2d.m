function x = ellbndr_2d(E, N)
%
% ELLBNDR_2D - compute the boundary of 2D ellipsoid.
%

  global ellOptions;

  if nargin < 2
    N = ellOptions.plot2d_grid;
  end
  
  phi    = linspace(0, 2*pi, N);
  l      = [cos(phi); sin(phi)];
  [r, x] = rho(E, l);

  return;
