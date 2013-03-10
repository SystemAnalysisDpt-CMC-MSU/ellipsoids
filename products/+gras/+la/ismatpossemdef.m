function isPosSemDef = ismatpossemdef( qMat, absTol)
% ISMATPOSSEMDEF  checks if qMat is positive semi-definite
%
% Input:
%	regular:
%       qMat: double[nDims, nDims] - inpute matrix
%       absTol: double - precision
%
% Output:
%   isPosDef: logical[1,1] - true iff matrix is positive semi-definite
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
        'ISMATPOSSEMDEF: Input matrix must be square.');
end

minEig=min(eig(qMat));

isPosSemDef=false;
if (minEig>=0 || abs(minEig)<absTol)
    isPosSemDef=true;
end


