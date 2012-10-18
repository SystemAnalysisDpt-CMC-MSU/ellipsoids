function Q=getbasematrix(X,ind)
%GETBASEMATRIX Internal function to extract basematrix for variable IND

% Author Johan L�fberg 
% $Id: getbasematrix.m,v 1.1 2006-08-10 18:00:20 joloef Exp $  

if ind==0
  base = X.basis(:,1);
  Q = reshape(base,X.dim(1),X.dim(2));
  return;
end

here = find(X.lmi_variables==ind);
if isempty(here)
  Q = sparse(X.dim(1),X.dim(2));
else
  base = X.basis(:,here+1);
  Q = reshape(base,X.dim(1),X.dim(2));
end


