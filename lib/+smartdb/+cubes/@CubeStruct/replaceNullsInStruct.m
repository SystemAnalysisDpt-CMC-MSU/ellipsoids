function [SData,SIsNull,SIsValueNull]=replaceNullsInStruct(self,...
    SData,SIsNull,SIsValueNull,...
    varargin)
% REPLACENULLSINSTRUCT replaces the values corresponding to nulls with
% the specified or default values
%
% Please note: the function takes type information from CubeStruct meta
% data by structure field type
%
% Input:
%   regular:
%       SData: struct[1,1]
%       SIsNull: struct[1,1]
%       SIsValueNull: struct[1,1]
%
%   properties:
%       nullReplacements: cell[1,nReplacedFields]  - list of null
%           replacements for each of the fields
%
%       nullReplacementFields: cell[1,nReplacedFields] - list of fields in
%          which the nulls are to be replaced with the specified values,
%          if not specified it is assumed that all fields are to be replaced
%
%          NOTE!: all fields not listed in this parameter are replaced with the
%             default values
%          NOTE!: if null replacement value from nullReplacements is scalar
%             it is automatically replicated to mach a field value size
%
% Output:
%       SData: struct[1,1]
%       SIsNull: struct[1,1]
%       SIsValueNull: struct[1,1]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-23 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%

%% Parse input parameters
[~,prop]=modgen.common.parseparams(varargin,[],0);
%
isNullReplacementSpec=false;
isNullReplacementFieldsSpec=false;
%
for k=1:2:numel(prop)-1
    switch lower(prop{k})
        case 'nullreplacements',
            isNullReplacementSpec=true;
            nullReplacementCMat=prop{k+1};
            if ~iscell(nullReplacementCMat)
                error([upper(mfilename),':wrongInput'],...
                    'nullReplacements is expected to be a cell-array');
            end
            %
        case 'nullreplacementfields',
            nullReplacementFieldList=prop{k+1};
            if ~(modgen.common.isrow(nullReplacementFieldList)&&...
                    iscellstr(nullReplacementFieldList))
                error([upper(mfilename),':wrongInput'],...
                    ['nullReplacementFields is expected to ',...
                    'be a cell row-vector of chars']);
            end
            %
            isNullReplacementFieldsSpec=true;
            %
        otherwise,
            error([upper(mfilename),':wrongInput'],...
                'property %s is unknown',prop{k});
    end
end
%% Check input property values for consistency and correctness
fieldNameList=fieldnames(SData);
nFields=numel(fieldNameList);
if isNullReplacementSpec
    if ~(ndims(nullReplacementCMat)==2&&size(nullReplacementCMat,1)<=2&&...
            size(nullReplacementCMat,1)>=1)
        error([upper(mfilename),':wrongInput'],...
            'nullReplacements is expected to have 1 or 2 rows');
    end
    %
    if isNullReplacementFieldsSpec
        if ~(modgen.common.isrow(nullReplacementFieldList)&&...
                iscellstr(nullReplacementFieldList))
            error([upper(mfilename),':wrongInput'],...
                ['nullReplacementFields is expected to be ',...
                'a row cell vector of strings']);
        end
        nReplacedFields=numel(nullReplacementFieldList);
    else
        nReplacedFields=nFields;
    end
    %
    if size(nullReplacementCMat,2)~=nReplacedFields
        error([upper(mfilename),':wrongInput'],...
            'nullReplacements is expected to have %d columns',...
            nReplacedFields);
    end
    %
elseif isNullReplacementFieldsSpec
    error([upper(mfilename),':wrongInput'],...
        ['nullReplacementFields doesn''t make ',...
        'sense without nullReplacements']);
end
%
isIsNullReplacementSpec=false;
%
if isNullReplacementSpec
    if size(nullReplacementCMat,1)==1
        nullReplacementCMat=[nullReplacementCMat;cell(1,nReplacedFields)];
    else
        isIsNullReplacementSpec=true;
    end
    %
    if isNullReplacementFieldsSpec
        [isThereVec,indLocVec]=ismember(nullReplacementFieldList,fieldNameList);
        if ~all(isThereVec)
            error([upper(mfilename),':wrongInput'],...
                'nullReplacementFields contain the unknown field names');
        end
        isReplacedByDefaultVec=true(1,nFields);
        isReplacedByDefaultVec(indLocVec)=false;
        if isNullReplacementSpec
            tmp=nullReplacementCMat;
            nullReplacementCMat=cell(2,nFields);
            nullReplacementCMat(:,indLocVec)=tmp;
        end
    else
        isReplacedByDefaultVec=false(1,nFields);
    end
else
    isReplacedByDefaultVec=true(1,nFields);
end
%

%% Extract field meta-data
fieldMetaDataVec=self.getFieldMetaData(fieldNameList);
%
minDim=self.getMinDimensionality();
%
valueSizeMat=self.getFieldValueSizeMatInternal(fieldNameList,...
    'skipMinDimensions',true,'minDimension',minDim+2,'SData',SData);
%% Check null replacement sizes and reconstruct the replacements for
%% isNull indicators if necessary
if isNullReplacementSpec
    for iField=1:nFields
        if ~isReplacedByDefaultVec(iField)
            if ~auxchecksize(nullReplacementCMat{1,iField},...
                    valueSizeMat(iField,:))
                if numel(nullReplacementCMat{1,iField})==1
                    nullReplacementCMat{1,iField}=repmat(...
                        nullReplacementCMat{1,iField},valueSizeMat(iField,:));
                else
                    error([upper(mfilename),':wrongInput'],...
                        'field %s is expected to have size %s',...
                        fieldNameList{iField},...
                        mat2str(valueSizeMat(iField,:)));
                end
            end
        end
    end
    %
    if ~isIsNullReplacementSpec
        nullReplacementCMat=[nullReplacementCMat;cell(1,nFields)];
        for iField=1:nFields
            fieldMetaDataVec(iField).checkFieldValue([false true],...
                'replaceNull',[true,false,false],nullReplacementCMat(:,iField));
            nullReplacementCMat(:,iField)=...
                fieldMetaDataVec(iField).reconstructFieldValues(...
                nullReplacementCMat(:,iField),...
                [true,false,false],[true,false]);
        end
    else
        for iField=1:nFields
            if ~isReplacedByDefaultVec(iField)
                if ~auxchecksize(nullReplacementCMat{2,iField},...
                        valueSizeMat(iField,:));
                    if numel(nullReplacementCMat{2,iField})==1
                        nullReplacementCMat{2,iField}=repmat(...
                            nullReplacementCMat{2,iField},valueSizeMat(iField,:));
                    else
                        error([upper(mfilename),':wrongInput'],...
                            'field %s is expected to have size %s',...
                            fieldNameList{iField},...
                            mat2str(valueSizeMat(iField,:)));
                    end
                end
                fieldMetaDataVec(iField).checkFieldValue([true true],...
                    'replaceNull',[true,true,false],...
                    nullReplacementCMat(:,iField));
            end
        end
    end
end
%% Replace nulls
nElems=self.getNElemsInternal('SData',SData);
for iField=1:nFields
    fieldName=fieldNameList{iField};
    isValueNullMat=SIsValueNull.(fieldName);
    indNullVec=find(isValueNullMat);
    nNulls=numel(indNullVec);
    if nNulls>0
        nValueElem=prod(valueSizeMat(iField,:));
        [indNullVec,indValueVec]=ndgrid(indNullVec,1:nValueElem);
        indVec=sub2ind([nElems,nValueElem],indNullVec(:),indValueVec(:));
        %
        if isReplacedByDefaultVec(iField)
            [SData.(fieldName)(indVec), SIsNull.(fieldName)(indVec)]=...
                fieldMetaDataVec(iField).generateDefaultFieldValue(...
                [nNulls,nValueElem],...
                'columnData',false);
        else
            %
            SData.(fieldName)(indVec)=repmat(shiftdim(...
                nullReplacementCMat{1,iField},-1),[nNulls,1]);
            %
            SIsNull.(fieldName)(indVec)=repmat(shiftdim(...
                nullReplacementCMat{2,iField},-1),[nNulls,1]);
        end
    end
end