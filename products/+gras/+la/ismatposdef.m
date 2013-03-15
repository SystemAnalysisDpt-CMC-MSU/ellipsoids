function isPosDef = ismatposdef( qMat, absTol, flagSemDef)
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
import gras.la.ismatsymm;
%
if ~ismatsymm(qMat)
    throwerror('wrongInput:nonSymmMat',...
        'ISMATPOSDEF: Input matrix must be symmetric');
end
%
minEig=min(eig(qMat));
%
isPosDef=false;
if nargin<3
    flagSemDef=0;
end
if flagSemDef
    if (minEig>=0 || abs(minEig)<absTol)
        isPosDef=true;
    end
else
    if (minEig>absTol)
        isPosDef=true;
    end
end



