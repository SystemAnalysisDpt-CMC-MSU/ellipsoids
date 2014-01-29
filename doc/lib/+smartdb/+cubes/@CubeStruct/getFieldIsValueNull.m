function fieldIsNullCVec=getFieldIsValueNull(self,fieldName)
% GETFIELDISVALUENULL - returns for given field logical vector determining 
%                       whether value of this field in each cell is null
%                       or not.
%
% BEWARE OF confusing this with getFieldIsNull method which returns is-null 
%    indicators for a field content
%
% Usage: isNullVec=getFieldValueIsNull(self,fieldName)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] 
%     fieldName: char - field name
%
% Output:
%   regular:
%     isValueNullVec: logical[] - array of isValueNull indicators for the
%        specified field
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
fieldIsNullCVec=self.SIsValueNull.(fieldName);