mEllObj  = ellipsoid(0.01*eye(3));  % terminating set
termTime = 3;  % terminating time

% compute backward reach set:
% compute the reach set:
secBrsObj = elltool.reach.ReachContinuous(secSys, mEllObj, dirsMat,...
 [termTime switchTime]);  % second system comes first
firstBrsObj = secBrsObj.evolve(0, firstSys);  % then the first system

% obtain projections onto (x1, x2) subspace:
firstBpsObj = firstBrsObj.getProjection(basisMat);
secBpsObj = secBrsObj.getProjection(basisMat);

% plot the results:
subplot(2, 2, 3);
firstBpsObj.plot_ea('r'); % external apprx. of backward reach set 1 (red)
hold on;
firstBpsObj.plot_ia('g'); % internal apprx. of backward reach set 1 (green)
secBpsObj.plot_ea('y'); % external apprx. of backward reach set 2 (yellow)
secBpsObj.plot_ia('b'); % internal apprx. of backward reach set 2 (blue)

% plot the 3-dimensional backward reach set at time t = 0:
subplot(2, 2, 4);
firstBrsObj = firstBrsObj.cut(0);
firstBrsObj.plot_ea('r');
hold on;
firstBrsObj.plot_ia('g');
