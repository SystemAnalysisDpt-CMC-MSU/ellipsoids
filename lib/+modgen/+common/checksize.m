function isValid=checksize(varargin)
% CHECKSIZE checks sizes of arrays;
%
% Usage isValid=checksize(arr1,arr2,arr3,siz);
%
% Input:
%   regular:
%       firstArr: any[]
%       ......
%       lastArr: any[]
%       sizeVec: double[1,nDims] - mask for check of size;
%
% Output:
%   isValid: logical[1,1] - true if all arrays is proper with
%       mask
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
isValidVec=modgen.common.isvalidsize(varargin{:});
isValid=all(isValidVec);