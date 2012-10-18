function Y=sum(X,I)
%SUM (overloaded)

% Author Johan L�fberg 
% $Id: sum.m,v 1.1 2006-08-10 18:00:22 joloef Exp $   

try
    n = X.dim(1);
    m = X.dim(2);
    if nargin==1
        Y = X;
        if n==1 | m==1
            % Spezialized code...
            Y.basis = sum(Y.basis,1);
            Y.dim(1) = 1;
            Y.dim(2) = 1;
            temp = 1;
        else
            % Standard case

            temp = sum(reshape(X.basis(:,1),n,m));
            Y.basis =  kron(speye(m),ones(1,n))*X.basis;

        end
    else
        Y = X;
        temp = sum(reshape(X.basis(:,1),n,m),I);
        Y.basis = temp(:);
        for i = 1:length(Y.lmi_variables)
            temp = sum(reshape(X.basis(:,i+1),n,m),I);
            Y.basis(:,i+1) = temp(:);
        end
    end
catch
    error(lasterr)
end
Y.dim(1) = size(temp,1);
Y.dim(2) = size(temp,2);
% Reset info about conic terms
Y.conicinfo = [0 0];
Y = clean(Y);
