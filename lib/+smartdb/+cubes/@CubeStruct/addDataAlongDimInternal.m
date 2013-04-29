function addDataAlongDimInternal(self,catDimension,varargin)
% ADDDATAALONGDIMINTERNAL - adds a set of field values to existing data 
%                           using a concatenation along a specified    
%                           dimension
%
% Usage: addDataAlongDimInternal(self,catDimension,varargin)
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - class object
%       catDimension: numeric[1,1] - dimension along which a data
%          concatenation is to be performed
%       SData: struct [1,1] - structure with values of all cells for
%           all fields
%
%   optional:
%       SIsNull: struct [1,1] - structure of fields with is-null
%           information for the field content, it can be logical for
%           plain real numbers of cell of logicals for cell strs or
%           cell of cell of str for more complex types
%
%       SIsValueNull: struct [1,1] - structure with logicals
%         determining whether value corresponding to each field
%         and each cell is null or not
%
%   properties:
%       checkConsistency: logical [1,1]/[1,2] - the
%           first element defines if a consistency between the value
%           elements (data, isNull and isValueNull) is checked;
%           the second element (if specified) defines if
%           value's type is checked. If isConsistencyChecked
%           is scalar, it is automatically replicated to form a
%           two-element vector.
%           Note: default value is true
%
%       structNameList: cell[1,] of char - list of input structure names
%
%       checkStruct: logical[1,nStruct] - an array of indicators which when
%          true force checking of structure content (including presence of all
%          required fields). The first element correspod to SData, the
%          second and the third (if specified) to SIsNull and SIsValueNull
%          correspondingly
%
%       dataChangeIsComplete: logical[1,1] - indicates whether a change
%           performed by the function is complete
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.struct.*;
import modgen.common.*;
import modgen.cell.cellstr2expression;
%
if ~(isnumeric(catDimension)&&numel(catDimension)==1)
    error([upper(mfilename),':wrongInput'],...
        'catDimension is expected to be a numeric scalar');
end
%
if catDimension>self.minDimensionality||catDimension<0
    error([upper(mfilename),':wrongInput'],...
        'catDim is expected to be in range [1,minDimensionality] =[1,%d]',...
        self.minDimensionality);
end
%
[reg,prop]=modgen.common.parseparams(varargin);
if ~all(cellfun('isclass',reg,'struct'))
    error([upper(mfilename),':wrongInput'],...
        'all regular parameters are expected to be structures');
end
%
nReg=length(reg);
nProp=length(prop);
isConsistencyChecked=true;
isCheckStructSpec=false;
isDataChangeComplete=true;
isStructNameListSpec=false;
%
for k=1:2:nProp
    switch lower(prop{k})
        case 'checkconsistency',
            isConsistencyChecked=prop{k+1};
        case 'structnamelist',
            structNameList=prop{k+1};
            isStructNameListSpec=true;
        case 'checkstruct',
            isCheckStructSpec=true;
            isStructCheckedVec=prop{k+1};
        case 'datachangeiscomplete'
            isDataChangeComplete=prop{k+1};
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'unknown property %s',prop{k});
    end
end
%
if nReg==0
    error([upper(mfilename),':wrongInput'],...
        'at least one input argument is required');
end
%
if ~isStructNameListSpec
    structNameList=self.completeStructNameList(1:nReg);
else
    if ischar(structNameList)
        structNameList={structNameList};
    end
    %
    if ~auxchecksize(structNameList,[1,nReg])
        error([upper(mfilename),':wrongInput'],...
            'structNameList is expected to be of size [1,%d]',nReg);
    end
end
[isSpecified,indLoc]=ismember(self.completeStructNameList,structNameList);
if ~isSpecified(1)
    throwerror('wrongInput','SData is mandatory input argument');
end
%
nFields=self.getNFields();
%
fieldNameList=self.getFieldNameList();
isFieldSpecifiedVec=isfield(reg{indLoc(1)},fieldNameList);
if ~any(isFieldSpecifiedVec)
    return;
end
%
reg(isSpecified)=reg(indLoc(isSpecified));
reg(~isSpecified)={[]};
%
nAllStructs=length(self.completeStructNameList);
%
firstFieldSpecName=fieldNameList{find(isFieldSpecifiedVec,1,'first')};
minDimensionality=self.getMinDimensionality();
inpMinDimSizeVec=modgen.common.getfirstdimsize(...
    reg{1}.(firstFieldSpecName),minDimensionality);
%
dataValueSizeMat=self.getFieldValueSizeMat('skipMinDimensions',true);
minDimSizeVec=self.getMinDimensionSizeInternal();
%
isNotEmptySelf=minDimensionality>0&&self.getNElems()>0;
%
if ~isCheckStructSpec
    isStructCheckedVec=true(size(reg));
end
%
self.checkData(isConsistencyChecked,'add',reg{:},...
    'checkstruct',isStructCheckedVec,...
    'isStructSpecified',isSpecified,...
    'fillUnspecified',false,...
    'fieldNameList',fieldNameList(isFieldSpecifiedVec));
%
for iField=1:nFields
    fieldName=fieldNameList{iField};
    if isFieldSpecifiedVec(iField)
        if isNotEmptySelf&&...
                all(self.SIsValueNull.(fieldName)(:))
            inpValueDimSizeVec=size(reg{1}.(fieldName));
            inpValueDimSizeVec=inpValueDimSizeVec(minDimensionality+1:end);
            fieldTypeObj=self.getFieldTypeList(fieldName,'UniformOutput',true);
            [self.SData.(fieldName),...
                self.SIsNull.(fieldName),...
                self.SIsValueNull.(fieldName)]=...
                fieldTypeObj.createDefaultValueArray(...
                [minDimSizeVec,inpValueDimSizeVec]);
        end
        [value,isReconstructed]=...
            self.fieldMetaData(iField).reconstructFieldValues(...
            getstructsfield(reg,fieldName,isSpecified),...
            isSpecified,true);
        if ~all(isReconstructed)&&isConsistencyChecked
            throwerror('wrongInput',...
                'cannot reconstruct elements %s for field %s',...
                cellstr2expression(self.completeStructNameList(~isReconstructed)),...
                cellstr2expression(fieldNameList));
        end
        for iStruct=1:nAllStructs
            if isReconstructed(iStruct)&&~isSpecified(iStruct)
                reg{iStruct}.(fieldName)=value{iStruct};
            end
        end
        %
    else
        value=cell(size(self.completeStructNameList));
        sizeVec=[inpMinDimSizeVec,dataValueSizeMat(iField,:)];
        [value{:}]=self.fieldMetaData(iField).generateDefaultFieldValue(sizeVec);
        for iStruct=1:nAllStructs
            reg{iStruct}.(fieldName)=value{iStruct};
        end
    end
end
%
for iField=1:nFields
    fieldName=fieldNameList{iField};
    for iStruct=1:nAllStructs
        if isReconstructed(iStruct)
            try
                if iStruct==1
                    self.SData.(fieldName)=cat(catDimension,...
                        self.SData.(fieldName),...
                        reg{iStruct}.(fieldName));
                elseif iStruct==2
                    self.SIsNull.(fieldName)=cat(catDimension,...
                        self.SIsNull.(fieldName),...
                        reg{iStruct}.(fieldName));
                elseif iStruct==3
                    self.SIsValueNull.(fieldName)=cat(catDimension,...
                        self.SIsValueNull.(fieldName),...
                        reg{iStruct}.(fieldName));
                else
                    error([upper(mfilename),':wrongInput'],...
                        'Oops, we shouldn''t be here');
                end
            catch meObj
                if iStruct<=3
                    newMeObj=MException([upper(mfilename),':badData'],...
                        ['cannot concatenate field %s from %s along',...
                        ' dimension %d'],...
                        fieldName,self.completeStructNameList{iStruct},...
                        catDimension);
                    %
                    throw(addCause(newMeObj,meObj));
                else
                    rethrow(meObj);
                end
            end
        end
    end
end
if isDataChangeComplete
    self.changeDataPostHook();
end
end
function value=getstructsfield(reg,fieldName,isStructVec)
value=cell(size(reg));
for iStruct=1:numel(reg)
    if isStructVec(iStruct)
        value{iStruct}=reg{iStruct}.(fieldName);
    end
end
end
