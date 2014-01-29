function dXdt = ell_iesm_ode(t, X, xl0, l0, mydata, n, back, absTol)
%
% ELL_IESM_ODE - ODE for the shape matrix of the internal
%                ellipsoid.
%
import elltool.conf.Properties;
if nargin < 8
    absTol=Properties.getAbsTol();
end
if back > 0
    t = -t;
    F = ell_value_extract(mydata.Phi, t, [n n]);
    s = -1;
else
    F = ell_value_extract(mydata.Phinv, t, [n n]);
    s = 1;
end

A     = ell_value_extract(mydata.A, t, [n n]);
BPBsr = ell_value_extract(mydata.BPBsr, t, [n n]);
X     = reshape(X, n, n);

l = BPBsr * F' * l0;
%xl0 = X * F' *l0;
if norm(l) <absTol
    S = eye(n);
else
    S = ell_valign(xl0, l);
end
dXdt = reshape((s*X*A' + S*BPBsr), n*n, 1);