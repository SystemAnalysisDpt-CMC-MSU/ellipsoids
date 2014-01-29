function varargout=getUniqueDataAlongDimInternal(self,catDim,varargin)
% GETUNIQUEDATAALONGDIM - returns internal representation of CubeStruct
%                         data set unique along a specified dimension
%                         set
%
% Usage: [SData,SIsNull,SIsValueNull]=getUniqueData(self,varargin)
%
% Input:
%   regular:
%     self:
%     catDim: double[1,1] - dimension number along which uniqueness is
%        checked
%
%   properties
%       fieldNameList: list of field names used for finding the unique
%           elements; only the specified fields are returned in SData,
%           SIsNull,SIsValueNull structures
%       structNameList: list of internal structures to return (by default it
%           is {SData, SIsNull, SIsValueNull}
%       replaceNull: logical[1,1] if true, null values are replaced with
%           certain default values uniformly across all CubeStruct cells
%               default value is false
%       checkInputs: logical[1,1] - if true, the input parameters are
%          checked for consistency
%
% Output:
%   regular:
%     SData: struct [1,1] - structure containing values of fields
%
%     SIsNull: struct [1,1] - structure containing info whether each value
%         in selected cells is null or not, each field is either logical
%         array or cell array containing logical arrays
%
%     SIsValueNull: struct [1,1] - structure containing a
%        logical array [nSlices,1] for each of the fields (true
%        means that a corresponding cell doesn't not contain
%           any value
%
%     indForwardVec: double[nUniqueSlices,1] - indices of unique entries in
%        the original CubeStruct data set
%
%     indBackwardVec: double[nSlices,1] - indices that map the unique data set
%        set back to the original data set
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-08-17 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.system.ExistanceChecker;
import modgen.common.throwerror;
%
isNullReplaced=false;
%
%% extract isInputConsistencyChecked
[reg,prop]=modgen.common.parseparams(varargin);
if ~isempty(reg)
    throwerror('wrongInput',...
        ['property name-value sequence should not contain any ',...
        'regular parameters']);
end
nProp=length(prop);
isInputConsistencyChecked=true;
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'checkinputs',
            isInputConsistencyChecked=prop{k+1};
            if ~(islogical(isInputConsistencyChecked)&&...
                    numel(isInputConsistencyChecked)==1)
                throwerror('wrongInput',...
                    ['isInputConsistencyChecked is expected ',...
                    'to be a scalar logical value']);
            end
            %
            prop([k k+1])=[];
            nProp=length(prop);
            break;
    end
end
%
%% check a consistency of inputs
if isInputConsistencyChecked
    for k=1:2:nProp-1
        switch lower(prop{k})
            case 'fieldnamelist'
                fieldNameList=prop{k+1};
                if ischar(fieldNameList)
                    fieldNameList={fieldNameList};
                end
                self.isFieldsCheck(fieldNameList,true);
            case 'structnamelist',
                structNameList=prop{k+1};
                if (length(structNameList)+2)<nargout
                    throwerror('wrongInput',...
                        'too many output arguments');
                end
            case 'replacenull'
                if ~(islogical(prop{k+1})&&numel(prop{k+1})==1)
                    throwerror('wrongInput',...
                        'replaceNull is expected to have a scalar logical value');
                end
            otherwise
                throwerror('wrongInput',...
                    'unknown property %s',prop{k});
        end
    end
end
%% default values
structNameList=self.completeStructNameList;
%
isFieldNameListSpecified=false;
isStructNameListSpecified=false;
%% extract property values
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'structnamelist',
            structNameList=prop{k+1};
            isStructNameListSpecified=true;
        case 'replacenull',
            isNullReplaced=prop{k+1};
        case 'fieldnamelist',
            isFieldNameListSpecified=true;
            fieldNameList=prop{k+1};
    end
end
%
nRes=length(self.completeStructNameList);
%
resCell=cell(1,2);
if isFieldNameListSpecified
    fieldParamList={'fieldNameList',fieldNameList};
else
    fieldParamList={};
end
[resCell{:}]=self.getDataInternal(fieldParamList{:},...
    'replaceNull',true,'structNameList',{'SData','SIsNull'},...
    'checkInputs',false);
%
fieldNameList=fieldnames(resCell{1});
nFields=length(fieldNameList);
%we use @(x)struct2cell(x) instead of @struct2cell to avoid a misterious
%OUT OF MEMORY error
resCell=cellfun(@(x)struct2cell(x),resCell,'UniformOutput',false);
%
% use only SData and SIsNull structures
[uniqueResCell,indForwardVec,indBackwardVec]=uniquejoint(...
    vertcat(resCell{1:2}),catDim);
if modgen.common.isrow(indForwardVec)
    indForwardVec=transpose(indForwardVec);
end
if modgen.common.isrow(indBackwardVec)
    indBackwardVec=transpose(indBackwardVec);
end
%
uniqueResCell=[uniqueResCell;...
    struct2cell(self.getDataInternal({indForwardVec},catDim,...
    fieldParamList{:},'structNameList',{'SIsValueNull'}))];
%
resCell=mat2cell(uniqueResCell,repmat(nFields,1,nRes),1);
varargout=cellfun(@(x)cell2struct(x,fieldNameList),resCell,...
    'UniformOutput',false).';
%
if isNullReplaced
    [varargout{:}]=self.replaceNullsInStruct(varargout{:});
end
%
if isStructNameListSpecified
    [~,indLoc]=ismember(structNameList,self.completeStructNameList);
    varargout=varargout(indLoc);
end
%
varargout=[varargout,{indForwardVec,indBackwardVec}];