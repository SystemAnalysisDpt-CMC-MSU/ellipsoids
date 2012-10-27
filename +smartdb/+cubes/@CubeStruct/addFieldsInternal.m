function addFieldsInternal(self,addFieldNameList,varargin)
% ADDFIELDSINTERNAL adds new fields to a given CubeStruct object
%
% Usage: addFieldsInternal(self,addFieldNameList,addFieldDescrList)
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - class object
%       addFieldNameList: char or char cell [1,nAddFields] - names of fields
%           to be added
%   optional:
%       addFieldDescrList: char or char cell [1,nAddFields] - descriptions of
%           fields to be added
%
%   properties:
%       typeSpecList: cell[1,nAddFields] - type specifications for the
%          added fields
%   
%       sourceFieldNameList: cell[1,nAddFields] of char[1,] - source 
%           field name list that defines a field from which the values 
%           and copied from, if both typeSpecList and sourceFieldNameList 
%           is specified, sourceFieldNameList has the first priority, 
%           empty entries in sourceFieldNameList mean that 
%           the corresponding field has no source field
%
%       addInFront: logical[1,1]- if true, fields are added in front of the
%           relation, otherwise they are added to the back of the 
%           field list 
%              default value is false
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.type.simple.*;
import modgen.common.throwerror;
%
[reg,prop]=modgen.common.parseparams(varargin,...
    {'typeSpecList','addInFront','sourceFieldNameList'},[0,1]);
if ischar(addFieldNameList),
    addFieldNameList={addFieldNameList};
end
if ~iscellstr(addFieldNameList),
    throwerror('wrongInput',...
        'addFieldNameList must be char or char cell array');
end
%
if ~auxchecksize(addFieldNameList,[1 nan])
    throwerror('wrongInput',...
        ['addFieldNameList is expected to be of size [1, ]',...
        'i.e. vector-string']);
end
%
nAddFields=length(addFieldNameList); 
if ~isempty(reg)
    addFieldDescrList=reg{1};
    if ischar(addFieldDescrList),
        addFieldDescrList={addFieldDescrList};
    end
    if ~auxchecksize(addFieldDescrList,[1 nan])
        throwerror('wrongInput',...
            ['addFieldDescrList is expected to be of size [1, ]',...
            'i.e. vector-string']);
    end

    if ~iscellstr(addFieldDescrList),
        throwerror('wrongInput',...
            'addFieldDescrList must be char or char cell array');
    end
    if length(addFieldDescrList)~=nAddFields,
        throwerror('wrongInput',...
            ['addFieldNameList and addFieldDescrList are not ',...
            'consistent in length']);
    end
else
    addFieldDescrList=addFieldNameList;
end
if any(self.getIsFieldVec(addFieldNameList)),
    throwerror('wrongInput',...
        'some of added fields are already in the list of object fields');
end
%
isTypeSpecListSpec=false;
isSourceFieldNameSpec=false;
nProps=length(prop);
isAddedInFront=false;
for k=1:2:nProps-1
    switch lower(prop{k})
        case 'typespeclist',
            typeSpecList=prop{k+1};
            isTypeSpecListSpec=true;
        case 'addinfront',
            isAddedInFront=prop{k+1};
            if ~(islogical(isAddedInFront)&&numel(isAddedInFront)==1)
                error([upper(mfilename),':wrongInput'],...
                    'addInFront is expected to be a logical scalar');
            end
        case 'sourcefieldnamelist',
            isSourceFieldNameSpec=true;
            checkgen(prop{k+1},@(x)lib.isrow(x)&&...
                all(cellfun('isclass',x,'char')|cellfun('isempty',x)));
            sourceFieldNameList=prop{k+1};
    end
end
%
if ~isTypeSpecListSpec
    typeSpecList=repmat({{char.empty(1,0)}},1,nAddFields);
end
if ~isSourceFieldNameSpec
    sourceFieldNameList=cell(1,nAddFields);
end
if ~isequal(size(typeSpecList),size(sourceFieldNameList))
    throwerror('wrongInput',...
        ['typeSpecList and sourceFieldNameList properties are ',...
        'expected to be of the same size']);
end
%
isnEmptySourceVec=~cellfun('isempty',sourceFieldNameList);
typeSpecList(isnEmptySourceVec)=...
    self.getFieldTypeSpecList(sourceFieldNameList(isnEmptySourceVec));
addFieldDescrList(isnEmptySourceVec)=...
    self.getFieldDescrList(sourceFieldNameList(isnEmptySourceVec));
%
newMetaDataVec=smartdb.cubes.CubeStructFieldInfo.customArray(...
    self,addFieldNameList,addFieldDescrList,typeSpecList);
%
for iField=1:nAddFields,
    fieldName=addFieldNameList{iField};
    if isnEmptySourceVec(iField)
        sourceFieldName=sourceFieldNameList{iField};
        self.SData.(fieldName)=self.SData.(sourceFieldName);
        self.SIsNull.(fieldName)=self.SIsNull.(sourceFieldName);
        self.SIsValueNull.(fieldName)=self.SIsValueNull.(sourceFieldName);
    else
        [valueVec,isNullVec,isValueNullVec]=...
            newMetaDataVec(iField).generateDefaultFieldValue();
        self.SData.(fieldName)=valueVec;
        self.SIsNull.(fieldName)=isNullVec;
        self.SIsValueNull.(fieldName)=isValueNullVec;
    end
end
if isAddedInFront
    self.fieldMetaData=[newMetaDataVec,self.fieldMetaData];
else
    self.fieldMetaData=[self.fieldMetaData,newMetaDataVec];
end
%
%clear field definitions as properties and then recreate them
self.clearFieldsAsProps();
self.defineFieldsAsProps();