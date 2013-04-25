function volVal = ellvolume(QMat)
% ELLVOLUME calculates a volume of ellipsoid
% 
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-12-30 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
nDims=size(QMat,1);
volVal=pi^(nDims*0.5)*realsqrt(det(QMat))./gamma(0.5*nDims+1);