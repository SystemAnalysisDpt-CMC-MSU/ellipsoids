function dxdt = ell_stm_ode(t, x, mydata, n, back,varargin)
%
% ELL_STM_ODE - ODE for state transition matrix.
%

if back > 0
    t = -t;
end

A  = ell_value_extract(mydata.A, t, [n n]);
Z  = zeros(n, n);
AA = A;
ZZ = Z;

for i = 1:(n - 1)
    AA = [AA ZZ; ZZ' A];
    ZZ = [ZZ; Z];
end

if back > 0
    dxdt = -AA * x;
else
    dxdt = AA * x;
end