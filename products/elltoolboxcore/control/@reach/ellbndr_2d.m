function x = ellbndr_2d(E, N)
%
% ELLBNDR_2D - compute the boundary of 2D ellipsoid.
%

  import elltool.conf.Properties;

  if nargin < 2
    N = getNPlot2dPoints(E);
  end
  
  phi    = linspace(0, 2*pi, N);
  l      = [cos(phi); sin(phi)];
  [r, x] = rho(E, l);

  return;
