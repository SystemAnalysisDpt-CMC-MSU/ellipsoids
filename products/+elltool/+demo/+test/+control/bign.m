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

function test(dirsNumber)

time0 = now;

dirsNumber = 5;     % number of directions

n = 2*dirsNumber;

% System
aMat = zeros(n, n);
aMat(1:dirsNumber, dirsNumber+1:end) = eye(dirsNumber);
onesVec = ones(1, dirsNumber-1);
aMat(dirsNumber+1:end, 1:dirsNumber) = -diag([2*onesVec, 1]) + diag(onesVec, 1) + diag(onesVec, -1);
bMat = [zeros(2*dirsNumber-1, 1); 1];
SUBounds = ellipsoid(1, 1);

sys = elltool.linsys.LinSysContinuous(aMat, bMat, SUBounds);

% Reach set
x0EllObj = ell_unitball(n);
dirsMat = randn(n, NL);
elltool.reach.ReachContinuous(sys, x0EllObj, dirsMat, [-10 0],'isRegEnabled', true, 'isJustCheck', false, 'regTol', 1e-4);

disp(sprintf('Passed test for N = %d: %.1f s', dirsNumber, (now-time0)*86400));
