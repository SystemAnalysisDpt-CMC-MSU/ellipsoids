function [v, c] = double(H)
%
% DOUBLE - return parameters of hyperplane - normal vector and shift.
%
%
% Description:
% ------------
%
%    [V, C] = DOUBLE(H)  Returns normal vector and scalar value of the hyperplane.
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

  import elltool.conf.Properties;


  if ~(isa(H, 'hyperplane'))
    error('DOUBLE: input argument must be hyperplane.');
  end

  if min(size(H) == [1 1]) < 1
    error('DOUBLE: input argument must be single hyperplane.');
  end

  v = H.normal;
  
  if nargout < 2
    return;
  end

  c = H.shift;

  return;
