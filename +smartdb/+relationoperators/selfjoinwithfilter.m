function resRelObj = selfjoinwithfilter(inpRelObj,joinByFieldList,...
    filterField,filterToFieldRel,varargin)
% SELFJOINWITHFILTER performs self join of given relation and returns the
% result as new relation
%
% Usage: resRelObj=selfjoinwithfilter(inpRelObj,joinByFieldList,...
%            filterField,filterToFieldRel,varargin)
%
% Input:
%   regular:
%     inpRelObj: ARelation [1,1] - class object with relation to which self
%        join is to be applied
%     joinByFieldList: cell [1,nJoinFields] of char[1,] - list of names 
%       for fields of inpRelObj reltion by which join is performed
%     filterField: char - name of field in inpRelObj relation such that
%        tuples with different values of this field but with equal values
%        of fields from joinByFieldList are joined into single tuple so
%        that duplicates of value fields (i.e. the rest fields such that
%        their names are not equal both to filterField and to fields from
%        joinByFieldList) of inpRelObj relation corresponding to the same
%        initial field but to different tuples that are joined are
%        represented by separate fields in new relation with some new names
%     filterToFieldRel: ARelation [1,1] - class object with relation that
%        determines parameters of self join; it is assumed that
%        filterToFieldRel must contain at least fields with names given by
%        filterField, fieldNameListField and fieldDescrListField and that
%        filterField contains unique values; after join value fields 
%        corresponding to tuples in inpRelObj with filterField
%        equal to some filter index are renamed to fields whose names and
%        descriptions are given by values of fieldNameListField and
%        fieldDescrListField in filterToFieldRel for tuples such that
%        field filterField in filterToFieldRel equals this filter index
%
%   properties:
%     leadFieldList: cell[1,] of char[1,] - list of fields from the original
%       inpRelObj relation that are kept in the resulting relation
%     valueField: char[1,] - name of field value in inpRelObj, if not
%        specified it is determined automatically
%     fieldNameListField: char - name of field in filterToFieldRel that
%        determines names of value columns in the resulting relation
%     fieldDescrListField: char - name of field in filterToFieldRel that
%        determines description of each column
%     fieldOrderField: char - name of field in filterToFieldRel that is
%        used for ordering the fields in the resulting relation
%
% Output:
%   regular:
%     resRelObj: ARelation [1,1] - class object obtained from inpRelObj as
%        result of self joining
%
% Note: 1) All fields in inpRelObj are divided on three groups: fields from
%          joinByFieldList, single field filterField and value fields not
%          contained in previous two groups. It is assumed that inpRelObj
%          contains only one value field from the third group.
%       2) resRelObj contains fields from joinByFieldList and duplicates
%          of single value field renamed with respect to filterToFieldRel
%          and does not contain filterField.
%       3) It is assumed that combination of values for fields from
%          joinByFieldList and filterField uniquely determines tuples of
%          inpRelObj relation.
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-09-06 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import smartdb.relations.*;
import modgen.common.*;
%% Input parameters
[reg,prop]=parseparams(varargin);
if ~isempty(reg)
    throwerror('wrongInput',...
    ['property name-value sequence should not ',...
        'contain any regular parameters']);
end
nProp=length(prop);
isFieldNameListFieldSpec=false;
isFieldDescrListFieldSpec=false;
isFieldOrderFieldSpec=false;
isValueFieldSpec=false;
isLeadFieldsSpec=false;
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'leadfieldlist',
            leadFieldList=prop{k+1};
            isLeadFieldsSpec=true;
        case 'valuefield',
            valueField=prop{k+1};
            isValueFieldSpec=true;
        case 'fieldnamelistfield',
            fieldNameListField=prop{k+1};
            isFieldNameListFieldSpec=true;            
        case 'fielddescrlistfield'
            fieldDescrListField=prop{k+1};
            isFieldDescrListFieldSpec=true;
        case 'fieldorderfield',
            isFieldOrderFieldSpec=true;
            fieldOrderField=prop{k+1};
        otherwise,
            throwerror('wrongInput',...
                'unidentified property name: %s ',prop{k});
    end
end
%
if isValueFieldSpec
    if ~(ischar(valueField)&&modgen.common.isrow(valueField))
        throwerror('wrongInput',...
            'valueField is expected to be a character string');
    end
end
%
if isFieldOrderFieldSpec
    if ~ischar(fieldOrderField)
        throwerror('wrongInput',...
            'fieldOrderField is expected to be a string');
    end
end
%
if ~iscellstr(joinByFieldList)
    throwerror('wrongInput',...
        'joinByFieldList is expected to be a cell array of strings');
end
%
if ~ischar(filterField)
    throwerror('wrongInput',...
        'filterField is expected to be a string');
end
%
if ~isFieldNameListFieldSpec
    throwerror('wrongInput',...
        'fieldNameListField is an obligatory property');
else
    if ~ischar(fieldNameListField)
        throwerror('wrongInput',...
            'fieldNameListField is expected to be a string');
    end
    if ~isFieldDescrListFieldSpec
        fieldDescrListField=fieldNameListField;
    elseif ~ischar(fieldDescrListField)
        throwerror('wrongInput',...
            'fieldDescrListField is an obligatory property');
    end
end
%    
if (filterToFieldRel.getNTuples()==0)
    throwerror([upper(mfilename),':wrongInput'],...
        'Not empty filterToFieldRel relation expected');
end
%
%% retrieve value field
if ~isValueFieldSpec
    valueFieldList=setdiff(inpRelObj.getFieldNameList,[joinByFieldList,filterField]);
    if length(valueFieldList)~=1
        throwerror('wrongInput',...
            ['joinByFiledList and filterField parameters should be ',...
            'such that only one value field remained']);
    end
    valueField=valueFieldList{1};
else
    if any(strcmp(valueField,[joinByFieldList,filterField]))
        throwerror('wrongInput',...
            'value field cannot be among joinByFieldList or filterField');
    end
end
%    
%% check filterToField relation
%check that filter key is actually a key
if ~filterToFieldRel.isUniqueKey(filterField)
    throwerror('wrongInput', ...
        ['filterField in filterToFieldRel relation is ',...
        'expected to containt unique values']);
end
%
if isLeadFieldsSpec
    if ~(modgen.common.isrow(leadFieldList)&&iscellstr(leadFieldList))
        throwerror('wrongInput',...
            'leadFieldList is expected to be a row cell vector of strings');
    end
    if any(strcmp(leadFieldList,filterField))
        throwerror('wrongInput',...
            'leadFieldList cannot contain filterField');
    end
    if any(strcmp(leadFieldList,valueField))
        throwerror([upper(mfilename),':wrongInput'],...
            'leadFieldList cannot contain valueField');
    end
else
    leadFieldList=joinByFieldList;
end
%
%% Remove from inpRelObj records with the values of filter field not listed
%% in filterToFiled relation
filterKeyVec=filterToFieldRel.(filterField);
inpRelObj=inpRelObj.getTuplesFilteredBy(filterField,filterKeyVec);
if inpRelObj.getNTuples()==0
    throwerror('zeroColumnResult',...
        'Zero number of columns is expected in the resulting relation');
end
%
%% Get unique values for joinByFieldList
%
[~,~,~,indJoinForward,indJoinBackward]=inpRelObj.getUniqueData(...
    'fieldNameList',joinByFieldList);
%
nJoinRows=length(indJoinForward);
%
%% Determine field names for the resulting relation
%
[fieldNameList,indForwardFieldNames,indBackwardFieldNames]=unique(....
    filterToFieldRel.(fieldNameListField));
fieldNameList=transpose(fieldNameList);
if isFieldOrderFieldSpec
    fieldOrderVec=filterToFieldRel.(fieldOrderField);
    fieldOrderVec=fieldOrderVec(indForwardFieldNames);
    [~,indSortVec]=sort(fieldOrderVec);
    [~,indSortBackVec]=sort(indSortVec);
    fieldNameList=fieldNameList(indSortVec);
    indForwardFieldNames=indForwardFieldNames(indSortVec);
    indBackwardFieldNames=indSortBackVec(indBackwardFieldNames);
end
%
fieldDescrList=filterToFieldRel.(fieldDescrListField).';
fieldDescrList=fieldDescrList(indForwardFieldNames);
%
nFilterCols=length(fieldNameList);

%% Do the same for filter field
filterVec=inpRelObj.(filterField);
% FIXME - add checking for NULL
%isFilterNullVec=inpRelObj.getFieldIsNull(filterField);
%
[~,indFilterBackward]=ismember(filterVec,filterKeyVec);
indFilterBackward=indBackwardFieldNames(indFilterBackward);
%
%% Reconstruct valueMat
SValueTypeInfo=inpRelObj.getFieldTypeList(valueField,'UniformOutput',true);
%
[valueMat,isNullMat,isValueNullMat]=SValueTypeInfo.createDefaultValueArray(...
    [nJoinRows,nFilterCols],[nJoinRows,nFilterCols]);
%
%% MOST important - fill the values
indLinear=sub2ind([nJoinRows,nFilterCols],indJoinBackward,indFilterBackward);
if any(diff(sort(indLinear(:)))==0),
    throwerror('wrongInput:moreThanOneTupleWithEqualValues',...
        ['There is more than one tuple with equal values of fields ',...
        'from joinByFieldList and filterField']);
end
valueMat(indLinear)=inpRelObj.(valueField);
isNullMat(indLinear)=inpRelObj.getFieldIsNull(valueField);
isValueNullMat(indLinear)=inpRelObj.getFieldIsValueNull(valueField);
%
%% Build SData and SIsNull
%
valueVecCVec=num2cell(valueMat,1);
%
if isa(valueMat,'cell')
    valueVecCVec=num2cell(valueVecCVec,1);
end
%
valueVecCVec=[fieldNameList;valueVecCVec];
SData=struct(valueVecCVec{:});
%
IsNullVecCVec=num2cell(isNullMat,1);
%
if isa(isNullMat,'cell')
    IsNullVecCVec=num2cell(IsNullVecCVec,1);
end
%   
IsNullVecCVec=[fieldNameList;IsNullVecCVec];
SIsNull=struct(IsNullVecCVec{:});
%
isValueNullCVec=num2cell(isValueNullMat,1);
isValueNullCVec=[fieldNameList;isValueNullCVec];
SIsValueNull=struct(isValueNullCVec{:});
%
%% Add leading fields 
%FIXME use getColumns here
leadRelObj=inpRelObj.getTuples(indJoinForward);
allFieldList=inpRelObj.getFieldNameList;
fieldToRemList=setdiff(allFieldList,leadFieldList);
%this should be gone after we use getColumns
leadRelObj=smartdb.relations.DynamicRelation(leadRelObj);
leadRelObj.removeFields(fieldToRemList{:});
nLeadFields=length(leadFieldList);
%
for iField=1:nLeadFields
    fieldName=leadFieldList{iField};
    SData.(fieldName)=leadRelObj.(fieldName);
    SIsNull.(fieldName)=leadRelObj.getFieldIsNull(fieldName);
    SIsValueNull.(fieldName)=leadRelObj.getFieldIsValueNull(fieldName);
end
%
fieldDescrList=[leadRelObj.getFieldDescrList(leadFieldList) fieldDescrList];
fieldNameList=[leadFieldList fieldNameList];
%% Construct resulting relation
resRelObj=smartdb.relations.DynamicRelation(SData,SIsNull,SIsValueNull,...
    'fieldNameList',fieldNameList,'fieldDescrList',fieldDescrList);