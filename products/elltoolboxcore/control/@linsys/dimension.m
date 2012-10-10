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

  N      = [];
  I      = [];
  O      = [];
  D      = [];
  [m, n] = size(lsys);
  for i = 1:m
    nn = [];
    ii = [];
    oo = [];
    dd = [];
    for j = 1:n
      nn = [nn size(lsys(i, j).A, 1)];
      ii = [ii size(lsys(i, j).B, 2)];
      oo = [oo size(lsys(i, j).C, 1)];
      dd = [dd size(lsys(i, j).G, 2)];
    end
    N = [N; nn];
    I = [I; ii];
    O = [O; oo];
    D = [D; dd];
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
