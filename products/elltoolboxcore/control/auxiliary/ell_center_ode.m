function dxdt = ell_center_ode(t, x, mydata, n, back,varargin)
%
% ELL_CENTER_ODE - ODE for the center of the reach set.
%
if back > 0
    t = -t;
end
%
A  = ell_value_extract(mydata.A, t, [n n]);
Bp = ell_value_extract(mydata.Bp, t, [n 1]);

if ~(isempty(mydata.Gq))
    Gq = ell_value_extract(mydata.Gq, t, [n 1]);
else
    Gq = zeros(n, 1);
end
%
if back > 0
    dxdt = -A*x - Bp - Gq;
else
    dxdt = A*x + Bp + Gq;
end