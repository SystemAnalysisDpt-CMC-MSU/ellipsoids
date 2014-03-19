function isSymm = ismatsymm(qMat,varargin)
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
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $ $Date: 2014-03-19$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012-2014 $
%

import modgen.common.throwerror;
[nRows, nCols] = size(qMat);
if (nRows~=nCols)
    throwerror('wrongInput:nonSquareMat',...
        'ISMATSYMM: Input matrix must be square.');
end
nVarargs = length(varargin);
if (nVarargs >1)
    throwerror('TooManyInputs',...
        'ISMATSYMM: Too many input arguments');
elseif (nVarargs == 1)
    absTol = varargin{1};
else
    absTol = 0;
end
isSymm=modgen.common.absrelcompare(qMat,transpose(qMat),absTol,[],@abs);