function isFieldsCheck(self,fieldList,isUniquenessChecked)
% ISFIELDSCHECK checks whether all fields whose names are given
% in the input list are in the field list of given object or
% not; if it is not the case, it raises exception
%
% Usage: isFieldsCheck(self,fieldList)
%
% Input:
%   regular:
%       self: CubeStruct [1,1]
%       fieldList: char or char cell [1,nFields] - input list of
%           given field names
%   optional:
%       isUniquenessChecked [1,1] - if true, exception is thrown if the
%          field list doesn't contain unique value, false by default
%     
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-08-17 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
if nargin<3
    isUniquenessChecked=false;
end
%
if isa(fieldList,'char')
    fieldList={fieldList};
end
[isFields,isUniqueFields]=self.isFields(fieldList);
if ~isFields
    throwerror('wrongInput',...
        ['field list is not specified correctly or ',...
        'not all of the specified names correspond to field names']);
end
if isUniquenessChecked&&~isUniqueFields
    throwerror('wrongInput',...
        'field names are expected to be unique');
end