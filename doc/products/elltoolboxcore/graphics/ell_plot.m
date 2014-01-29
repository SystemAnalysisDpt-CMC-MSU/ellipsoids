function h = ell_plot(x, varargin)
%
%
% Description:
% ------------
%
%    Wrapper for PLOT and PLOT3 functions.
%    First argument must be a vector, or an array of 
%    vectors, in 1D, 2D or 3D.
%    Other arguments are the same as for PLOT and PLOT3
%    functions.
%
%
% Output:
% -------
%
%    Plot handle.
%
%
% See also:
% ---------
%
%    PLOT, PLOT3.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  [m, n] = size(x);
  if m > 3
    error('ELL_PLOT: can only plot 1D, 2D and 3D vectors.');
  end


  switch m
    case 1,
      y = zeros(1, n);
      h = plot(x, y, varargin{:});

    case 2,
      xx = x(1, :);
      yy = x(2, :);
      h  = plot(xx, yy, varargin{:});  

    otherwise,
      xx = x(1, :);
      yy = x(2, :);
      zz = x(3, :);
      h  = plot3(xx, yy, zz, varargin{:});  

  end

  if nargout == 0
    clear h;
  end 

  return;
