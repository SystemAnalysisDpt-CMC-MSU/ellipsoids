function isherm=ishermitian(X)
%ISHERMITIAN Check if variable is Hermitian

% Author Johan L�fberg 
% $Id: ishermitian.m,v 1.1 2008-04-02 19:06:54 joloef Exp $

[n,m] = size(X);
issym = 0;

if (n==m)
  isherm = norm(X-X',1)<1e-10; % Should be scaled with size maybe
end

  
  
