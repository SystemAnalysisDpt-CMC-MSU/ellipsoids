function QSqrtMat = sqrtm(QMat)
% SQRTM generates a square root from matrix QMat 
% Input:
%      QMat: double[nDims, nDims]
% Output:
%   QsqrtMat: double[nDims,nDims]
%
% 
% $Author: Vadim Kaushanskiy  <vkaushanskiy@gmail.com> $	$Date: 2012-01-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $

    [VMat, DMat]=eig(QMat);
    DMat=sqrt(DMat);
    QSqrtMat=VMat*DMat*VMat.';
end