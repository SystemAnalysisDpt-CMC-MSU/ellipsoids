function isNotDeg = ismatnotdeg( qMat, absTol)
% ISMATNOTDEG  checks if qMat is not degenerate
%
% Input:
%   regular:
%       qMat: double[nDims, nDims] - inpute matrix
%   optional:
%       absTol: double - precision of svd decomposition
%
% Output:
%   isNotDeg: logical[1,1] - true iff matrix is not degenerate
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 15-Mar-2014$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
%
import modgen.common.throwerror;
%
if nargin<2
    absTol=0;
elseif absTol<0
    throwerror('wrongInput:absTolNegative',...
        'absTol is expected to be not-negative');
end
if absTol==0
    isNotDeg=true;
else
    minSing=min(abs(svd(qMat)));
    %
    %
    if minSing<absTol
        isNotDeg=false;
    else
        isNotDeg=true;
    end
end
