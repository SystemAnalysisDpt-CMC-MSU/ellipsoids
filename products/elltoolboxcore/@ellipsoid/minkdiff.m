function [y, Y] = minkdiff(varargin)
%
% MINKDIFF - computes geometric (Minkowski) difference of two ellipsoids in 2D or 3D.
%
%
% Description:
% ------------
%
% MINKDIFF(E1, E2, OPTIONS)  Computes geometric difference of two ellipsoids
%                            E1 - E2, if 1 <= dimension(E1) = dimension(E2) <= 3,
%                            and plots it if no output arguments are specified.
%
%    [y, Y] = MINKDIFF(E1, E2)  Computes geometric difference of two ellipsoids
%                               E1 - E2.
%                               Here y is the center, and Y - array of
%                               boundary points.
%             MINKDIFF(E1, E2)  Plots geometric difference of two ellipsoids
%                               E1 - E2 in default (red) color.
%    MINKDIFF(E1, E2, Options)  Plots geometric difference E1 - E2 using options
%                               given in the Options structure.
%
%    In order for the geometric difference to be nonempty set, ellipsoid E1
%    must be bigger than E2 in the sense that if E1 and E2 had the same center,
%    E2 would be contained inside E1.
%
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
%    ELLIPSOID/ELLIPSOID, MINKDIFF_EA, MINKDIFF_IA, ISBIGGER, ISBADDIRECTION,
%                         MINKSUM, MINKSUM_EA, MINKSUM_IA.
%

% 
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if nargin < 2
    error('MINKDIFF: first and second arguments must be single ellipsoids.');
  end

  E1 = varargin{1};
  E2 = varargin{2};

  if ~(isa(E1, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    error('MINKDIFF: first and second arguments must be single ellipsoids.');
  end

  if isbigger(E1, E2) == 0
    switch nargout
      case 0,
        fprintf('Geometric difference of these two ellipsoids is empty set.');
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

  if nargin > 2
    if isstruct(varargin{3})
      Options = varargin{3};
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
  m    = dimension(E1);
  n    = dimension(E2);
  if m ~= n
    error('MINKDIFF: ellipsoids must be of the same dimension.');
  end
  if n > 3
    error('MINKDIFF: ellipsoid dimension must be not higher than 3.');
  end

  %opts.fill          = Options.fill;
  %opts.shade(1, 1:2) = Options.shade;

  if nargout == 0
    ih = ishold;
  end

  if (Options.show_all ~= 0) & (nargout == 0)
    plot([E1 E2], 'b');
    hold on;
    if Options.newfigure ~= 0
      figure;
    else
      newplot;
    end
  end

  if Properties.getIsVerbose()
    if nargout == 0
      fprintf('Computing and plotting geometric difference of two ellipsoids...\n');
    else
      fprintf('Computing geometric difference of two ellipsoids...\n');
    end
  end
	
  Q1 = E1.shape;
  if rank(Q1) < size(Q1, 1)
    Q1 = regularize(Q1,E1.properties.absTol);
  end
  Q2 = E2.shape;
  if rank(Q2) < size(Q2, 1)
    Q2 = regularize(Q2,E2.properties.absTol);
  end
  switch n
    case 2,
      y      = E1.center - E2.center;
      phi    = linspace(0, 2*pi, Properties.getNPlot2dPoints());
      l = rm_bad_directions(Q1, Q2, [cos(phi); sin(phi)]);
      if size(l, 2) > 0
        [r, Y] = rho(E1, l);
        [r, X] = rho(E2, l);
        Y      = Y - X;
        Y      = [Y Y(:, 1)];
      else
        Y = y;
      end
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
      y   = E1.center - E2.center;
      M   = Properties.getNPlot3dPoints()/2;
      N   = M/2;
      psy = linspace(0, pi, N);
      phi = linspace(0, 2*pi, M);
      l   = [];
      for i = 2:(N - 1)
        arr = cos(psy(i))*ones(1, M);
        l   = [l [cos(phi)*sin(psy(i)); sin(phi)*sin(psy(i)); arr]];
      end
      l = rm_bad_directions(Q1, Q2, l);
      if size(l, 2) > 0
        [r, Y] = rho(E1, l);
        [r, X] = rho(E2, l);
        Y      = Y - X;
      else
        Y = y;
      end
      if nargout == 0
        vs   = size(Y, 2);
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
      y       = E1.center - E2.center;
      Y(1, 1) = E1.center - E2.center + sqrt(E2.shape) - sqrt(E1.shape);
      Y(1, 2) = E1.center - E2.center + sqrt(E1.shape) - sqrt(E2.shape);
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
