function r=getsosrank(X)

% Author Johan L�fberg 
% $Id: getsosrank.m,v 1.1 2005-07-18 15:01:30 joloef Exp $  

try
    r = X.extra.rank;
catch
    r = inf;
end
  
  
      