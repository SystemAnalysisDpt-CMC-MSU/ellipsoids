function res = subsref(rs, S)
%
% SUBSREF - allows to access elements of reach class from outside the class methods.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  res = builtin('subsref', rs, S);

  return;
