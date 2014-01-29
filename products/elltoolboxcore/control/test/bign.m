% A test with large state dimension  (n)
function bign

import elltool.conf.Properties;

Properties.setIsVerbose(false);
Properties.setNTimeGridPoints(135);
profile clear
profile on

test5
test10
test25
test35
test40

profile viewer

% Separate functions for each N are needed for profiling purposes
function test5
test(5);

function test10
test(10);

function test25
test(25);

function test35
test(35);

function test40
test(40);

function test(N)

time0 = now;

NL = 5;     % number of directions

n = 2*N;

% System
A = zeros(n, n);
A(1:N, N+1:end) = eye(N);
o = ones(1, N-1);
A(N+1:end, 1:N) = -diag([2*o, 1]) + diag(o, 1) + diag(o, -1);
B = [zeros(2*N-1, 1); 1];
U = ellipsoid(1, 1);

ls = linsys(sparse(A), sparse(B), U);

% Reach set
X0 = ell_unitball(n);
L = randn(n, NL);
reach(ls, X0, L, -10);

disp(sprintf('Passed test for N = %d: %.1f s', N, (now-time0)*86400));
