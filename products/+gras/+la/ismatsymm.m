function isSymm = ismatsymm(qMat)
% ISMATSYMM  checks if qMat is symmetric
%
% Input:
%	regular:
%       qMat: double[nDims, nDims]
%
% Output:
%   isSymm: logical[1,1] - indicates whether a matrix is symmetric.
% 
%
% $Author: Rustam Guliev  <glvrst@gmail.com> $	$Date: 2012-16-11$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%

import modgen.common.throwerror;
[nRows, nCols] = size(qMat);
if (nRows~=nCols)
    throwerror('wrongInput:nonSquareMat',...
        'ISMATSYMM: Input matrix must be square.');
end
isSymm=false;
if (all(all(qMat == transpose(qMat))))
    isSymm=true;
end

