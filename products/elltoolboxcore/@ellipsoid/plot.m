function plot(varargin)
%
% PLOT - plots ellipsoids in 2D or 3D.
%
%
% Description:
% ------------
%
% PLOT(E, OPTIONS) plots ellipsoid E if 1 <= dimension(E) <= 3.
%
%                  PLOT(E)  Plots E in default (red) color.
%              PLOT(EA, E)  Plots array of ellipsoids EA and single 
%                           ellipsoid E.
%   PLOT(E1, 'g', E2, 'b')  Plots E1 in green and E2 in blue color.
%        PLOT(EA, Options)  Plots EA using options given in the Options 
%                           structure.
%
%
% Options.newfigure    - if 1, each plot command will open a new figure 
%                        window.
% Options.fill         - if 1, ellipsoids in 2D will be filled with color.
% Options.width        - line width for 1D and 2D plots.
% Options.color        - sets default colors in the form [x y z].
% Options.shade = 0-1  - level of transparency (0 - transparent, 1 - opaque).
%
%
% Output:
% -------
%
%    None.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID.
%

% 
% $Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;
  import elltool.logging.Log4jConfigurator;

  persistent logger;
  
  nai = nargin;
  E   = varargin{1};
  if ~isa(E, 'ellipsoid')
    error('PLOT: input argument must be an ellipsoid.');
  end

  if nai > 1
    if isstruct(varargin{nai})
      Options = varargin{nai};
      nai     = nai - 1;
    else
      Options = [];
    end
  else
    Options = [];
  end

  if ~isfield(Options, 'newfigure')
    Options.newfigure = 0;
  end

  ucolor    = [];
  vcolor    = [];
  ells      = [];
  ell_count = 0;

  for i = 1:nai
    if isa(varargin{i}, 'ellipsoid')
      E      = varargin{i};
      [m, n] = size(E);
      cnt    = m * n;
      E1     = reshape(E, 1, cnt);
      ells   = [ells E1];
      if (i < nai) && ischar(varargin{i + 1})
        clr = ellipsoid.my_color_table(varargin{i + 1});
        val = 1;
      else
        clr = [0 0 0];
        val = 0;
      end
      for j = (ell_count + 1):(ell_count + cnt)
        ucolor(j) = val;
        vcolor    = [vcolor; clr];
      end
      ell_count = ell_count + cnt;
    end
  end

  if ~isfield(Options, 'color')
    % Color maps:
    %    hsv       - Hue-saturation-value color map.
    %    hot       - Black-red-yellow-white color map.
    %    gray      - Linear gray-scale color map.
    %    bone      - Gray-scale with tinge of blue color map.
    %    copper    - Linear copper-tone color map.
    %    pink      - Pastel shades of pink color map.
    %    white     - All white color map.
    %    flag      - Alternating red, white, blue, and black color map.
    %    lines     - Color map with the line colors.
    %    colorcube - Enhanced color-cube color map.
    %    vga       - Windows colormap for 16 colors.
    %    jet       - Variant of HSV.
    %    prism     - Prism color map.
    %    cool      - Shades of cyan and magenta color map.
    %    autumn    - Shades of red and yellow color map.
    %    spring    - Shades of magenta and yellow color map.
    %    winter    - Shades of blue and green color map.
    %    summer    - Shades of green and yellow color map.
    
    auxcolors  = hsv(ell_count);
    colors     = auxcolors;
    multiplier = 7;
    if mod(size(auxcolors, 1), multiplier) == 0
      multiplier = multiplier + 1;
    end
    
    for i = 1:ell_count
      jj           = mod(i*multiplier, size(auxcolors, 1)) + 1;
      colors(i, :) = auxcolors(jj, :);
    end
    colors        = flipud(colors);
    Options.color = colors;
  else
    if size(Options.color, 1) ~= ell_count
      if size(Options.color, 1) > ell_count
        Options.color = Options.color(1:ell_count, :);
      else
        Options.color = repmat(Options.color, ell_count, 1);
      end
    end
  end

  if ~isfield(Options, 'shade')
    Options.shade = 0.4*ones(1, ell_count);
  else
    [m, n] = size(Options.shade);
    m      = m * n;
    if m == 1
      Options.shade = Options.shade * ones(1, ell_count);
    else
      Options.shade = reshape(Options.shade, 1, m);
      if m < ell_count
        for i = (m + 1):ell_count
          Options.shade = [Options.shade 0.4];
        end
      end
    end
  end

  if ~isfield(Options, 'width')
    Options.width = ones(1, ell_count);
  else
    [m, n] = size(Options.width);
    m      = m * n;
    if m == 1
      Options.width = Options.width * ones(1, ell_count);
    else
      Options.width = reshape(Options.width, 1, m);
      if m < ell_count
        for i = (m + 1):ell_count
          Options.width = [Options.width 1];
        end
      end
    end
  end

  if ~isfield(Options, 'fill')
    Options.fill = zeros(1, ell_count);
  else
    [m, n] = size(Options.fill);
    m      = m * n;
    if m == 1
      Options.fill = Options.fill * ones(1, ell_count);
    else
      Options.fill = reshape(Options.fill, 1, m);
      if m < ell_count
        for i = (m + 1):ell_count
          Options.fill = [Options.fill 0];
        end
      end
    end
  end

  if size(Options.color, 1) < ell_count
    error('PLOT: not enough colors.');
  end

  dims = dimension(ells);
  m    = min(dims);
  n    = max(dims);
  if m ~= n
    error('PLOT: ellipsoids must be of the same dimension.');
  end
  if (n > 3) || (n < 1)
    error('PLOT: ellipsoid dimension can be 1, 2 or 3.');
  end

  if Properties.getIsVerbose()
    if isempty(logger)
      logger=Log4jConfigurator.getLogger();
    end
    if ell_count == 1
      logger.info('Plotting ellipsoid...');
    else
      logger.info(sprintf('Plotting %d ellipsoids...', ell_count));
    end
  end

  ih = ishold;

  for i = 1:ell_count
    if Options.newfigure ~= 0
      figure;
    else
      newplot;
    end

    hold on;

    E = ells(i);
    q = E.center;
    Q = E.shape;

    if ucolor(i) == 1
      clr = vcolor(i, :);
    else
      clr = Options.color(i, :);
    end
      
    switch n
      case 2,
        x = ellbndr_2d(E);
        if Options.fill(i) ~= 0
          fill(x(1, :), x(2, :), clr);
        end
        h = ell_plot(x);
        set(h, 'Color', clr, 'LineWidth', Options.width(i));
        h = ell_plot(q, '.');
        set(h, 'Color', clr);

      case 3,
        x    = ellbndr_3d(E);
        chll = convhulln(x');
        vs   = size(x, 2);
        patch('Vertices', x', 'Faces', chll, ...
              'FaceVertexCData', clr(ones(1, vs), :), 'FaceColor', 'flat', ...
              'FaceAlpha', Options.shade(1, i));
        shading interp;
        lighting phong;
        material('metal');
        view(3);
        %camlight('headlight','local');
        %camlight('headlight','local');
        %camlight('right','local');
        %camlight('left','local');

      otherwise,
        h = ell_plot([(q-realsqrt(Q)) (q+realsqrt(Q))]);
        set(h, 'Color', clr, 'LineWidth', Options.width(i));
        h = ell_plot(q(1, 1), '*');
        set(h, 'Color', clr);

    end
  end

  if ih == 0;
    hold off;
  end

end
