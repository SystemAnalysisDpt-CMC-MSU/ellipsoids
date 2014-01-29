% assign parameter values:
v1 = 65; v2 = 60; v3 = 63; v4 = 65;  % mph
w1 = 10; w2 = 10; w3 = 10; w4 = 10;  % mph
d1 = 2; d2 = 3; d3 = 4; d4 = 2;  % miles
Ts = 2/3600;  % sampling time in hours
xM1 = 200; xM2 = 200; xM3 = 200; xM4 = 200;  % vehicles per lane
b = 0.4;

firstAMat = [(1-(v1*Ts/d1)) 0 0 0
         (v1*Ts/d2) (1-(v2*Ts/d2)) 0 0
         0 (v2*Ts/d3) (1-(v3*Ts/d3)) 0
         0 0 ((1-b)*(v3*Ts/d4)) (1-(v4*Ts/d4))];
firstBMat = [v1*Ts/d1 0 0; 0 0 v2*Ts/d2; 0 0 0; 0 0 0];
firstUBoundsEllObj = ellipsoid([180; 150; 50], [100 0 0; 0 100 0; 0 0 25]);

secAMat = [(1-(w1*Ts/d1)) (w2*Ts/d1) 0 0
         0 (1-(w2*Ts/d2)) (w3*Ts/d2) 0
         0 0 (1-(w3*Ts/d3)) ((1/(1-b))*(w4*Ts/d3))
         0 0 0 (1-(w4*Ts/d4))];
secBMat = [0 0 w1*Ts/d1; 0 0 0; 0 0 0; 0 -w4*Ts/d4 0];
secUBoundsEllObj = firstUBoundsEllObj;
gMat = [(w1*Ts/d1) (-w2*Ts/d1) 0 0
         0 (w2*Ts/d2) (-w3*Ts/d2) 0
         0 0 (w3*Ts/d3) ((-1/(1-b))*(w4*Ts/d3))
         0 0 0 (w4*Ts/d4)];
vVec = [xM1; xM2; xM3; xM4];
% define linear systems:
% free-flow mode
firstSys = elltool.linsys.LinSysDiscrete(firstAMat, firstBMat,...
    firstUBoundsEllObj);
% congestion mode 
secSys = elltool.linsys.LinSysDiscrete(secAMat, secBMat,...
 secUBoundsEllObj, gMat, vVec); 
% define guard:
grdHypObj = hyperplane([0; 1; 0; 0], xM2);
