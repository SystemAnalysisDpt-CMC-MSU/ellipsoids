function figHandleVec = plot(varargin)
%
% PLOT - plots hyperplanes in 2D or 3D.
%
%
% Description:
% ------------
%
% PLOT(H, OPTIONS) plots hyperplane H if 2 <= dimension(E) <= 3.
%
%                PLOT(H)  Plots H in default (red) color.
%            PLOT(HA, H)  Plots array of hyperplanes HA and single hyperplane H.
% PLOT(H1, 'g', H2, 'b')  Plots H1 in green and H2 in blue color.
%      PLOT(HA, Options)  Plots HA using options given in the Options structure.
%
%
% Options.newfigure   - if 1, each plot command will open a new figure window.
% Options.size        - length of the line segment in 2D, or square diagonal in 3D.
% Options.center      - center of the line segment in 2D, of the square in 3D.
% Options.width       - line width for 2D plots.
% Options.color       - sets default colors in the form [x y z].
% Options.shade = 0-1 - level of transparency (0 - transparent, 1 - opaque).
%
%
% Output:
% -------
%
%    Array with handles of figures hyperplanes were plotted in. The size of array
%is [1 n], where n is number of figures.
%
% See also:
% ---------
%
%    HYPERPLANE/HYPERPLANE, PLOT.
%

% 
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: <1 november> $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department <2012> $


  global ellOptions;

  if ~isstruct(ellOptions)
    evalin('base', 'ellipsoids_init;');
  end

  nai = nargin;
  H   = varargin{1};
  if ~(isa(H, 'hyperplane'))
    error('PLOT: input argument must be hyperplane.');
  end

  if nai > 1
    if isstruct(varargin{nai}) & ~(isa(varargin{nai}, 'hyperplane'))
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

  ucolor   = [];
  vcolor   = [];
  hps      = [];
  hp_count = 0;
  for i = 1:nai
    if isa(varargin{i}, 'hyperplane')
      H      = varargin{i};
      [m, n] = size(H);
      cnt    = m * n;
      H1     = reshape(H, 1, cnt);
      hps    = [hps H1];
      if (i < nai) & ischar(varargin{i + 1})
        clr = my_color_table(varargin{i + 1});
        val = 1;
      else
        clr = [0 0 0];
        val = 0;
      end
      for j = (hp_count + 1):(hp_count + cnt)
        ucolor(j) = val;
        vcolor    = [vcolor; clr];
      end
      hp_count = hp_count + cnt;
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
    
    auxcolors  = hsv(hp_count);
    colors     = auxcolors;
    multiplier = 7;
    if mod(size(auxcolors, 1), multiplier) == 0
      multiplier = multiplier + 1;
    end
    
    for i = 1:hp_count
      jj           = mod(i*multiplier, size(auxcolors, 1)) + 1;
      colors(i, :) = auxcolors(jj, :);
    end
    colors        = flipud(colors);
    Options.color = colors;
  else
    if size(Options.color, 1) ~= hp_count
      if size(Options.color, 1) > hp_count
        Options.color = Options.color(1:hp_count, :);
      else
        Options.color = repmat(Options.color, hp_count, 1);
      end
    end
  end

  if ~isfield(Options, 'shade')
    Options.shade = 0.25 * ones(1, hp_count);
  else
    [m, n] = size(Options.shade);
    m      = m * n;
    if m == 1
      Options.shade = Options.shade * ones(1, hp_count);
    else
      Options.shade = reshape(Options.shade, 1, m);
      if m < hp_count
        for i = (m + 1):hp_count
          Options.shade = [Options.shade 0.25];
        end
      end
    end
  end

  if ~isfield(Options, 'size')
    Options.size = 100 * ones(1, hp_count);
  else
    [m, n] = size(Options.size);
    m      = m * n;
    if m == 1
      Options.size = Options.size * ones(1, hp_count);
    else
      Options.size = reshape(Options.size, 1, m);
      if m < hp_count
        for i = (m + 1):hp_count
          Options.size = [Options.size 100];
        end
      end
    end
  end

  if ~isfield(Options, 'center')
    Options.center = zeros(1, hp_count);
    m = size(Options.center, 2);
    if m < hp_count
      for i = (m + 1):hp_count
        Options.center = [Options.center (Options.center(:, 1) - Options.center(:, 1))];
      end
    end
  end

  if ~isfield(Options, 'width')
    Options.width = ones(1, hp_count);
  else
    [m, n] = size(Options.width);
    m      = m * n;
    if m == 1
      Options.width = Options.width * ones(1, hp_count);
    else
      Options.width = reshape(Options.width, 1, m);
      if m < hp_count
        for i = (m + 1):hp_count
          Options.width = [Options.width 1];
        end
      end
    end
  end

  if size(Options.color, 1) < hp_count
    error('PLOT: not enough colors.');
  end

  dims = dimension(hps);
  m    = min(dims);
  n    = max(dims);
  if m ~= n
    error('PLOT: hyperplanes must be of the same dimension.');
  end
  if (n < 2) | (n > 3)
    error('PLOT: hyperplane dimension must be 2 or 3.');
  end

  if ellOptions.verbose > 0
    if hp_count == 1
      fprintf('Plotting hyperplane...\n');
    else
      fprintf('Plotting %d hyperplanes...\n', hp_count);
    end
  end

  if  ~isempty(findall(0,'Type','Figure')) && ~(Options.newfigure)
    ih = ishold;
  else
    ih = false;
  end 
  
  if Options.newfigure
      figHandleVec = zeros(1,hp_count);
  else 
      if ih
          figHandleVec = gcf;
      else
          figHandleVec = figure();
      end
  end
  
  for i = 1:hp_count
    if Options.newfigure ~= 0
        figHandleVec(i) = figure();
    else
      newplot(figHandleVec);
    end

    hold on;

    H = hps(i);
    q = H.normal;
    g = H.shift;
    if g < 0
      g = -g;
      q = -q;
    end
    c = Options.size(i)/2;

    if ucolor(i) == 1
      clr = vcolor(i, :);
    else
      clr = Options.color(i, :);
    end
      
    if size(Options.center, 1) == n
      x0 = Options.center(:, i);
      if ~(contains(H, x0))
        x0 = (g*q)/(q'*q);
      end
    else
      x0 = (g*q)/(q'*q);
    end
    [U S V] = svd(q);
    e1      = U(:, 2);
    x1      = x0 - c*e1;
    x2      = x0 + c*e1;
    if n == 2
      h = ell_plot([x1 x2]);
      set(h, 'Color', clr, 'LineWidth', Options.width(i));
    else
      e2 = U(:, 3);
      if min(min(abs(x0))) < ellOptions.abs_tol
        x0 = x0 + ellOptions.abs_tol * ones(3, 1);
      end
      x3 = x0 - c*e2;
      x4 = x0 + c*e2;
      if strcmp(version('-release'), '13')
        ch = convhulln([x1 x3 x2 x4]');
      else
        ch = convhulln([x1 x3 x2 x4]', {'QJ', 'QbB', 'Qs', 'QR0', 'Pp'});
      end
      patch('Vertices', [x1 x3 x2 x4]', 'Faces', ch, ...
            'FaceVertexCData', clr(ones(1, 4), :), 'FaceColor', 'flat', ...
            'FaceAlpha', Options.shade(1, i));
      shading interp;
      lighting phong;
      material('metal');
      view(3);
      %camlight('headlight','local');
      %camlight('headlight','local');
      %camlight('right','local');
      %camlight('left','local');
    end

  end

  if ~ih;
    hold off;
  end

  return;





function res = my_color_table(ch)
%
% MY_COLOR_TABLE - returns the code of the color defined by single letter.
%

  if ~(ischar(ch))
    res = [0 0 0];
    return;
  end

  switch ch
    case 'r',
      res = [1 0 0];

    case 'g',
      res = [0 1 0];

    case 'b',
      res = [0 0 1];

    case 'y',
      res = [1 1 0];

    case 'c',
      res = [0 1 1];

    case 'm',
      res = [1 0 1];

    case 'w',
      res = [1 1 1];

    otherwise,
      res = [0 0 0];
  end

  return;
