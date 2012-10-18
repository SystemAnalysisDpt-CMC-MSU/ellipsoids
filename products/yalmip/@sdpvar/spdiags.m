function X=spdiags(varargin)
%SPDIAGS (overloaded)

% Author Johan L�fberg
% $Id: sparse.m,v 1.7 2010-02-22 12:40:48 joloef Exp $

if nargin < 1
    error('At-least 1 arguments needed');
end

X = varargin{1};
newBase = [];
for i = 1:length(X.lmi_variables)+1
    Y = X.basis(:,i);
    Y = reshape(Y,X.dim);
    tempBase = spdiags(Y,varargin{2:end});
    newBase = [newBase tempBase(:)];
end
X.basis = newBase;
X.dim = size(tempBase);
X.conicinfo = [0 0];
X = flush(X);
X = clean(X);
