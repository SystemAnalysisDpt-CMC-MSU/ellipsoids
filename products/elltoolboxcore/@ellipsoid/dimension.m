function [sd, ed] = dimension(E)
%
% DIMENSION - returns the dimension of the space in which the ellipsoid
%             is defined and the dimension of the ellipsoid.
%
%
% Description:
% ------------
%
%    [SD, ED] = DIMENSION(E)  Retrieves the space dimension SD in which
%                             the ellipsoid E is defined and the actual
%                             dimension ED of this ellipsoid.
%
%          SD = DIMENSION(E)  Retrieves just the space dimension SD in which
%                             the ellipsoid E is defined.
%
%
% Output:
% -------
%
%    SD - space dimension.
%    ED - dimension of the ellipsoid E.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ELLIPSOID, ISDEGENERATE.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;


  [m, n] = size(E);
  
  sd=zeros(m,n);
  ed=zeros(m,n);
  for i = 1:m
    for j = 1:n
      sd(i, j) = size(E(i, j).shape, 1);
      ed(i, j) = rank(E(i, j).shape);
      if isempty(E(i, j).shape) || isempty(E(i, j).center)
        sd(i, j) = 0;
        ed(i, j) = 0;
      end
    end
  end

end
