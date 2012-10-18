function d = detn(X)
%DETN Internal function used in construction of MAXDET formulations

% Author Johan L�fberg 
% $Id: detn.m,v 1.2 2004-07-02 08:17:30 johanl Exp $  

[n,m]=size(X);

if n~=m
    error
else
    if n==2
        d = X(1,1)*X(2,2)-X(1,2)*X(2,1);
    else
        d = 0;
        for i = 1:n
            d = d + (-1)^(i+1)*X(i,1)*detn(X([1:1:i-1 i+1:1:n],2:end));
        end
    end
end