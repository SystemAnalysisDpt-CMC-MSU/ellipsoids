function clearFieldsAsProps(self,clearFieldNameList)
% CLEARFIELDSASPROPS deletes properties corresponding to fields
% of a given object
%
% Usage: clearFieldsAsProps(self)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] - class object
%   optional:
%     clearFieldNameList: char or char cell [1,nClearFields] -
%         name of fields for which properties must be cleared
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

if nargin<2,
    clearFieldNameList=self.fieldNameList;
end
if ischar(clearFieldNameList),
    clearFieldNameList={clearFieldNameList};
end
nFields=length(clearFieldNameList);
for iField=1:nFields
    fieldName=clearFieldNameList{iField};
    p=findprop(self,fieldName);
    if ~isempty(p),
        delete(p);
    end
end