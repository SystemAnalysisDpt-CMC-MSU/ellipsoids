function regMat = regmat(inpMat, regTol)
% REGMAT returns a regularized inpMat matrix.
%
% Input:
%   regular:
%       inpMat: double[nDim, nDim] - square matrix
%           that needs to be regularized.
%       regTol: double[1, 1] - regularization tolerance,
%           expected to be positive
%
% Output:
%   regMat: double[nDim, nDim] - regularized matrix.
%
% $Authors: Peter Gagarinov  <pgagarinov@gmail.com> $  $Date: 15-Mar-2014 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
regTol = gras.la.trytreatasreal (regTol);
modgen.common.type.simple.checkgen(regTol,...
    'isscalar(x)&&isnumeric(x)&&(x>0)');
if regTol>0
    [uMat,sMat,vMat] = svd(inpMat);
    sMat = diag(max(diag(sMat), regTol));
    regMat = uMat * sMat * vMat;
end