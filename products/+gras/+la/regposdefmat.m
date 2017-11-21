function regMat = regposdefmat(inpMat, regTol)
% REGPOSDEFMAT returns a regularized inpMat matrix.
%
% Input:
%   regular:
%       inpMat: double[nDim, nDim] - square symmetric matrix
%           that needs to be regularized.
%       regTol: double[1, 1] - regularization tolerance, added to each
%          eigen value of inpMat. regTol is expected to be positive
%
% Output:
%   regMat: double[nDim, nDim] - regularized matrix.
%
% $Authors: Kirill Mayantsev  <kirill.mayantsev@gmail.com> $  $Date: 21-04-2013 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
modgen.common.type.simple.checkgen(regTol,...
    'isscalar(x)&&isnumeric(x)&&(x>0)');
regTol = gras.la.trytreatasreal (regTol);
modgen.common.checkvar(inpMat, 'gras.la.ismatsymm(x)',...
    'errorMessage', 'matrix must be symmetric.');
[vMat, dMat] = eig(inpMat, 'nobalance');
mMat = diag(max(0,regTol-diag(dMat)));
mMat = vMat * mMat * transpose(vMat);
regMat = inpMat + mMat;
regMat = 0.5 * (regMat + regMat.');
end