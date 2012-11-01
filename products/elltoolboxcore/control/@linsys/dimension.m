function [N, I, O, D] = dimension(lsys)
%
% DIMENSION - returns dimensions of state, input, output and disturbance spaces.
%
%
% Description:
% ------------
%
%            N = DIMENSION(LSYS)  Returns state space dimension.
%       [N, I] = DIMENSION(LSYS)  Returns state space dimension and number of inputs.
%    [N, I, O] = DIMENSION(LSYS)  Returns state space dimension, number of inputs
%                                 and number of outputs.
% [N, I, O, D] = DIMENSION(LSYS)  Returns state space dimension, number of inputs,
%                                 number of outputs and number of disturbance inputs.
%
%
% Output:
% -------
%
%    Dimensions
%               N - state space,
%               I - number of inputs,
%               O - number of outputs,
%               D - number of disturbance inputs.
%
%
% See also:
% ---------
%
%    LINSYS/LINSYS.
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

  if ~(isa(lsys, 'linsys'))
    error('DIMENSION: input argument must be linear system object.');
  end

  [m, n] = size(lsys);
  
  N      = zeros(m,n);
  I      = zeros(m,n);
  O      = zeros(m,n);
  D      = zeros(m,n);
  
  for i = 1:m
    for j = 1:n
      N(i, j) = size(lsys(i, j).A, 1);
      I(i, j) = size(lsys(i, j).B, 2);
      O(i, j) = size(lsys(i, j).C, 1);
      D(i, j) = size(lsys(i, j).G, 2);
    end
  end

  if nargout < 4
    clear D;
    if nargout < 3
      clear O;
      if nargout < 2
        clear I;
      end
    end
  end

  return;
