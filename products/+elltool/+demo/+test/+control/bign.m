% A test with large state dimension  (n)
function bign(varargin)
import elltool.conf.Properties;

Properties.setIsVerbose(false);
Properties.setNTimeGridPoints(135);

test(5);
test(10);
test(25);
% test(35);


function test(N)

time0 = now;

nDirs = 5;     % number of directions

n = 2*N;

% System
aMat = zeros(n, n);
aMat(1:N, N+1:end) = eye(N);
onesVec = ones(1, N-1);
aMat(N+1:end, 1:N) = -diag([2*onesVec, 1]) + diag(onesVec, 1) + diag(onesVec, -1);
bMat = [zeros(2*N-1, 1); 1];
SUBounds = ellipsoid(1, 1);

sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);

% Reach set
x0EllObj = ell_unitball(n);
dirsMat = randn(n, nDirs);
elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, [-10 0],'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-4);

disp(sprintf('Passed test for N = %d: %.1f s', N, (now-time0)*86400)); %#ok<DSPS>
