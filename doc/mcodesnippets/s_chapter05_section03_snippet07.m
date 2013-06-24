externallEllMat = firstRsObj.get_ea()  % external approximating ellipsoids

% externallEllMat =
% 2x100 array of ellipsoids.

% internal approximating ellipsoids
[internalEllMat, timeVec] = firstRsObj.get_ia();  