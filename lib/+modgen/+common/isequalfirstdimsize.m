function isPositive=isequalfirstdimsize(valueA,valueB,nDims)
% ISEQUALFIRSTDIMSIZE checks if the specified arrays have the same size
% along the first N dimensions where N is specified
%
% Input:
%   regular:
%       valueA: array[] - first array
%       valueB: array[] - second array
%       nDims: double[1,1] - number of dimensions
%
% Output: 
%       isPositive: logical[1,1] - true if the check is successfull
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

import modgen.common.*;
if ~isnumeric(nDims)||numel(nDims)~=1||fix(nDims)~=nDims||nDims<=0
    error([upper(mfilename),':wrongInput'],...
        'nDims is expected to be a scalar positive integer value');
end
%
isPositive=isequal(getfirstdimsize(valueA,nDims),...
    getfirstdimsize(valueB,nDims));