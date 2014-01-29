function setField(self,varargin)
% SETFIELDINTERNAL - sets values of all cells for given field
%
% Usage: setFieldInternal(self,fieldName,value)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
%     fieldName: char - name of field
%     value: array [] of some type - field values
%
%   optional:
%     isNull: logical/cell[]
%     isValueNull: logical[]
%
%   properties:
%     structNameList: list of internal structures to return (by default it
%       is {SData, SIsNull, SIsValueNull}
%
%     inferIsNull: logical[1,2] - the first (second) element = false
%       means that IsNull (IsValueNull) indicator for a field in question 
%           is kept intact (default = [true,true])
%
%       Note: if structNameList contains 'SIsValueNull' entry, 
%        inferIsValueNull parameter is overwritten by false
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.prohibitProperty('checkFieldValueSize',varargin);
%
if self.getNFields()==1
    isFieldValueSizeChecked=false;
else
    isFieldValueSizeChecked=true;
end
%
self.setFieldInternal(varargin{:},...
    'checkFieldValueSize',...
    isFieldValueSizeChecked);
end