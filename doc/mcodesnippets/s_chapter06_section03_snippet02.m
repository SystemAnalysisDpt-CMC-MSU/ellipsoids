mEllObj  = ellipsoid(0.01*eye(3));  % terminating set
termTime = 3;  % terminating time

% compute backward reach set:
% compute the reach set:
secBrsObj = elltool.reach.ReachContinuous(secondSys, mEllObj, dirsMat,...
 [termTime switchTime], 'isRegEnabled', true, 'isJustCheck', false,...
 'regTol', 1e-5);  % second system comes first
firstBrsObj = secBrsObj.evolve(0, firstSys);  % then the first system

% obtain projections onto (x1, x2) subspace:
firstBpsObj = firstBrsObj.projection(basisMat);
secBpsObj = secBrsObj.projection(basisMat);

% plot the results:

firstBpsObj.plotByEa('r'); % external apprx. of backward reach set 1 (red)
hold on;
firstBpsObj.plotByIa('g'); % internal apprx. of backward reach set 1 (green)
secBpsObj.plotByEa('y'); % external apprx. of backward reach set 2 (yellow)
secBpsObj.plotByIa('b'); % internal apprx. of backward reach set 2 (blue)

% plot the 3-dimensional backward reach set at time t = 0:

firstBrsObj = firstBrsObj.cut(0);
firstBrsObj.plotByEa('r');
hold on;
firstBrsObj.plotByIa('g');
