function reorderFields(self,newFieldNameList)
% REORDERFIELDS reorders CubeStruct fields to according to 
% a specified filed list
% 
% Input:
%   regular:
%       self:
%       newFieldNameList: cell[1,nFields] of char - new order of fields
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.reorderFieldsInternal(newFieldNameList);