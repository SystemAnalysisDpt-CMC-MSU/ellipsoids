function [isUniform,STypeInfo]=generatetypeinfostruct(value)
% GENERATETYPEINFOSTRUCT constructs a meta structure containing a
% complete (recursive for cells)
% information about type of input array
%
% Input: value - array of any type
% 
% Output: 
%   isUniform: logical[1,1]
%
%   STypeInfo struct[1,1] containing type information for input
%      array, contains the following fields
%   
%      type: char[1,]
%      itemTypeInfo: STypeInfo[1,]
%      isCell: logical[1,1]

%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
% [isUniform,STypeInfo]=modgen.common.type.NestedArrayType.fromValue(value);
% STypeInfo=STypeInfo.toStruct();
[isUniform,STypeInfo]=modgen.common.type.NestedArrayType.generatetypeinfostruct(value);