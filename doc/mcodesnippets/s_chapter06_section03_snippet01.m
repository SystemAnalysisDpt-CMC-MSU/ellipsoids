% define system 1
firstAMat = [-1/6 0 -1/3; 0 0 1/7; 1/2 -1/2 -1/2];
firstBMat = [1/6 1/3; 0 0; 0 0];
firstUBoundsEllObj = ellipsoid(eye(2));
firstSys = elltool.linsys.LinSysContinuous(firstAMat, firstBMat,...
       firstUBoundsEllObj);
% define system 2:
secAMat = [-1/6 0 -1/3; 0 0 1/3; 1/6 -1/6 -1/3];
secBMat = [1/6; 0; 0];
secUBoundsEllObj = ellipsoid(1);
secondSys = elltool.linsys.LinSysContinuous(secAMat, secBMat,....
         secUBoundsEllObj);
x0EllObj = ellipsoid(0.01*eye(3));  % set of initial states
dirsMat = eye(3);  % 3 initial directions
switchTime = 2;  % time of switch
termTime = 3;  % terminating time

% compute the reach set:
firstRsObj = elltool.reach.ReachContinuous(firstSys, x0EllObj, dirsMat,...
 [0 switchTime]);  % reach set of the first system
% computation of the second reach set starts
% where the first left off
secRsObj = firstRsObj.evolve(termTime, secondSys);

% obtain projections onto (x1, x2) subspace:
basisMat = [1 0 0; 0 1 0]';  % (x1, x2) subspace basis
firstPsObj = firstRsObj.projection(basisMat);
secPsObj = secRsObj.projection(basisMat);

% plot the results:
subplot(2, 2, 1);
firstPsObj.plot_ea('r');  % external apprx. of reach set 1 (red)
hold on;
firstPsObj.plot_ia('g');  % internal apprx. of reach set 1 (green)
secPsObj.plot_ea('y');  % external apprx. of reach set 2 (yellow)
secPsObj.plot_ia('b');  % internal apprx. of reach set 2 (blue)

% plot the 3-dimensional reach set at time t = 3:
subplot(2, 2, 2);
secRsObj = secRsObj.cut(3)
secRsObj.plot_ea('y');
hold on;
secRsObj.plot_ia('b');
