function [y, Y] = minkmp(varargin)
%
% MINKMP - computes and plots geometric (Minkowski) sum of the geometric difference
%          of two ellipsoids and the geometric sum of n ellipsoids in 2D or 3D:
%
%          (E0 - E) + (E1 + E2 + ... + En)
%
%
% Description:
% ------------
%
% MINKMP(E0, E, EE, OPTIONS)  Computes geometric sum of the geometric difference
%                             of two ellipsoids E0 - E and the geometric sum of
%                             ellipsoids in the ellipsoidal array EE, if
%                             1 <= dimension(E0) = dimension(E) = dimension(EE) <= 3,
%                             and plots it if no output arguments are specified.
%
%    [y, Y] = MINKMP(E0, E, EE)  Computes (E0 - E) + (geometric sum of ellipsoids in EE).
%                                Here y is the center, and Y - array of boundary points.
%             MINKMP(E0, E, EE)  Plots (E0 - E) + (geometric sum of ellipsoids in EE)
%                                in default (red) color.
%    MINKMP(E0, E, EE, Options)  Plots (E0 - E) + (geometric sum of ellipsoids in EE)
%                                using options given in the Options structure.
%
% Options.show_all     - if 1, displays also ellipsoids E1 and E2.
% Options.newfigure    - if 1, each plot command will open a new figure window.
% Options.fill         - if 1, the resulting set in 2D will be filled with color.
% Options.color        - sets default colors in the form [x y z].
% Options.shade = 0-1  - level of transparency (0 - transparent, 1 - opaque).
%
%
% Output:
% -------
%
%    y - center of the resulting set.
%    Y - set of boundary points (vertices) of resulting set.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, MINKSUM, MINKDIFF, MINKPM.
%

% 
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if nargin < 3
    error('MINKMP: first, second and third arguments must be ellipsoids.');
  end

  E1 = varargin{1};
  E2 = varargin{2};
  EE = varargin{3};

  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid')) | ~(isa(EE, 'ellipsoid'))
    error('MINKMP: first, second and third arguments must be ellipsoids.');
  end

  [k, l] = size(E1);
  [m, n] = size(E2);
  if (k ~= 1) | (l ~= 1) | (m ~= 1) | (n ~= 1)
    error('MINKMP: first and second arguments must be single ellipsoid.');
  end

  m    = dimension(E1);
  n    = dimension(E2);
  dims = dimension(EE);
  mn   = min(min(dims));
  mx   = max(max(dims));
  if (mn ~= mx) | (mn ~= n) | (m ~= n)
    error('MINKMP: all ellipsoids must be of the same dimension.');
  end
  if n > 3
    error('MINKMP: ellipsoid dimension must be not higher than 3.');
  end

  if ~isbigger(E1, E2)
    switch nargout
      case 0,
        fprintf('The resulting set is empty.');
        return;

      case 1,
        y = [];
        return;

      otherwise,
        y = [];
        Y = [];
        return;

    end
  end

  switch n
    case 2,
      phi = linspace(0, 2*pi, E1.nPlot2dPoints);
      L   = [cos(phi); sin(phi)];

    case 3,
      M   = E1.nPlot3dPoints/2;
      N   = M/2;
      psy = linspace(0, pi, N);
      phi = linspace(0, 2*pi, M);
      L   = [];
      for i = 2:(N - 1)
        arr = cos(psy(i))*ones(1, M);
        L   = [L [cos(phi)*sin(psy(i)); sin(phi)*sin(psy(i)); arr]];
      end
      
    otherwise,
      L = [-1 1];

  end

  if nargin > 3
    if isstruct(varargin{4})
      Options = varargin{4};
    else
      Options = [];
    end
  else
    Options = [];
  end

  if ~isfield(Options, 'newfigure')
    Options.newfigure = 0;
  end

  if ~isfield(Options, 'fill')
    Options.fill = 0;
  end

  if ~isfield(Options, 'show_all')
    Options.show_all = 0;
  end

  if ~isfield(Options, 'color')
    Options.color = [1 0 0];
  end

  if ~isfield(Options, 'shade')
    Options.shade = 0.4;
  else
    Options.shade = Options.shade(1, 1);
  end

  clr  = Options.color;

  if nargout == 0
    ih = ishold;
  end

  if (Options.show_all ~= 0) & (nargout == 0)
    plot(EE, 'b', E2, 'k', E1, 'g');
    hold on;
    if Options.newfigure ~= 0
      figure;
    else
      newplot;
    end
  end

  if Properties.getIsVerbose()
    if nargout == 0
      fprintf('Computing and plotting (E0 - E) + sum(E_i) ...\n');
    else
      fprintf('Computing (E0 - E) + sum(E_i) ...\n');
    end
  end

  vrb                = Properties.getIsVerbose();
  Properties.setIsVerbose(false);
  [x, X]             = minksum(EE);
  Properties.setIsVerbose(vrb);
  y                  = E1.center - E2.center + x;
  Y                  = [];
  N                  = size(L, 2);
  bd                 = isbaddirection(E1, E2, L);
  bd                 = find(bd == 0);

  if isempty(bd)
    x = E1.center - E2.center;
  end

  l       = L(:, bd(1));
  [r, x1] = rho(E1, l);
  [r, x2] = rho(E2, l);
  x       = x1 - x2;

  for i = 1:N
    l = L(:, i);
    if ~isbaddirection(E1, E2, l)
      [r, x1] = rho(E1, l);
      [r, x2] = rho(E2, l);
      x       = x1 - x2;
    end
    Y = [Y (x+X(:, i))];
  end

  switch n
    case 2,
      Y = [Y Y(:, 1)];

      if nargout == 0
        if Options.fill ~= 0
          fill(Y(1, :), Y(2, :), clr);
          hold on;
        end
        h = ell_plot(Y);
        hold on;
        set(h, 'Color', clr, 'LineWidth', 2);
        h = ell_plot(y, '.');
        set(h, 'Color', clr);
      end

    case 3,
      if nargout == 0
        vs = size(Y, 2);
        if vs > 1
          chll = convhulln(Y');
          patch('Vertices', Y', 'Faces', chll, ...
                'FaceVertexCData', clr(ones(1, vs), :), 'FaceColor', 'flat', ...
                'FaceAlpha', Options.shade(1, 1));
        else
          h = ell_plot(y, '*');
          set(h, 'Color', clr);
        end
        hold on;
        shading interp;
        lighting phong;
        material('metal');
        view(3);
        %camlight('headlight','local');
        %camlight('headlight','local');
        %camlight('right','local');
        %camlight('left','local');
      end

    otherwise,
      Y       = [y y];
      Y(1, 1) = EA(1).center - E2.center + sqrt(E2.shape) - sqrt(EA(1).shape);
      Y(1, 2) = EA(1).center - E2.center + sqrt(EA(1).shape) - sqrt(E2.shape);
      if nargout == 0
        h = ell_plot(Y);
        hold on;
        set(h, 'Color', clr, 'LineWidth', 2);
        h = ell_plot(y, '*');
        set(h, 'Color', clr);
      end

  end

  if nargout == 0
    if ih == 0
      hold off;
    end
  end

  if nargout == 1
    y = Y;
  end
  if nargout == 0
    clear y, Y;
  end

  return;
