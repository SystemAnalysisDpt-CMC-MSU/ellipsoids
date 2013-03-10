function isPosDef = ismatposdef( qMat, absTol)
% ISMATPOSDEF  checks if qMat is positive definite
%
% Input:
%	regular:
%       qMat: double[nDims, nDims] - inpute matrix
%       absTol: double - precision
%
% Output:
%   isPosDef: logical[1,1] - true iff matrix is positive definite
% 
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $	$Date: 2013-01-Mar$
% $Copyright: Lomonosov Moscow State University,
%             Faculty of Computational Mathematics and Cybernetics,
%             Department of System Analysis  2013 $
%
%
import modgen.common.throwerror;
%
[nRows, nCols] = size(qMat);
if (nRows~=nCols)
    throwerror('wrongInput:nonSquareMat',...
        'ISMATPOSDEF: Input matrix must be square.');
end
%
minEig=min(eig(qMat));
%
isPosDef=false;
if (minEig>absTol)
    isPosDef=true;
end


