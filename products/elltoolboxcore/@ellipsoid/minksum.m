function [y, Y] = minksum(varargin)
%
% MINKSUM - computes geometric (Minkowski) sum of ellipsoids in 2D or 3D.
%
%
% Description:
% ------------
%
% MINKSUM(EA, OPTIONS)  Computes geometric sum of ellipsoids in the array EA,
%                       if 1 <= min(dimension(EA)) = max(dimension(EA)) <= 3,
%                       and plots it if no output arguments are specified.
%
%    [y, Y] = MINKSUM(EA)  Computes geometric sum of ellipsoids in EA.
%                          Here y is the center, and Y - array of
%                          boundary points.
%             MINKSUM(EA)  Plots geometric sum of ellipsoids in EA
%                          in default (red) color.
%    MINKSUM(EA, Options)  Plots geometric sum of EA using options
%                          given in the Options structure.
%
%
% Options.show_all     - if 1, displays also ellipsoids in the given array EA.
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
%    ELLIPSOID/ELLIPSOID, MINKSUM_EA, MINKSUM_IA, MINKDIFF, MINKDIFF_EA, MINKDIFF_IA.
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

  nai = nargin;
  E   = varargin{1};
  if ~isa(E, 'ellipsoid')
    error('MINKSUM: input argument must be an array of ellipsoids.');
  end

  ells   = varargin{1};
  [m, n] = size(ells);
  cnt    = m * n;
  ells   = reshape(ells, 1, cnt);
  dims   = dimension(ells);
  m      = min(dims);
  n      = max(dims);

  if m ~= n
    error('MINKSUM: ellipsoids must be of the same dimension.');
  end
  if n > 3
    error('MINKSUM: ellipsoid dimension must be not higher than 3.');
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
    Options.shade = 0.4*ones(1, cnt);
  else
    Options.shade = Options.shade(1, 1);
  end

  %opts.fill            = Options.fill;
  %opts.shade(1, 1:cnt) = Options.shade;

  if nargout == 0
    ih = ishold;
  end

  if (Options.show_all ~= 0) & (nargout == 0)
    plot(ells, 'b');
    hold on;
    if Options.newfigure ~= 0
      figure;
    else
      newplot;
    end
  end

  if (ellOptions.verbose > 0) & (cnt > 1)
    if nargout == 0
      fprintf('Computing and plotting geometric sum of %d ellipsoids...\n', cnt);
    else
      fprintf('Computing geometric sum of %d ellipsoids...\n', cnt);
    end
  end
	
  clr = Options.color;

  for i = 1:cnt
    E = ells(i);

    switch n
      case 2,
        if i == 1
          Y = ellbndr_2d(E);
          y = E.center;
        else
          Y = Y + ellbndr_2d(E);
          y = y + E.center;
        end
        if (i == cnt) & (nargout == 0)
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
        if i == 1
          Y = ellbndr_3d(E);
          y = E.center;
        else
          Y = Y + ellbndr_3d(E);
          y = y + E.center;
        end
        if (i == cnt) & (nargout == 0)
          chll = convhulln(Y');
          vs   = size(Y, 2);
          patch('Vertices', Y', 'Faces', chll, ...
                'FaceVertexCData', clr(ones(1, vs), :), 'FaceColor', 'flat', ...
                'FaceAlpha', Options.shade(1, 1));
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
        if i == 1
          y       = E.center;
          Y(1, 1) = E.center - sqrt(E.shape);
          Y(1, 2) = E.center + sqrt(E.shape);
        else
          y       = y + E.center;
          Y(1, 1) = Y(1, 1) + E.center - sqrt(E.shape);
          Y(1, 2) = Y(1, 2) + E.center + sqrt(E.shape);
        end
        if (i == cnt) & (nargout == 0)
          h = ell_plot(Y);
          hold on;
          set(h, 'Color', clr, 'LineWidth', 2);
          h = ell_plot(y, '*');
          set(h, 'Color', clr);
        end

    end
  end

  if nargout == 0
    if ih == 0
      hold off;
    end
  end

  if nargout == 1
    y = Y;
    clear Y;
  end
  if nargout == 0
    clear y, Y;
  end

  return;
