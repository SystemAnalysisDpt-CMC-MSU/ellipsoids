function valueMat=createarraybytypeinfo(STypeInfoInp,sizeInpVec)
% CREATEARRAYBYTYPEINFO creates an array of STypeInfo structure
%
% Input:
%   regular:
%       STypeInfo: struct[1,1] - structure containing type information 
%       sizeInpVec: double [1,nDims] - size of the array to be created
%
%   properties:
%       createIsNull: logical[1,2] - depending on whether the first element
%          is true, an array for the value field (false) or an array for isNull
%          indicator field (true) is created. In the latter case the second
%          element specified a value of isNull indicator
%   
% Output: 
%   valueMat: requested type of size specified by sizeInpVec parameter
%   
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
STypeInfoInp=modgen.common.type.NestedArrayType.fromStruct(STypeInfoInp);
valueMat=STypeInfoInp.createDefaultArray(sizeInpVec);