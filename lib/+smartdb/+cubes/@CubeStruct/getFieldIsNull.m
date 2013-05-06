function fieldIsNullCVec=getFieldIsNull(self,fieldName)
% GETFIELDISNULL - returns for given field a nested logical/cell array 
%                  containing is-null indicators for cell content
%
% Usage: fieldIsNullCVec=getFieldIsNull(self,fieldName)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] 
%     fieldName: char - field name
% Output:
%   regular:
%     fieldIsCVec: logical/cell[] - nested cell/logical array containing 
%        is-null indicators for content of the field
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.checkIfObjectScalar();
if ~isa(fieldName,'char')
    error([upper(mfilename),':wrongInput'],...
        'field name should be of type char');
end
fieldIsNullCVec=self.SIsNull.(fieldName);