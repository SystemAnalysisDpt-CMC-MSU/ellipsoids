function D = dimension(H);
%
% DIMENSION - returns dimensions of hyperplanes in the array.
%
%
% Description:
% ------------
%
%    D = DIMENSION(H)  Returns dimensions of hyperplanes described by
%                      hyperplane structures in the array H.
%
%
% Output:
% -------
%
%    D - array with dimension data of the same size as the size of input 
%        array of hyperplane structures.
%
%
% See also:
% ---------
%
%    HYPERPLANE.
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

  if ~isa(H, 'hyperplane')
    error('DIMENSION: input must be array of hyperplanes.');
  end

  [m, n] = size(H);
  D      = [];
  for i = 1:m
    r = [];
    for j = 1:n
      h = H(i, j);
      s = size(h.normal, 1);
      if s < 2
        if (abs(h.normal) <= ellOptions.abs_tol) & ...
           (abs(h.shift) <= ellOptions.abs_tol)
          r = [r 0];
        else
          r = [r s];
        end
      else
        r = [r s];
      end
    end
    D = [D; r];
  end

  return;
