function res = subsref(lsys, S)
%
% SUBSREF - allows to access elements of linsys class from outside the class methods.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  res = builtin('subsref', lsys, S);

  return;
