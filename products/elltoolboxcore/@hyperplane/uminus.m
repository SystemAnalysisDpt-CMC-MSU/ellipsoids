function H1 = uminus(H)
%
% Description:
% ------------
%
%    Switch signs of normal vector and the shift scalar to the opposite.
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

  if ~(isa(H, 'hyperplane'))
    error('UMINUS: input argument must be hyperplanes.');
  end

  H1     = H;
  [m, n] = size(H1);
  
  for i = 1:m
    for j = 1:n
      H1(i, j).normal = - H1(i, j).normal;
      H1(i, j).shift  = - H1(i, j).shift;
    end
  end
    
  return;  
