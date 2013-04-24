function regQMat = regularize(qMat, regTol)
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
regQMat = gras.la.regposdefmat(qMat, regTol);