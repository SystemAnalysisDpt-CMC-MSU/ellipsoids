function Q=getbasevectorwithoutcheck(X,ind)
%GETBASEVECTORWITHOUTCHECK Internal function to extract basematrix for variable ind

% Author Johan L�fberg 
% $Id: getbasevectorwithoutcheck.m,v 1.1 2006-08-10 18:00:20 joloef Exp $  

Q=X.basis(:,ind+1);
  
  
      