function X=cumsum(X,I)
%CUMSUM (overloaded)

% Author Johan L�fberg
% $Id: cumsum.m,v 1.9 2009-10-15 10:25:41 joloef Exp $

if nargin == 1
    I = min(find(X.dim>1));
    if isempty(I)
        I = 1;
    end
end

B = [];
for i = 1:length(X.lmi_variables)+1
    C = reshape(X.basis(:,i),X.dim);
    C = cumsum(C,I);
    B = [B C(:)];
end
X.basis = B;
X.conicinfo = [0 0];
X.extra.opname = '';
X = flush(X);
X = clean(X);