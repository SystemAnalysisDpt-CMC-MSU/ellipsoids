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
%                   positive semi-definiteness, DEFAULT value is false;
% Output:
%   isPosDef: logical[1,1] - true iff matrix is positive definite
%
%
% $Author: Vitaly Baranov  <vetbar42@gmail.com> $	$Date: 2013-01-Mar$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
%
%
import modgen.common.throwerror;
import gras.la.ismatsymm;
%
if nargin<3
    isFlagSemDefOn=false;
    if nargin<2
        absTol=0;
    elseif absTol<0
        throwerror('wrongInput:absTolNegative',...
            'absTol is expected to be not-negative');
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
%
isPosDef=true;
if isFlagSemDefOn
    if minEig<-absTol
        isPosDef=false;
    end
else
    if minEig<=absTol
        isPosDef=false;
    end
end