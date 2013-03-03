function regQMat = regularize(qMat,absTol)
%
% REGULARIZE - regularization of singular symmetric matrix.
%
% Input:
%   regular:
%       qMat: double [nDim,nDim] - symmetric matrix
%       absTol: double [1,1] - absolute tolerance
%
% Output:
%	regQMat: double [nDim,nDim] - regularized qMat with
%       absTol tolerance    
%
% $Author: Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
% $Copyright:  The Regents of the University of California 2004-2008 $

modgen.common.checkvar(qMat,'gras.la.ismatsymm(x)',...
    'errorMessage','matrix must be symmetric.');

nDim = size(qMat,2);
nRank = rank(qMat);

if nRank < nDim
    [uMat, ~, ~] = svd(qMat);
    eMat = absTol * eye(nDim - nRank);
    regQMat = qMat + (uMat *...
        [zeros(nRank, nRank), zeros(nRank, (nDim-nRank));...
         zeros((nDim-nRank), nRank), eMat]* uMat');
    regQMat = 0.5*(regQMat + regQMat');
else
    regQMat = qMat;
end
