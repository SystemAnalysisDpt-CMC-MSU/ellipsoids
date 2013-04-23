function resQMat=findDiffEaND(ellQ1Mat, ellQ2Mat,curDirVec,absTol)
% FINDDIFFEAND - find external approximation for Minkowsky difference
%                of ellipsoids with matrices Q1>0, Q2>=0, in good direction
%
% Input:
%   regular:
%       ellQ1Mat: double: [kSize,kSize] - positive matrix
%       ellQ2Mat: double: [kSize,kSize] - semi-positive matrix
%       curDirVec: double: [kSize,1] - direction of calculation
%       absTol: double: [1,1] - absolute tolerance
%
% Output:
%   resQMat: double: [kSize,kSize]/[0,0] - matrix of approximating 
%       ellipsoid. Empty if the direction is bad.
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $    $Date: Nov-2012$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
import elltool.core.GenEllipsoid;
isGoodDir= GenEllipsoid.getIsGoodDirForMat(ellQ1Mat,ellQ2Mat,curDirVec,...
    absTol);
if isGoodDir
    ellSQR1Mat=GenEllipsoid.findSqrtOfMatrix(ellQ1Mat,absTol);
    ellSQR2Mat=GenEllipsoid.findSqrtOfMatrix(ellQ2Mat,absTol);
    sOrthMat=  gras.la.orthtransl(ellSQR2Mat*curDirVec,...
        ellSQR1Mat*curDirVec);
    auxMat=ellSQR1Mat-sOrthMat*ellSQR2Mat;
    resQMat=auxMat.'*auxMat;
    resQMat=0.5*(resQMat+resQMat.');
else
    resQMat=[];
end