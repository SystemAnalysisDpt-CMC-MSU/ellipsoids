function bpMat = ellbndr_3d(myEll)
%
% ELLBNDR_3D - compute the boundary of 3D ellipsoid. 
%
% Input:
%   regular:
%       myEll: ellipsoid [1, 1]- ellipsoid of the dimention 3.
%
% Output:
%   bpMat: double[3, nCols] - boundary points of the ellipsoid myEll.
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
sphereTriangNum=3;
[cenVec qMat]=double(myEll);
absTol=myEll.getAbsTol();
bpMat=ellipsoid.ellbndr_3dmat(cenVec,qMat,sphereTriangNum,absTol);
