function [y, Y] = minkpm(varargin)
%
% MINKPM - computes and plots geometric (Minkowski) difference of the geometric
%          sum of ellipsoids and a single ellipsoid in 2D or 3D:
%
%          (E1 + E2 + ... + En) - E
%
%
% Description:
% ------------
%
% MINKPM(EA, E, OPTIONS)  Computes geometric difference of the geometric sum
%                         of ellipsoids in EA and ellipsoid E,
%                         if 1 <= dimension(EA) = dimension(E) <= 3,
%                         and plots it if no output arguments are specified.
%
%    [y, Y] = MINKPM(EA, E)  Computes (geometric sum of ellipsoids in EA) - E.
%                            Here y is the center, and Y - array of boundary points.
%             MINKPM(EA, E)  Plots (geometric sum of ellipsoids in EA) - E
%                            in default (red) color.
%    MINKPM(EA, E, Options)  Plots (geometric sum of ellipsoids in EA) - E
%                            using options given in the Options structure.
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
%    ELLIPSOID/ELLIPSOID, MINKSUM, MINKDIFF, MINKMP.
%

% 
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  if nargin < 2
    error('MINKPM: first and second arguments must be ellipsoids.');
  end

  EE = varargin{1};
  E2 = varargin{2};

  if ~(isa(EE, 'ellipsoid')) | ~(isa(E2, 'ellipsoid'))
    error('MINKPM: first and second arguments must be ellipsoids.');
  end

  [m, n] = size(E2);
  if (m ~= 1) | (n ~= 1)
    error('MINKPM: second argument must be single ellipsoid.');
  end

  dims = dimension(EE);
  k    = min(min(dims));
  m    = max(max(dims));
  n    = dimension(E2);
  if (k ~= m) | (m ~= n)
    error('MINKPM: all ellipsoids must be of the same dimension.');
  end
  if n > 3
    error('MINKPM: ellipsoid dimension must be not higher than 3.');
  end

  switch n
    case 2,
      phi = linspace(0, 2*pi, ellOptions.plot2d_grid);
      L   = [cos(phi); sin(phi)];

    case 3,
      M   = ellOptions.plot3d_grid/2;
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

  vrb                = ellOptions.verbose;
  ellOptions.verbose = 0;
  EA                 = minksum_ea(EE, L);
  ellOptions.verbose = vrb;
  
  if min(EA > E2) == 0
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

  if nargout == 0
    ih = ishold;
  end

  if (Options.show_all ~= 0) & (nargout == 0)
    plot(EE, 'b', E2, 'k');
    hold on;
    if Options.newfigure ~= 0
      figure;
    else
      newplot;
    end
  end

  if ellOptions.verbose > 0
    if nargout == 0
      fprintf('Computing and plotting (sum(E_i) - E) ...\n');
    else
      fprintf('Computing (sum(E_i) - E) ...\n');
    end
  end

  y                  = EA(1).center - E2.center;
  Y                  = [];
%  EF                 = [];
%  LL                 = [];
  N                  = size(L, 2);
  ellOptions.verbose = 0;

%  for i = 1:N
%    l = L(:, i);
%    E = EA(i);
%    if ~isbaddirection(E, E2, l)
%      EF = [EF minkdiff_ea(E, E2, l)];
%      LL = [LL l];
%    end
%  end
%
%  M = size(EF, 2);
%  
%  for i = 1:N
%    l    = L(:, i);
%    mval = 0;
%
%    for j = 1:M
%      Q = parameters(EF(j));
%      v = l' * ell_inv(Q) * l;
%      if v > mval
%        mval = v;
%      end
%    end
%    
%    if mval > 0
%      Y = [Y ((l/sqrt(mval))+y)];
%    end
%  end
%
%  if isempty(Y)
%    Y = y;
%  end

  switch n
    case 2,
      EF = [];
      LL = [];
      for i = 1:N
        l = L(:, i);
        E = EA(i);
        if ~isbaddirection(E, E2, l)
          EF = [EF minkdiff_ea(E, E2, l)];
          LL = [LL l];
        end
      end
      M = size(EF, 2);
      for i = 1:N
        l    = L(:, i);
        mval = 0;
        for j = 1:M
          Q = parameters(EF(j));
          v = l' * ell_inv(Q) * l;
          if v > mval
            mval = v;
          end
        end
        if mval > 0
          Y = [Y ((l/sqrt(mval))+y)];
        end
      end
      if isempty(Y)
        Y = y;
      end
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
      for i = 1:N
        l = L(:, i);
        E = EA(i);
        if ~isbaddirection(E, E2, l)
          I = minksum_ia(EE, l);
          if isbigger(I, E2);
            if ~isbaddirection(I, E2, l)
              [r, x] = rho(minkdiff_ea(E, E2, l), l);
              Y      = [Y x];
            end
          end
        end
      end
      if isempty(Y)
        Y = y;
      end
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

  ellOptions.verbose = vrb;

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
