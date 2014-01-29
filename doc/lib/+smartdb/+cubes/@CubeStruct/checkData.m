function fieldMetaData=checkData(self,isConsistencyCheckedVec,actionType,varargin)
% CHECKDATA verifies CubeStruct data for consistency
%
% Input:
%   regular:
%       self: CubeStruct[1,1]
%       isConsistencyCheckedVec: logical [1,1]/[1,2]/[1,3] - 
%           the first element defines if a consistency between the value
%               elements (data, isNull and isValueNull) is checked;
%           the second element (if specified) defines if
%               value's type is checked. 
%           the third element defines if consistency between of sizes
%               between different fields is checked
%             If isConsistencyCheckedVec
%               if scalar, it is automatically replicated to form a
%                   3-element vector
%               if the third element is not specified it is assumed 
%                   to be true
%           
%       actionType: char[1,] - type of action that is going to be applied
%          to CubeStruct object using the data passed into the function.
%          The following action types are supported:
%               'add' - use it when a new piece of data is added
%                   to data already stored within CubeStruct object
%               'replace' - used when the data passed into the function is
%                  going to replace the data stored within CubeStruct object
%
%   optional:
%       SData: struct[1,1]
%       SIsNull: struct[1,1]
%       SIsValueNull: struct[1,1]
%
%  properties:
%       checkStruct: logical[1,nStruct] - an array of indicators which when
%          true force checking of structure content (including presence of all
%          required fields). The first element correspod to SData, the
%          second and the third (if specified) to SIsNull and SIsValueNull
%          correspondingly
%
%       isStructSpecified: logical[1,3] - logical vector which defines
%           which of field value structures are specified
%
%       structNameList: cell [1,nStruct] of char - list of struct names,
%           an alternative way of specifying which structures are on input
%
%       fillUnspecified: logical[1,1] - if true, the unspecified value
%          elements (SData, SIsNull and/or SIsValueNull) are filled from
%          the internal data
%
%       fieldMetaData: smartdb.cubes.CubeStructFieldInfo[1,] - field meta
%          data array to check against
%
%       fieldNameList: cell[1,] of char - list of names of fields to check
%
%       mdFieldNameList: cell[1,] of char - list of names of fields for
%          which meta data is specified
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
isMetaDataSpec=false;
[reg,prop]=modgen.common.parseparams(varargin,...
    {'checkstruct','structnamelist',...
    'isstructspecified','fillunspecified',...
    'fieldmetadata','fieldnamelist','mdfieldnamelist'});
nStruct=length(reg);
%
if nStruct>3
    throwerror('wrongInput',...
        'too many optional arguments');
end
%
if numel(isConsistencyCheckedVec)==3
    isFieldConsistencyChecked=isConsistencyCheckedVec(3);
    isDataConsistencyCheckedVec=isConsistencyCheckedVec(1:2);
else
    if numel(isConsistencyCheckedVec)==2
        isFieldConsistencyChecked=true;
    else
        isFieldConsistencyChecked=isConsistencyCheckedVec(1);
    end
    isDataConsistencyCheckedVec=isConsistencyCheckedVec;
end
    
%
isStructCheckedVec=true(1,nStruct);
isStructSpecifiedSpec=false;
isFieldNamesSpec=false;
isMDFieldNamesSpec=false;
nProp=length(prop);
addArgList={};
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'checkstruct',
            isStructCheckedVec=prop{k+1};
            if size(isStructCheckedVec,1)~=1||...
                    numel(isStructCheckedVec)<nStruct||...
                    ~islogical(isStructCheckedVec)
                throwerror('wrongInput',...
                    ['isStructChecked is expected to be a ',...
                    'logical raw-vector with %d elements'],...
                    nStruct);
            end
        case 'isstructspecified',
            addArgList=[addArgList,prop([k,k+1])];
            isStructSpecifiedSpec=true;
            isStructSpecifiedVec=prop{k+1};
            
        case {'structnamelist','fillunspecified'}
            addArgList=[addArgList,prop([k,k+1])];
        case 'fieldmetadata',
            isMetaDataSpec=true;
            fieldMetaData=prop{k+1};
        case 'fieldnamelist',
            isFieldNamesSpec=true;
            fieldNameList=prop{k+1};
        case 'mdfieldnamelist',
            isMDFieldNamesSpec=true;
            mdFieldNameList=prop{k+1};
        otherwise
            throwerror('wrongInput',...
                'unknown property: %s',prop{k});
    end
end
if ~isStructSpecifiedSpec
    isStructSpecifiedVec=true(1,nStruct);
end
% OPTIMIZATION !!!!!!------------
if any(isDataConsistencyCheckedVec)||any(isStructCheckedVec)
    %
    isOkVec=cellfun('isclass',reg,'struct');
    isOkVec=isOkVec&cellfun('prodofsize',reg)==1;
    isOkVec=isOkVec|~isStructSpecifiedVec;
    %
    if ~all(isOkVec)
        throwerror('wrongInput',...
            'optional arguments are expected to be the scalar structures');
    end
    %
    if isMDFieldNamesSpec&&~isMetaDataSpec
        throwerror('wrongInput',...
            ['mdFieldMetaData doesn''t make sense ',...
            'when no fieldMetaData is specified']);
    end
    %
    if ~isMetaDataSpec
        if isFieldNamesSpec
            fieldMetaData=self.getFieldMetaData(fieldNameList);
        else
            fieldMetaData=self.fieldMetaData;
        end
        if isMDFieldNamesSpec
            throwerror('wrongInput',...
                ['mdFieldMetaData doesn''t make sense ',...
                'when no fieldMetaData is specified']);
        end
    end
    %
    if ~isMDFieldNamesSpec
        mdFieldNameList=fieldMetaData.getNameList();
    end
    %
    if ~isFieldNamesSpec
        fieldNameList=mdFieldNameList;
    end
    %
    if isMetaDataSpec&&~isequal(fieldNameList,mdFieldNameList)
        [isThereVec,indLocVec]=ismember(fieldNameList,mdFieldNameList);
        %
        fieldMetaData(isThereVec)=fieldMetaData(indLocVec);
        if ~all(isThereVec)
            fieldMetaData(~isThereVec)=...
                self.getFieldMetaData(fieldNameList(~isThereVec));
        end
    end
    %
    indLastSpec=find(isStructSpecifiedVec,1,'last');
    stFieldNameList=fieldnames(reg{indLastSpec});
    for iStruct=1:indLastSpec
        if ~isStructSpecifiedVec(iStruct)
            stArgList=[stFieldNameList,cell(size(stFieldNameList))].';
            reg{iStruct}=struct(stArgList{:});
        end
    end
    nStruct=indLastSpec;
    %
    if isFieldNamesSpec
        checkStructArgList={fieldNameList};
    else
        if isMetaDataSpec
            checkStructArgList={mdFieldNameList};
        else
            checkStructArgList={};
        end
    end
    for iStruct=1:nStruct
        if isStructCheckedVec(iStruct)
            self.checkStruct(reg{iStruct},isFieldConsistencyChecked,...
                checkStructArgList{:});
        end
    end
    %
    if nStruct>=1
        nFields=length(fieldNameList);
        switch nStruct
            case 1
                for iField=1:nFields
                    fieldName=fieldNameList{iField};
                    self.checkFieldValue(isDataConsistencyCheckedVec,fieldName,...
                        actionType,{reg{1}.(fieldName)},...
                        'fieldMetaData',fieldMetaData(iField),addArgList{:});
                end
            case 2
                for iField=1:nFields
                    fieldName=fieldNameList{iField};
                    self.checkFieldValue(isDataConsistencyCheckedVec,fieldName,...
                        actionType,{reg{1}.(fieldName),...
                        reg{2}.(fieldName)},...
                        'fieldMetaData',fieldMetaData(iField),addArgList{:});
                end
            case 3
                for iField=1:nFields
                    fieldName=fieldNameList{iField};
                    self.checkFieldValue(isDataConsistencyCheckedVec,fieldName,...
                        actionType,{reg{1}.(fieldName),...
                        reg{2}.(fieldName),reg{3}.(fieldName)},...
                        'fieldMetaData',fieldMetaData(iField),addArgList{:});
                end
        end
    end
end