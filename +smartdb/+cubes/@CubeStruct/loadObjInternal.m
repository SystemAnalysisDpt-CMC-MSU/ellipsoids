function loadObjInternal(self,SObjectData,varargin)
% LOADOBJINTERNAL updates properties of given CubeStruct object
% object from structure containing its internal representation
%
% Usage: loadObjInternal(self,SObjectData)
%
% Input:
%   regular:
%     self: CubeStruct [n_1,...,n_k]
%     SObjectData: struct [n_1,...,n_k] - structure containing an internal
%        representation of the object
%     
%   optional:
%     fieldNameList: cell[1,nFields] - list of fields to copy
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-21 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
for iElem=1:numel(self)
    loadScalarObj(self(iElem),SObjectData(iElem),varargin{:});
end
end
%
function loadScalarObj(self,SObjectData,varargin)
import modgen.common.throwerror;
[~,~,fieldNameList,isMissingFieldsFilledWithNulls,...
    isFieldNameSpec,isFillMissingFieldsWithNullsSpec]=...
    modgen.common.parseparext(varargin,...
    {'fieldNameList','fillMissingFieldsWithNulls';...
    {},false},0);
if ~isfield(SObjectData,'minDimensionality')
    if isempty(self.minDimensionality)
        error([mfilename,':wrongInput'],...
            'minDimensionality field is obligatory');
    end
else
    self.minDimensionality=SObjectData.minDimensionality;
end
%
if ~isFieldNameSpec
    self.SIsNull=SObjectData.SIsNull;
    if isfield(SObjectData,'SIsValueNull')
        self.SIsValueNull=SObjectData.SIsValueNull;
    else
        self.SIsValueNull=struct();
    end
    self.SData=SObjectData.SData;
elseif ~isempty(fieldNameList)
    %
    isFieldVec=isfield(SObjectData.SData,fieldNameList)&...
        isfield(SObjectData.SIsNull,fieldNameList)&...
        isfield(SObjectData.SIsValueNull,fieldNameList);
    %
    if ~(all(isFieldVec)||isMissingFieldsFilledWithNulls)
        throwerror('wrongInput',...
            'not enough fields in the data structures');
    end
    existFieldList=fieldNameList(isFieldVec);
    nExistFields=length(existFieldList);
    %filling existing fields
    for iField=1:nExistFields
        fieldName=existFieldList{iField};
        self.SData.(fieldName)=SObjectData.SData.(fieldName);
        self.SIsNull.(fieldName)=SObjectData.SIsNull.(fieldName);
        self.SIsValueNull.(fieldName)=SObjectData.SIsValueNull.(fieldName);
    end
    %filling not existing fields
    %
    notExistFieldList=fieldNameList(~isFieldVec);
    nNotExistFields=length(notExistFieldList);
    %
    minDimensionSizeVec=self.getMinDimensionSizeByDataInternal(...
        'SData',SObjectData.SData);
    %
    [SData,SIsNull,SIsValueNull]=self.generateEmptyDataSet(minDimensionSizeVec,...
        'fieldNameList',notExistFieldList);
    %
    for iField=1:nNotExistFields
        fieldName=notExistFieldList{iField};
        self.SData.(fieldName)=SData.(fieldName);
        self.SIsNull.(fieldName)=SIsNull.(fieldName);
        self.SIsValueNull.(fieldName)=SIsValueNull.(fieldName);
    end
    %
    indNotExistVec=find(~isFieldVec);
    indExistVec=find(isFieldVec);
    %
end
%
if ~isfield(SObjectData,'fieldMetaData')
    self.inferFieldMetaData();
elseif ~isa(SObjectData.fieldMetaData,'smartdb.cubes.CubeStructFieldInfo')
    warning([mfilename,':badFieldMetaData'],...
        ['fieldMetaData field was loaded ',...
        'incorrectly, inferring it from data...']);
    self.inferFieldMetaData();
else
    if ~isFieldNameSpec
        self.fieldMetaData=SObjectData.fieldMetaData.clone(self);
    elseif ~isempty(fieldNameList)
        fieldMetaData=[...
            self.fieldMetaData.filterByName(notExistFieldList),...
            SObjectData.fieldMetaData.filterByName(existFieldList).clone(self)];
        [~,indVec]=sort([indNotExistVec,indExistVec]);
        self.fieldMetaData=fieldMetaData(indVec);
    end
end
%
if self.getNElems()==0
    self.initByEmptyDataSet();
end
self.defineFieldsAsProps();
end