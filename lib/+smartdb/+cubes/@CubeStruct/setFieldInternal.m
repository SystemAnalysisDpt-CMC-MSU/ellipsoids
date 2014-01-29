function setFieldInternal(self,fieldName,varargin)
% SETFIELDINTERNAL sets values of all cells for given field
%
% Usage: setFieldInternal(self,fieldName,value)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
%     fieldName: char - name of field
%     value: array [] of some type - field values
%
%   optional:
%     isNull: logical/cell[]
%     isValueNull: logical[]
%
%   properties:
%     structNameList: list of internal structures to return (by default it
%       is {SData, SIsNull, SIsValueNull}
%
%     inferIsNull: logical[1,2] - the first (second) element = false
%       means that IsNull (IsValueNull) indicator for a field 
%           in question is kept intact (default = [true,true])
%
%       Note: if structNameList contains 'SIsValueNull' entry, 
%        inferIsValueNull parameter is overwritten by false
%       
%     checkFieldValueSize: logical[1,1] - positive value enforces a size
%        checking
%       
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-04-27 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
VALUE_PART_NAME_LIST={'[value]','[isNull]','[isValueNull]'};
%
import modgen.common.throwerror;
if nargin<3
    throwerror(':wrongInput',...
        'at least 2 input arguments apart from the class object are expected');
end
%
if ~ischar(fieldName)||size(fieldName,1)~=1
    throwerror('wrongInput',...
    'fieldName is expected to be a string of size [1,]');
end
%
[reg,prop]=modgen.common.parseparams(varargin);
nProp=length(prop);
nReg=length(reg);
%
isFieldValueSizeChecked=true;
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'inferisnull',
            isNullInferred=prop{k+1};
        case 'structnamelist',
            structNameList=prop{k+1};
        case 'checkfieldvaluesize',
            isFieldValueSizeChecked=prop{k+1};
        otherwise,
            throwerror('wrongInput',...
                'unidentified property name: %s ',prop{k});
    end;
end;
%
if ~modgen.system.ExistanceChecker.isVar('structNameList')
    structNameList=self.completeStructNameList(1:nReg);
else
    if ischar(structNameList)
        structNameList={structNameList};
    end
    %
    if ~auxchecksize(structNameList,[1,nReg])
        throwerror('wrongInput',...
            'structNameList is expected to be of size [1,%d]',nReg);
    end
end
%
if isFieldValueSizeChecked
    [isnWrongList,errMsgList]=cellfun(@(x)(self.isFieldSizeValid(x)),reg,...
        'UniformOutput',false);
    isnWrongVec=[isnWrongList{:}];
    if ~all(isnWrongVec),
        errMsgPrefix=sprintf('field %s doesn''t have expected size',...
            fieldName);
        errMsgBodyList=strcat(...
            VALUE_PART_NAME_LIST(~isnWrongVec).',':',...
            errMsgList(~isnWrongVec).',sprintf('\n'));
        errMsg=[errMsgPrefix,sprintf(':\n\t'),...
            modgen.string.catwithsep(errMsgBodyList,sprintf('\t'))];
        throwerror('wrongInput',errMsg);
    end
end
%
[isSpecified,indLoc]=ismember(self.completeStructNameList,structNameList);
if ~any(isSpecified)
    throwerror('wrongInput',...
        'at least one structure should be specified');
end
%
if modgen.system.ExistanceChecker.isVar('isNullInferred')
    if ~islogical(isNullInferred)||...
            (numel(isNullInferred)<1)||(numel(isNullInferred)>2)
        throwerror('wrongInput',...
            ['inferIsNull property is expected to have a logical ',...
            'value and have 1 or 2 elements']);
    end
else
    isNullInferred=true;
end
%
reg(isSpecified)=reg(indLoc(isSpecified));
reg(~isSpecified)={[]};
%
%check value type first as it can be different from the current field type
%
fieldMetaData=self.getFieldMetaData(fieldName).clone(self);
self.checkFieldValue([false true],fieldName,...
    'replace',reg,'isStructSpecified',isSpecified,...
    'fieldMetaData',fieldMetaData);
%
%use adjusted field type to reconstruct the missing field value components
%
[reg,isReconstructed]=fieldMetaData.reconstructFieldValues(reg,...
    isSpecified,isNullInferred);
%
if ~isReconstructed(1)
    reg{1}=self.SData.(fieldName);
end
if ~isReconstructed(2)
    reg{2}=self.SIsNull.(fieldName);
end
if ~isReconstructed(3)
    reg{3}=self.SIsValueNull.(fieldName);
end
%
try
    %check field element size consistency
    self.checkFieldValue([true false],fieldName,'replace',reg,...
        'fieldMetaData',fieldMetaData);
catch meObj
    if ~isempty(findstr(meObj.identifier,':wrongInput'))
        newMeObj=MException([upper(mfilename),':wrongInput'],...
            ['inputs are inconsistent, try setting elements of ',...
            'inferIsNull property to true']);
        newMeObj=newMeObj.addCause(meObj);
        throw(newMeObj);
    else
        rethrow(meObj);
    end
end
%
self.setFieldMetaData(fieldMetaData,fieldName);
%
for iStruct=1:3
    if isReconstructed(iStruct)
        structName=self.completeStructNameList{iStruct};
        self.(structName).(fieldName)=reg{iStruct};
    end
end



