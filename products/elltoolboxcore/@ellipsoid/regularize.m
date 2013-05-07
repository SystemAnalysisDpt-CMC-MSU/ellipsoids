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
% $Copyright:  The Regents of the University of California 
%              2004-2008 $
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 25-04-2013$
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Department of System Analysis 2012-2013 $

regQMat = gras.la.regposdefmat(qMat, regTol);
