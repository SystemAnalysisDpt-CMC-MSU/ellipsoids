function [isOk,STypeInfo]=istypesizeinfouniform(STypeSizeInfo)
% ISTYPESIZEINFOUNIFORM check the input STypeSizeInfo structure for
%   uniformity
% 
% Input: 
%   STypeSizeInfo: struct[1,1]
% 
% Output: 
%   isOk: logical[1,1] true is the input structure is uniform
%   STypeInfo: struct[1,1] - unified type info structure compiled from 
%      the input STypeSizeInfo structure by removing size information and
%      unified the type information across all the elements
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%

[isOk,STypeInfo]=modgen.common.type.istypesizeinfouniform(STypeSizeInfo);



