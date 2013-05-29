externallEllMat = firstRsObj.get_ea()  % external approximating ellipsoids

% externallEllMat =
% Array of ellipsoids with dimensionality 2x100

% internal approximating ellipsoids
[internalEllMat, timeVec] = firstRsObj.get_ia();  