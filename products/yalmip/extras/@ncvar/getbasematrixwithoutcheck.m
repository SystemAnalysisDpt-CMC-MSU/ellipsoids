function Q=getbasematrixwithoutcheck(X,ind)
%GETBASEMATRIXWITHOUTCHECK Internal function to extract basematrix for variable IND

% Author Johan L�fberg 
% $Id: getbasematrixwithoutcheck.m,v 1.1 2006-08-10 18:00:20 joloef Exp $  

Q=reshape(X.basis(:,ind+1),X.dim(1),X.dim(2));
  
  
      