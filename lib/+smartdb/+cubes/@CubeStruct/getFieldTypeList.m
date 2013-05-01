function typeInfoList=getFieldTypeList(self,varargin)
% GETFIELDTYPELIST - returns list of field types in given CubeStruct object
%
% Usage: fieldTypeList=getFieldTypeList(self)
%
% Input:
%   regular:
%       self: CubeStruct [1,1] 
%
%   optional:
%       fieldNameList: cell[1,nFields] - list of field names
%
% Output:
%  regular:
%   fieldTypeList: cell [1,nFields] of smartdb.cubes.ACubeStructFieldType[1,1]
%       - list of field types
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-25 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
self.checkIfObjectScalar();
import modgen.common.throwerror;
%
isUniformOutput=false;
[reg,prop]=modgen.common.parseparams(varargin);
if numel(reg)>1
    throwerror('wrongInput','too many regular arguments');
elseif numel(reg)==1
    fieldNameList=reg{1};
    if ischar(fieldNameList)
        fieldNameList={fieldNameList};
    end
else
    fieldNameList=self.getFieldNameList;
end
%
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'uniformoutput',
            isUniformOutput=prop{k+1};
    end
end
%
fullFieldNameList=self.getFieldNameList();
fieldTypeList=self.fieldMetaData.getTypeList();
%
if ~isempty(fieldNameList)
    [~,indLoc]=ismember(fieldNameList,fullFieldNameList);
    typeInfoList=fieldTypeList(indLoc);
    if isUniformOutput
        typeInfoList=[typeInfoList{:}];
    end
else
    if isUniformOutput
        typeInfoList=self.fieldMetaData.getDefaultTypeByCubeStructRef(...
            self,size(fieldNameList));
    else
       typeInfoList=cell.empty(size(fieldNameList)); 
    end
end
        