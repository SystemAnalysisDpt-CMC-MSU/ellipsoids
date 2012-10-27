function varargout=getDataInternal(self,varargin)
% GETDATAINTERNAL returns an indexed projection of CubeStruct object's
% content
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - the object
%
%   optional:
%
%       subIndCVec: 
%         Case#1: numeric[1,]/numeric[,1] 
%   
%         Case#2: cell[1,nDims]/cell[nDims,1] of double [nSubElem_i,1] 
%               for i=1,...,nDims 
%       
%           -array of indices of field value slices that are selected
%           to be returned; if not given (default), 
%           no indexation is performed
%       
%         Note!: numeric components of subIndVec are allowed to contain
%            zeros which are be treated as they were references to null
%            data slices
%
%       dimVec: numeric[1,nDims]/numeric[nDims,1] - vector of dimension 
%           numbers corresponding to subIndCVec
%
%   properties:
%
%       fieldNameList: char[1,]/cell[1,nFields] of char[1,]  
%           list of field names to return
%
%       structNameList: char[1,]/cell[1,nStructs] of char[1,] 
%           list of internal structures to return (by default it
%           is {SData, SIsNull, SIsValueNull}
%
%       replaceNull: logical[1,1] if true, null values are replaced with 
%           certain default values uniformly across all the cells, 
%               default value is false
%
%       nullReplacements: cell[1,nReplacedFields]  - list of null
%           replacements for each of the fields
%
%       nullReplacementFields: cell[1,nReplacedFields] - list of fields in
%          which the nulls are to be replaced with the specified values,
%          if not specified it is assumed that all fields are to be replaced
%
%          NOTE!: all fields not listed in this parameter are replaced with the
%          default values
%
%       checkInputs: logical[1,1] - true by default (input arguments are
%          checked for correctness
%
% Output:
%   regular:
%     SData: struct [1,1] - structure containing values of
%         fields at the selected slices, each field is an array
%         containing values of the corresponding type
%
%     SIsNull: struct [1,1] - structure containing a nested
%         array with is-null indicators for each CubeStruct cell content
%
%     SIsValueNull: struct [1,1] - structure containing a
%        logical array [] for each of the fields (true
%        means that a corresponding cell doesn't not contain
%           any value
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-23 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
import modgen.system.ExistanceChecker;
%% parse input params
[reg,prop]=modgen.common.parseparams(varargin,[],[0 2]);
nReg=length(reg);
%
isNullReplaced=false;
isFieldNameListSpec=false;
replaceNullArgList={};
isStructNameListSpec=false;
isInputsChecked=true;
%
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'checkinputs',
            isInputsChecked=prop{k+1};
            if ~(islogical(isInputsChecked)&&numel(isInputsChecked)==1)
                error([upper(mfilename),':wrongInput'],...
                    ['isInputsChecked is expected to a scalar ',...
                    'logical value']);
            end
            %
            prop([k k+1])=[];
            nProp=length(prop);
            break;
    end
end
%% continue parsing
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'checkinputs',
            isInputsChecked=prop{k+1};
            if ~(islogical(isInputsChecked)&&numel(isInputsChecked)==1)
                error([upper(mfilename),':wrongInput'],...
                    ['isInputsChecked is expected to a scalar ',...
                    'logical value']);
            end
        case 'fieldnamelist',
            fieldNameList=prop{k+1};
            if ischar(fieldNameList)
                fieldNameList={fieldNameList};
            end
            if isInputsChecked
                self.isFieldsCheck(fieldNameList,true);
            end
            isFieldNameListSpec=true;
        case 'structnamelist',
            structNameList=prop{k+1};
            if ischar(structNameList)
                structNameList={structNameList};
            end
            %
            if isInputsChecked
                self.checkStructNameList(structNameList,true);
            end
            %
            if length(structNameList)<nargout
                error([upper(mfilename),':wrongInput'],...
                    'incorrect number of output arguments');
            end
            isStructNameListSpec=true;
        case 'replacenull',
            isNullReplaced=prop{k+1};
        case {'nullreplacements','nullreplacementfields'},
            isNullReplaced=true;
            replaceNullArgList=[replaceNullArgList,prop([k,k+1])];
            %
        otherwise,
            error([upper(mfilename),':wrongProperty'],...
                'unidentified property name: %s ',prop{k});
    end;
end;
%%
%% TEMPORARY PLUG FOR BACKWARD COMPATIBILITY WITH OLD
%% STRUCTURES
self.inferSIsValueNullIfEmpty();
if ~isFieldNameListSpec
    fieldNameList=self.getFieldNameList();
end
%
nFields=length(fieldNameList);
%
if nReg>=1
    %
    minDimSize=self.getMinDimensionSizeInternal();
    %
    subIndCVec=varargin{1};
    if ~iscell(subIndCVec)
        subIndCVec={subIndCVec};
    else
        if ~modgen.common.isvec(subIndCVec)
            error([upper(mfilename),':wrongInput'],...
                'subIndCVec is expected to be a row-vector');
        end
    end
    %
    if nReg==1
        nDims=length(subIndCVec);
        dimVec=1:nDims;
    else
        dimVec=varargin{2};
        if ~(modgen.common.isvec(dimVec)&&...
                isnumeric(dimVec)&&isequal(fix(dimVec),dimVec))
            error([upper(mfilename),':wrongInput'],...
                'dimVec is expected to be a numeric row-vector of integers');
        end
        %        
        nDims=max(dimVec);
        if length(subIndCVec)~=length(dimVec)
            error([upper(mfilename),':wrongInput'],...
                ['dimVec and subIndCVec (if it is a cell array) ',...
                    'should have the same length']);
        end
        if max(dimVec)>self.getMinDimensionality()||min(dimVec)<1
            error([upper(mfilename),':wrongInput'],...
                ['dimVec is expected to consist of componets from range ',...
                '[1,minDimensionality]= [1,%d]'],....
                self.getMinDimensionality());
        end        
    end
    %
    if ~all(dimVec<=length(minDimSize))
        error([upper(mfilename),':wrongInput'],...
            'length of subIndCVec is greater than a cube dimensionality');
    end
    %
    isNumericVec=cellfun(@(x,y)isnumeric(x)&&isequal(x,fix(x))&&...
        modgen.common.isvec(x)&&all(x<=y&x>=0),...
        subIndCVec,num2cell(minDimSize(dimVec)));
    %
    isLogicalVec=cellfun(@(x,y)islogical(x)&&numel(x)==y&&...
        modgen.common.isvec(x),...
        subIndCVec,num2cell(minDimSize(dimVec)));
    %
    if ~all(isNumericVec|isLogicalVec)
        error([upper(mfilename),':wrongInput'],...
            ['subIndCVec is expected to contain either logical ',...
            'or numeric vectors of indices that are within range']);
    end
    %
    isZeroIndexSpec=any(cellfun(@(x)any(x==0),subIndCVec(isNumericVec)));
    %
    if isZeroIndexSpec
        %
        fieldMetaData=self.getFieldMetaData(fieldNameList);
        %
        fromIndCVec=subIndCVec;
        toIndCVec=cell(size(subIndCVec));
        for iDim=1:length(subIndCVec)
            if isNumericVec(iDim)
                isPositiveVec=subIndCVec{iDim}>0;
                fromIndCVec{iDim}=subIndCVec{iDim}(isPositiveVec);
                [~,toIndCVec{iDim}]=ismember(fromIndCVec{iDim},subIndCVec{iDim});
            end
        end
    else
        fromIndCVec=subIndCVec;
    end
    %
    if nReg>1
        subIndCVec=enhanceIndCVec(subIndCVec,dimVec,minDimSize);
        if isZeroIndexSpec
            toIndCVec=enhanceIndCVec(toIndCVec,dimVec,minDimSize);
            fromIndCVec=enhanceIndCVec(fromIndCVec,dimVec,minDimSize);
        else
            fromIndCVec=subIndCVec;
        end
    end
    %
    isLogicalIndexVec=cellfun('isclass',fromIndCVec,'logical');
    if ~all(isLogicalIndexVec)
        isRestNumeric=modgen.common.iscellnumeric(fromIndCVec(~isLogicalIndexVec));
        if ~isRestNumeric
            error([upper(mfilename),':wrongInput'],...
                'fromIndCVec should contain either logical or numeric arrays');
        end
    end
    %
    firstDimSizeVec=nan(1,nDims);
    firstDimSizeVec(~isLogicalIndexVec)=cellfun('length',subIndCVec(~isLogicalIndexVec));
    firstDimSizeVec(isLogicalIndexVec)=cellfun(@sum,subIndCVec(isLogicalIndexVec));    
    %
    resMinDimSize=[firstDimSizeVec minDimSize((nDims+1):end)];
    if length(resMinDimSize)==1
        resMinDimSize=[resMinDimSize 1];
    end
    %
    SData=struct();
    SIsNull=struct();
    SIsValueNull=struct();
    %
    for iField=1:nFields
        fieldName=fieldNameList{iField};
        endFieldSizeVec=size(self.SData.(fieldName));
        endFieldSizeVec=endFieldSizeVec((nDims+1):end);
        resFullValueSizeVec=[firstDimSizeVec endFieldSizeVec];
        %
        if isZeroIndexSpec
            [SData.(fieldName),...
                SIsNull.(fieldName),...
                SIsValueNull.(fieldName)]=...
                fieldMetaData(iField).generateDefaultFieldValue(...
                resFullValueSizeVec);
            %
            SData.(fieldName)(toIndCVec{:},:)=...
                self.SData.(fieldName)(fromIndCVec{:},:);
            SIsNull.(fieldName)(toIndCVec{:},:)=self.SIsNull.(fieldName)(...
                fromIndCVec{:},:);
            SIsValueNull.(fieldName)(toIndCVec{:},:)=self.SIsValueNull.(fieldName)(...
                fromIndCVec{:},:);
        else
            SData.(fieldName)=self.SData.(fieldName)(fromIndCVec{:},:);
            SIsNull.(fieldName)=self.SIsNull.(fieldName)(...
                fromIndCVec{:},:);
            %
            SIsValueNull.(fieldName)=self.SIsValueNull.(fieldName)(...
                fromIndCVec{:},:);
            %
            SData.(fieldName)=reshape(SData.(fieldName),...
                resFullValueSizeVec);
            %
            SIsNull.(fieldName)=reshape(SIsNull.(fieldName),...
                resFullValueSizeVec);
            %
            SIsValueNull.(fieldName)=reshape(SIsValueNull.(fieldName),...
                resMinDimSize);
        end

    end
else
    if isempty(fieldNameList)
        SData=struct();
        SIsNull=struct();
        SIsValueNull=struct();
    else
        if isFieldNameListSpec
            %
            SData=orderfields(auxfieldfilterstruct(...
                self.SData,fieldNameList),fieldNameList);
            SIsNull=orderfields(auxfieldfilterstruct(...
                self.SIsNull,fieldNameList),fieldNameList);
            SIsValueNull=orderfields(auxfieldfilterstruct(...
                self.SIsValueNull,fieldNameList),fieldNameList);
        else
            %
            SData=orderfields(self.SData,fieldNameList);
            SIsNull=orderfields(self.SIsNull,fieldNameList);
            SIsValueNull=orderfields(self.SIsValueNull,fieldNameList);
        end
    end
        
end
%
if isNullReplaced
    [SData,SIsNull,SIsValueNull]=self.replaceNullsInStruct(...
        SData,SIsNull,SIsValueNull,replaceNullArgList{:});
end
varargout={SData,SIsNull,SIsValueNull};
%
if isStructNameListSpec
    [~,indLoc]=ismember(structNameList,self.completeStructNameList);
    varargout=varargout(indLoc);
end
end
%
function subIndFullCVec=enhanceIndCVec(subIndCVec,dimVec,minDimSize)
nDims=max(dimVec);
subIndFullCVec=cell(1,nDims);
isnIndexedVec=true(1,nDims);
isnIndexedVec(dimVec)=false;
%
subIndFullCVec(dimVec)=subIndCVec;
%
completeIndCVec=cellfun(@(x)(1:x),...
    num2cell(minDimSize(isnIndexedVec)),'UniformOutput',false);
subIndFullCVec(isnIndexedVec)=completeIndCVec;
end