function setDataInternal(self,varargin)
% SETDATAINTERNAL sets values of all cells for all fields
%
% Usage: setDataInternal(self,varargin)
%
% Input:
%   regular:
%     self: CubeStruct[1,1]
%
%   optional:
%     SData: struct [1,1] - structure with values of all cells for
%         all fields
%
%     SIsNull: struct [1,1] - structure of fields with is-null
%        information for the field content, it can be logical for
%        plain real numbers of cell of logicals for cell strs or
%        cell of cell of str for more complex types
%
%     SIsValueNull: struct [1,1] - structure with logicals
%         determining whether value corresponding to each field
%         and field cell is null or not
%
%   properties:
%       fieldNameList: cell[1,] of char[1,] - list of fields for which data
%           should be generated, if not specified, all fields from the
%           relation are taken
%
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
%       transactionSafe: logical[1,1], if true, the operation is performed
%          in a transaction-safe manner
%
%       checkStruct: logical[1,nStruct] - an array of indicators which when
%          true force checking of structure content (including presence of all
%          required fields). The first element correspod to SData, the
%          second and the third (if specified) to SIsNull and SIsValueNull
%          correspondingly
%
%       structNameList: char[1,]/cell[1,], name of data structure/list of
%         data structure names to which the function is to
%              be applied, can be composed from the following values
%
%            SData - data itself
%
%            SIsNull - contains is-null indicator information for data values
%
%            SIsValueNull - contains is-null indicators for CubeStruct cells (not
%               for cell values
%         structNameList={'SData'} by default
%
%       fieldMetaData: smartdb.cubes.CubeStructFieldInfo[1,] - field meta
%          data array which is used for data validity checking and for
%          replacing the existing meta-data
%
%       mdFieldNameList: cell[1,] of char - list of names of fields for
%          which meta data is specified
%
%       dataChangeIsComplete: logical[1,1] - indicates whether a change
%           performed by the function is complete
%
% Note: call of setData with an empty list of arguments clears
%    the data
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-21 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.type.simple.checkcellofstr;
import modgen.common.throwerror;
%
[reg,prop]=parseparams(varargin);
nReg=length(reg);
nProp=length(prop);
isConsistencyChecked=true;
isStructCheckedVecSpes=false;
isTransactionSafe=false;
isStructNameListSpec=false;
isMetaDataSpecified=false;
inpCheckArgList={};
inpSetMDArgList={};
addInpArgList={};
isMissingFieldsFilledWithNulls=false;
for k=1:2:nProp
    switch lower(prop{k})
        case 'checkconsistency',
            isConsistencyChecked=prop{k+1};
        case 'transactionsafe',
            isTransactionSafe=prop{k+1};
        case 'checkstruct'
            isStructCheckedVec=prop{k+1};
            isStructCheckedVecSpes=true;
        case 'structnamelist',
            isStructNameListSpec=true;
            structNameList=prop{k+1};
        case 'fieldmetadata',
            isMetaDataSpecified=true;
            fieldMetaData=prop{k+1};
        case 'mdfieldnamelist',
            inpCheckArgList=prop([k,k+1]);
            inpSetMDArgList=prop(k+1);
        case 'datachangeiscomplete',
            addInpArgList=prop([k,k+1]);
        case 'fillmissingfieldswithnulls',
            isMissingFieldsFilledWithNulls=prop{k+1};
        otherwise,
            throwerror('wrongInput',...
                'unknown property %s',prop{k});
    end
end
%
nConsElems=numel(isConsistencyChecked);
if nConsElems==1
    isTypeConsistencyChecked=isConsistencyChecked;
    isConsistencyChecked=[isConsistencyChecked,isConsistencyChecked];
%    
elseif nConsElems>=2
    isTypeConsistencyChecked=isConsistencyChecked(2);
elseif nConsElems>3
    throwerror('wrongInput',...
        ['checkConsistency property value is expected to have ',...
        'either 1 or 2 elements']);
end
%
if isStructNameListSpec
    structNameList=checkcellofstr(structNameList);
    commonInpArgList={'structNameList',structNameList};
else
    commonInpArgList={};
end
%
if ~isMetaDataSpecified
    if isTransactionSafe
        fieldMetaData=self.fieldMetaData.clone(self);
    else
        fieldMetaData=self.fieldMetaData;
    end
end
%
if isStructNameListSpec
    [isSpecified,indSpecVec]=ismember(self.completeStructNameList,structNameList);
    isSIsValueNullSetterUsed=isSpecified(3)&&~isSpecified(2)&&~isSpecified(1);
else
    isSpecified=false(1,3);
    isSpecified(1:nReg)=true;
    indSpecVec=1:3;
    isSIsValueNullSetterUsed=false;
end
%
inpCheckArgList=[inpCheckArgList,commonInpArgList,{'fillUnspecified',false}];
if nReg>0&&~isSIsValueNullSetterUsed
    addInpArgList=[addInpArgList,commonInpArgList];
    if isStructCheckedVecSpes
        inpCheckArgList=[inpCheckArgList,{'checkStruct',isStructCheckedVec}];
        addInpArgList=[addInpArgList,{'checkStruct',isStructCheckedVec}];
    end
    if isMissingFieldsFilledWithNulls
        dataFieldNameList=fieldnames(reg{1});
        nDataFields=length(dataFieldNameList);
        %
        if numel(fieldMetaData)>nDataFields
            mdFieldNameList=fieldMetaData.getNameList();
            isThereVec=ismember(mdFieldNameList,dataFieldNameList);
            misFieldNameList=mdFieldNameList(~isThereVec);
            nMisFields=length(misFieldNameList);
            %
            minDimensionSizeVec=self.getMinDimensionSizeByDataInternal(...
                'SData',reg{indSpecVec(1)});
        %
            [SData,SIsNull,SIsValueNull]=self.generateEmptyDataSet(...
                minDimensionSizeVec,'fieldNameList',misFieldNameList);
            %
            if isSpecified(1)
                indReg=indSpecVec(1);
                for iField=1:nMisFields
                    fieldName=misFieldNameList{iField};
                    reg{indReg}.(fieldName)=SData.(fieldName);
                end
            end
            if isSpecified(2)
                indReg=indSpecVec(2);
                for iField=1:nMisFields
                    fieldName=misFieldNameList{iField};
                    reg{indReg}.(fieldName)=SIsNull.(fieldName);
                end
            end
            if isSpecified(3)
                indReg=indSpecVec(3);
                for iField=1:nMisFields
                    fieldName=misFieldNameList{iField};
                    reg{indReg}.(fieldName)=SIsValueNull.(fieldName);
                end
            end           
        end
    end
    self.checkData(isConsistencyChecked,'replace',reg{:},...
        'fieldMetaData',fieldMetaData,inpCheckArgList{:});
end
%
self.setFieldMetaData(fieldMetaData,inpSetMDArgList{:});
%
%
if isSIsValueNullSetterUsed
    if isConsistencyChecked(1)
        sizeVec=self.getMinDimensionSize();
        fieldNameList=self.getFieldNameList();
        nFields=length(fieldNameList);
        for iField=1:nFields
            fieldName=fieldNameList{iField};
            if ~auxchecksize(reg{1}.(fieldName),sizeVec)
                throwerror('wrongInput',...
                    ['size of field %s of input SIsValueNull structure ',...
                    'is inconsistent with minimal cube size'],fieldName);
            end
        end
    end
    if ~all(cellfun('isclass',struct2cell(reg{1}),'logical'))
        throwerror('wrongInput',['all fields of SIsValueNull ',...
            'input structure are expected to have logical type']);
    end
    self.SIsValueNull=reg{1};
else
    if isTypeConsistencyChecked||self.getNElems()>0||isMetaDataSpecified
        [self.SData,self.SIsNull,self.SIsValueNull]=self.generateEmptyDataSet();
    end
    %
    if nReg>0
        self.addDataAlongDimInternal(0,reg{:},addInpArgList{:},...
            'checkConsistency',false);
    end
end
if self.getNElems()==0
    self.initByEmptyDataSet();
end
