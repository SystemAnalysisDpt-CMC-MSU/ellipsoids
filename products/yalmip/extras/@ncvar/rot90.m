function X=rot90(X)
%ROT90 (overloaded)

% Author Johan L�fberg 
% $Id: rot90.m,v 1.1 2006-08-10 18:00:22 joloef Exp $   

n = X.dim(1);
m = X.dim(2);
nm = n*m;
for i = 1:length(X.lmi_variables)+1
  X.basis(:,i) = reshape(rot90(reshape(X.basis(:,i),n,m)),nm,1);
end
X.dim(1) = m;
X.dim(2) = n;
% Reset info about conic terms
X.conicinfo = [0 0];


