function sizeVec=getfirstdimsize(value,nDims)
% GETFIRSTDIMSIZE returns a size vector for the first N dimensions where N
% is specified
%
% Input:
%   regular:
%       value: array[] - input value
%       nDims: numeric[1,1] - 
%
% Output:
%   sizeVec: double[1,nDims] - vector of input value sizes for the first
%      nDims dimensions
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if ~isnumeric(nDims)||numel(nDims)~=1||...
        fix(nDims)~=nDims||nDims<0
    %
    error([upper(mfilename),':wrongInput'],...
        'nDims is expected to be a scalar positive integer value');
end
%
if nDims==1
    sizeVec=size(value,1);
else
    sizeCVec=cell(1,max(ndims(value),nDims));
    [sizeCVec{:}]=size(value);
    sizeVec=[sizeCVec{1:nDims}];
end

