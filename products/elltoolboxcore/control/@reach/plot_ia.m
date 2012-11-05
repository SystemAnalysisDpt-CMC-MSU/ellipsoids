function plot_ia(rs, varargin)
%
% PLOT_IA - plots internal approximations of 2D and 3D reach sets.
%
%
% Description:
% ------------
%
%         PLOT_IA(RS, OPTIONS)  Plots the internal approximation of the reach set RS
%                               using options in the OPTIONS structure.
%    PLOT_IA(RS, 'r', OPTIONS)  Plots the internal approximation of the reach set RS
%                               in red color using options in the OPTIONS structure.
%
%    OPTIONS structure is an optional parameter with fields:
%      OPTIONS.color       - sets color of the picture in the form [x y z].
%      OPTIONS.width       - sets line width for 2D plots.
%      OPTIONS.shade = 0-1 - sets transparency level (0 - transparent, 1 - opaque).
%      OPTIONS.fill        - if set to 1, reach set will be filled with color.
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
%    REACH/REACH, PLOT_EA, CUT, PROJECTION.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;

  if ~(isa(rs, 'reach'))
    error('PLOT_IA: first input argument must be reach set.');
  end

  rs = rs(1, 1);
  d  = dimension(rs);
  N  = size(rs.ia_values, 2);
  if (d < 2) | (d > 3)
    msg = sprintf('PLOT_IA: cannot plot reach set of dimension %d.', d);
    if d > 3
      msg = sprintf('%s\nUse projection.', msg);
    end
    error(msg);
  end

  if nargin > 1
    if isstruct(varargin{nargin - 1})
      Options = varargin{nargin - 1};
    else
      Options = [];
    end
  else
    Options = [];
  end

  if ~(isfield(Options, 'color'))
    Options.color = [0 1 0];
  end

  if ~(isfield(Options, 'shade'))
    Options.shade = 0.3;
  else
    Options.shade = Options.shade(1, 1);
    if Options.shade > 1
      Options.shade = 1;
    end
    if Options.shade < 0
      Options.shade = 0;
    end
  end

  if ~isfield(Options, 'width')
    Options.width = 2;
  else
    Options.width = Options.width(1, 1);
    if Options.width < 1
      Options.width = 2;
    end
  end

  if ~isfield(Options, 'fill')
    Options.fill = 0;
  else
    Options.fill = Options.fill(1, 1);
    if Options.fill ~= 1
      Options.fill = 0;
    end
  end


  if (nargin > 1) & ischar(varargin{1})
    Options.color = my_color_table(varargin{1});
  end
  
  E   = get_ia(rs);
  clr = Options.color;
  if rs.t0 > rs.time_values(end)
    back = 'Backward reach set';
  else
    back = 'Reach set';
  end

  if Properties.getIsVerbose()
    fprintf('Plotting reach set internal approximation...\n');
  end
  
  if d == 3
    EE         = move2origin(inv(E(:, end)));
    EE         = EE';
    m          = size(EE, 2);
    M          = Properties.getNPlot3dPoints()/2;
    N          = M/2;
    psy        = linspace(-pi/2, pi/2, N);
    phi        = linspace(0, 2*pi, M);
    [phi, psy] = meshgrid(phi, psy);
    x          = ones(3, N, M);
    X          = ones(N, M);
    Y          = ones(N, M);
    Z          = ones(N, M);
    x(1, :, :) = cos(psy).*cos(phi);
    x(2, :, :) = cos(psy).*sin(phi);
    x(3, :, :) = sin(psy);
    for i = 1:N
      for j = 1:M
        mval = inf;
        l    = [x(1, i, j); x(2, i, j); x(3, i, j)];
        for ii = 1:m
          Q = parameters(EE(1, ii));
          v = l' * Q * l;
          if v < mval
            mval = v;
          end
        end
        xx      = (l/sqrt(mval)) + rs.center_values(:, end);
	X(i, j) = xx(1, 1);
	Y(i, j) = xx(2, 1);
	Z(i, j) = xx(3, 1);
      end
    end
    patch(surf2patch(X, Y, Z), ...
          'FaceVertexCData', clr(ones(1, M*N), :), 'FaceColor', 'flat', ...
          'FaceAlpha', Options.shade);
    shading interp;
    lighting phong;
    material('metal');
    view(3);
    %camlight('headlight','local');
    %camlight('headlight','local');
    %camlight('right','local');
    %camlight('left','local');
    if isdiscrete(rs.system)
      title(sprintf('%s at time step K = %d', back, rs.time_values(end)));
    else
      title(sprintf('%s at time T = %d', back, rs.time_values(end)));
    end
    xlabel('x_1'); ylabel('x_2'); zlabel('x_3');
    return;
  end

  ih = ishold;

  if size(rs.time_values, 2) == 1
    E   = move2origin(E');
    M   = size(E, 2);
    N   = Properties.getNPlot2dPoints();
    phi = linspace(0, 2*pi, N);
    L   = [cos(phi); sin(phi)];
    X   = [];
    for i = 1:N
      l    = L(:, i);
      mval = Properties.getAbsTol();
      mQ   = [];
      for j = 1:M
        Q = parameters(E(1, j));
        if isempty(mQ)
          mQ = Q;
        end
        v = l' * Q * l;
        if v > mval
          mval = v;
          mQ   = Q;
        end
      end
      x = (mQ*l/sqrt(mval)) + rs.center_values;
      X = [X x];
    end
    if Options.fill ~= 0
      fill(X(1, :), X(2, :), Options.color);
      hold on;
    end
    h = ell_plot(X);
    hold on;
    set(h, 'Color', Options.color, 'LineWidth', Options.width);
    h = ell_plot(rs.center_values, '.');
    set(h, 'Color', Options.color);
    if isdiscrete(rs.system)
      title(sprintf('%s at time step K = %d', back, rs.time_values));
    else
      title(sprintf('%s at time T = %d', back, rs.time_values));
    end
    xlabel('x_1'); ylabel('x_2');
    if ih == 0
      hold off;
    end
    return;
  end

  [m, n] = size(E);
  s      = (1/2) * Properties.getNPlot2dPoints();
  phi    = linspace(0, 2*pi, s);
  L      = [cos(phi); sin(phi)];

  if isdiscrete(rs.system)
    for ii = 1:n
      EE = move2origin(E(:, ii));
      EE = EE';
      X  = [];
      for i = 1:s
        l    = L(:, i);
        mval = Properties.getAbsTol();
        mQ   = [];
        for j = 1:m
          Q  = parameters(EE(1, j));
          if isempty(mQ)
            mQ = Q;
          end
          v  = l' * Q * l;
          if v > mval
            mval = v;
            mQ   = Q;
          end
        end
        x = (mQ*l/sqrt(mval)) + rs.center_values(:, ii);
        X = [X x];
      end
      tt = rs.time_values(ii) * ones(1, s);
      X  = [tt; X];
      if Options.fill ~= 0
        fill3(X(1, :), X(2, :), X(3, :), Options.color);
        hold on;
      end
      h = ell_plot(X);
      set(h, 'Color', Options.color, 'LineWidth', Options.width);
      hold on;
      h = ell_plot([tt(1, 1); rs.center_values(:, ii)], '.');
      set(h, 'Color', clr);
    end
    xlabel('k');
    if rs.time_values(1) > rs.time_values(end)
      title('Discrete-time backward reach tube');
    else
      title('Discrete-time reach tube');
    end
  else
    F = ell_triag_facets(s, size(rs.time_values, 2));
    V = [];
    for ii = 1:n
      EE = move2origin(E(:, ii));
      EE = EE';
      X  = [];
      for i = 1:s
        l    = L(:, i);
        mval = Properties.getAbsTol();
	mQ   = [];
        for j = 1:m
          Q  = parameters(EE(1, j));
	  if isempty(mQ)
            mQ = Q;
          end
          v  = l' * Q * l;
          if v > mval
            mval = v;
	    mQ   = Q;
          end
        end
        x = (mQ*l/sqrt(mval)) + rs.center_values(:, ii);
        X = [X x];
      end
      tt = rs.time_values(ii) * ones(1, s);
      X  = [tt; X];
      V  = [V X];
    end
    vs = size(V, 2);
    patch('Vertices', V', 'Faces', F, ...
          'FaceVertexCData', clr(ones(1, vs), :), 'FaceColor', 'flat', ...
          'FaceAlpha', Options.shade);
    hold on;
    shading interp;
    lighting phong;
    material('metal');
    view(3);
    %camlight('headlight','local');
    %camlight('headlight','local');
    %camlight('right','local');
    %camlight('left','local');
    xlabel('t');
    if rs.time_values(1) > rs.time_values(end)
      title('Backward reach tube');
    else
      title('Reach tube');
    end
  end
  ylabel('x_1'); zlabel('x_2');

  if ih == 0
    hold off;
  end
  return;
