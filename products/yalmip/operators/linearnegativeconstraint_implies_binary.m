function F = linearnegativeconstraint_implies_binary(f,X,M,m,eps);
% Big-M for f<=0 implies X==1. Assumes f and X vectors of same size

if nargin < 3 | isempty(M)
    [M,m,infbound] = derivebounds(f);
    if infbound
        warning('You have unbounded variables in IFF leading to a lousy big-M relaxation.');
    end
end

if nargin < 5
    eps = 1e-5;
end

if length(X) ~= length(f)
    error('Inconsistent sizes in linearnegativeconstraint_implies_binary: Report bug');
end

% f < -eps implies X==1
F = [f >= -eps + (m+eps).*X];
