function [D, N] = dimension(rs)
%
% DIMENSION - returns the dimension of the reach set.
%
%
% Description:
% ------------
%
%  [D, N] = DIMENSION(RS)  returns the dimension of the reach set and, optionally,
%                          the state space dimension.  
%
%
% Output:
% -------
%
%    D - reach set dimension.
%    N - state space dimension.
%
%
% See also:
% ---------
%
%    REACH/REACH.
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

  if ~(isa(rs, 'reach'))
    error('DIMENSION: input argument must be reach set object.');
  end

  [m, n] = size(rs);
  D      = [];
  N      = [];
  
  for i = 1:m
    dd = [];
    nn = [];
    for j = 1:n
      s = dimension(rs(i, j).system);
      if isempty(rs(i, j).projection_basis)
        d = s;
      else
        d = size(rs(i, j).projection_basis, 2);
      end
      dd = [dd d];
      nn = [nn s];
    end
    D = [D; dd];
    N = [N; nn];
  end

  if nargout < 2
    clear N;
  end

  return;
