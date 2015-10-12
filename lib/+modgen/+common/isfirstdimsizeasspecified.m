function isPositive=isfirstdimsizeasspecified(valueArr,sizeVec)
% ISFIRSTDIMSIZEASSPECIFIED check if an input value have a specified size
%   along the first dimensions
%
% Input:
% 	regular:
%   	valueArr: any[] - input array of any type
%       sizeVec: numeric[1,nDims] - expected size vec
%
% Output:
%   isPositive: logical[1,1] - true if the check is successful
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
import modgen.common.getfirstdimsize;
import modgen.common.throwerror;
%
if any(~isnumeric(sizeVec)|size(sizeVec,1)~=1|fix(sizeVec)~=sizeVec|...
        sizeVec<0|isempty(sizeVec))
    throwerror('wrongInput',...
        ['sizeVec is expected to be a row-vector of non-negative ',...
        'integer numbers']);
end
%
nDims=length(sizeVec);
isPositive=isequal(getfirstdimsize(valueArr,nDims),sizeVec);