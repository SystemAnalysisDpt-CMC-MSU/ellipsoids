function [v, c] = parameters(H)
%
% PARAMETERS - return parameters of hyperplane - normal vector and shift.
%
%
% Description:
% ------------
%
%    [V, C] = PARAMETERS(H)  Returns normal vector and scalar value of the hyperplane.
%
% Output:
% -------
%
%    V - normal vector,
%    C - scalar constant.
%
%
% See also:
% ---------
%
%    HYPERPLANE/HYPERPLANE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%
  if ~(isa(H, 'hyperplane'))
    error('PARAMETERS: input argument must be hyperplane.');
  end

  if min(size(H) == [1 1]) < 1
    error('PARAMETERS: input argument must be single hyperplane.');
  end

  v = H.normal;
  
  if nargout < 2
    return;
  end

  c = H.shift;

  return;
