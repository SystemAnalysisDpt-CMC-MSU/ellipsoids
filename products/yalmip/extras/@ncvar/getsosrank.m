function r=getsosrank(X)

% Author Johan L�fberg 
% $Id: getsosrank.m,v 1.1 2006-08-10 18:00:20 joloef Exp $  

try
    r = X.extra.rank;
catch
    r = inf;
end
  
  
      