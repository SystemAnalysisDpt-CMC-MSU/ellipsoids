function E = ell_enclose(V)
%
% ELL_ENCLOSE - computes minimum volume ellipsoid that contains given vectors.
%
%
% Description:
% ------------
%
%    E = ELL_ENCLOSE(V)  Given vectors specified as columns of matrix V,
%                        compute minimum volume ellipsoid E that contains them.
%
%
% Output:
% -------
%
%    E - computed ellipsoid.
%
%
% See also:
% ---------
%
%    ELLIPSOID/ISINTERNAL, ELLUNION_EA;
%    POLYTOPE/getOutterEllipsoid.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%


global ellOptions;

if ~isstruct(ellOptions)
  evalin('base', 'ellipsoids_init;');
end

if nargin < 1
  E = ellipsoid;
  return;
end

[m, n] = size(V);

if ellOptions.verbose > 0
  fprintf('Invoking YALMIP...\n');
end

A = sdpvar(m, m);
b = sdpvar(m, 1);
C = set('A > 0');
for i = 1:n
  C = C + set('||A*V(:, i)+b||<1');
end

s  = solvesdp(C, -logdet(A), ellOptions.sdpsettings);

Aa = double(A);
bb = double(b);

Q  = ell_inv(Aa' * Aa);
Q  = 0.5 * (Q' + Q);
q  = -inv(Aa) * bb;

E  = ellipsoid(q, Q);

return;
