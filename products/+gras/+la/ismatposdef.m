function isPosDef = ismatposdef( qMat, absTol, isFlagSemDefOn)
% ISMATPOSDEF  checks if qMat is positive definite
%
% Input:
%   regular:
%       qMat: double[nDims, nDims] - inpute matrix
%   optional:
%       absTol: double - precision of positive definiteness determination, 
%           if minimum eigenvalue of qMat 
%       isFlagSemDefOn: logical[1,1] - if true than qMat is checked for 
%                   positive semi-definiteness
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
if nargin<3
    isFlagSemDefOn=false;
    if nargin<2
        absTol=0;
    end
end
%
if ~ismatsymm(qMat)
    throwerror('wrongInput:nonSymmMat',...
        'input matrix must be symmetric');
end
%
minEig=min(eig(qMat));
%
isPosDef=false;
%
if isFlagSemDefOn
    if (minEig>=0 || abs(minEig)<absTol)
        isPosDef=true;
    end
else
    if (minEig>absTol)
        isPosDef=true;
    end
end