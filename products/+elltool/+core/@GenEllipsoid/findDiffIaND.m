function resQMat=findDiffIaND(ellQ1Mat, ellQ2Mat,curDirVec,absTol)
% FINDDIFFIAND - find internal approximation for Minkowsky difference
%                of ellipsoids with matrices Q1>0, Q2>=0 for any direction
%
% Input:
%   regular:
%       ellQ1Mat: double: [kSize,kSize] - positive matrix
%       ellQ2Mat: double: [kSize,kSize] - semi-positive matrix
%       curDirVec: double: [kSize,1] - direction of calculation
%       absTol: double: [1,1] - absolute tolerance
%
% Output:
%   resQMat: double: [kSize,kSize] - matrix of approximation ellipsoid
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
import elltool.core.GenEllipsoid;
[~, pPar]=GenEllipsoid.getIsGoodDirForMat(ellQ1Mat,ellQ2Mat,curDirVec,...
    absTol);
if (pPar<absTol)
    resQMat=ellQ1Mat;
else
    resQMat=(1-pPar)*ellQ1Mat+(1-1/pPar)*ellQ2Mat;
    resQMat=0.5*(resQMat+resQMat.');
end

