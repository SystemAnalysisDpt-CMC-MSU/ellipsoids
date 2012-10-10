function res = ne(H1, H2)
%
%
% Description:
% ------------
%
%    The opposite of EQ.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  res = ~(eq(H1, H2));

  return;
