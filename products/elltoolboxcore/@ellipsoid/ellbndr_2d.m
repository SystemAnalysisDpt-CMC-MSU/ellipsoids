function bpMat = ellbndr_2d(myEll,nPoints)
%
% ELLBNDR_2D - compute the boundary of 2D ellipsoid. Private method.
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1]- ellipsoid of the dimention 2.
%   optional:
%       nPoints: number of boundary points
%
% Output:
%   bpMat: double[2, nPoints + 1] - boundary points of the ellipsoid myEll.
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $
%
% $Author: Guliev Rustam <glvrst@gmail.com> $   $Date: Dec-2012$
% $Copyright: Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Science, System Analysis Department 2012 $
%
% $Author: Vitaly Baranov <vetbar42@gmail.com>$ $Date: 10-04-2013$
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             System Analysis Department 2013$
%
if nargin<2
    nPoints = myEll.nPlot2dPoints;
end
[cenVec qMat]=double(myEll);
absTol=myEll.getAbsTol();
bpMat=ellipsoid.ellbndr_2dmat(nPoints,cenVec,qMat,absTol);