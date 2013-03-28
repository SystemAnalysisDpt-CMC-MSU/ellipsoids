function QSqrtMat = sqrtm(QMat, varargin)
% SQRTM generates a square root from matrix QMat 
% Input:
%     regular: 
%         QMat: double[nDims, nDims]
%     optional:
%         absTol: double[1, 1] - tolerance for eigenvalues
%      
% Output:
%   QsqrtMat: double[nDims, nDims]
%   
%
% 
% $Author: Vadim Kaushanskiy  <vkaushanskiy@gmail.com> $	$Date: 2012-01-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $

    [VMat, DMat]=eig(QMat);
    if (nargin >= 2) 
        DMat = sqrt(max(DMat,varargin{1}));
    else
        DMat = sqrt(DMat);
    end
    QSqrtMat=VMat*DMat*VMat.';
end