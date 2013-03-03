function invGroupBy(self,groupFieldNameList,varargin)
% IVNGROUPBY inverts groupBy operation
%
% Usage: invGroupBy(self,groupFieldNameList)
%
% input:
%   regular:
%       self: ARelation [1,1] - class object
%       groupFieldNameList: char or char cell [1,nFields] - list of field
%         names with respect to which tuples are grouped
%   properties:
%       ungroupFields: logical[1,1] - if true, groupFieldNameList is
%          interpreted as a list of fields that need to be ungrouped (as
%          opposed to specifying the fields by which the tuples were
%          originally grouped). 
%          default value is false.
%     
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-03-14 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
%% Initial actions
if nargin<2,
    throwerror('wrongInput',...
        'groupFieldNameList must be given for grouping');
end
%
[~,prop]=modgen.common.parseparams(varargin,{'ungroupFields'},0);
if isempty(prop)
    isUngroupFields=false;
else
    isUngroupFields=prop{2};
    if ~(islogical(isUngroupFields)&&numel(isUngroupFields)==1)
        throwerror('wrongInput',...
            'ungroupFields property is expected to be a logical scalar');
    end
end
%
if ischar(groupFieldNameList),
    groupFieldNameList={groupFieldNameList};
end
groupFieldNameList=groupFieldNameList(:).';
if ~iscellstr(groupFieldNameList),
    throwerror('wrongInput',...
        'groupFieldNameList must be array of strings');
end
[isField indField]=ismember(groupFieldNameList,self.fieldNameList);
if ~all(isField),
    throwerror('wrongInput',...
        'groupFieldNameList must contain names of given relation fields');
end
if any(diff(sort(indField))==0),
    throwerror('wrongInput',...
        'groupFieldNameList must contain unique names');
end
fieldNameList=self.fieldNameList;
nFields=length(fieldNameList);
if isUngroupFields
    isGroupField=true(1,nFields);
    isGroupField(indField)=false;
    groupFieldNameList=fieldNameList(isGroupField);
else
    isGroupField=false(1,nFields);
    isGroupField(indField)=true;
end
nGroupFields=sum(isGroupField);
deGroupFieldNameList=fieldNameList(~isGroupField);
nDeGroupFields=nFields-nGroupFields;
%% Get index for tuples
isCellVec=self.applyGetFuncInternal(@iscell,fieldNameList);
%
if sum(~isGroupField&isCellVec)<nDeGroupFields
    throwerror('wrongInput',...
        'all fields that are to be degrouped are expected to have cell values');
end
%
% FIXME - some optimization is required here to avoid getting a copy of
% relation IsNull data
nTuples=self.getNTuples();
%
deGroupFieldIsNullCMat=self.toCellIsNull(deGroupFieldNameList{:});
nElemIsNullMat=cellfun('size',deGroupFieldIsNullCMat,1);
nFieldElemVec=prod(self.getFieldValueSizeMat(deGroupFieldNameList),2);
%
if ~all(nFieldElemVec==nTuples)
    throwerror('wrongInput',...
        'degrouped fields are expected to be cell vectors');
end
if ~all(all(isequal(circshift(nElemIsNullMat,[0 1]),nElemIsNullMat),2))
    throwerror('wrongInput',...
        ['each tuple is expected to contain the array',...
        ' values with the same number of elements in the fields that are',...
        ' expected to be degrouped']);
end
nElemMat=nElemIsNullMat;
%
deGroupFieldMetaData=self.getFieldMetaData(deGroupFieldNameList);
deGroupTypeSpecList=deGroupFieldMetaData.getTypeSpecList;
deGroupTypeSpecList=cellfun(@(x)x(2:end),deGroupTypeSpecList,'UniformOutput',false);
deGroupFieldMetaData.setTypeBySpec(deGroupTypeSpecList);
%
if nTuples>0
    indTupleVec=transpose(1:nTuples);
    nElemVec=nElemMat(:,1);
    indTupleCVec=arrayfun(@(x,y)repmat(x,y,1),indTupleVec,nElemVec,'UniformOutput',false);
    indTupleVec=vertcat(indTupleCVec{:});
    %
    %% Construct inv-grouped relation
    [curSData,curSIsNull]=self.getData(indTupleVec,'fieldNameList',groupFieldNameList);
    %
    [deGroupDataCMat,deGroupIsNullCMat]=self.toMat(...
        'checkInputs',false,...
        'structNameList',...
        {'SData','SIsNull'},'fieldNameList',deGroupFieldNameList,...
        'UniformOutput',false,'groupByColumns',false,'replaceNull',false);
    %
    for iField=1:nDeGroupFields,
        fieldName=deGroupFieldNameList{iField};
        curSData.(fieldName)=vertcat(deGroupDataCMat{:,iField});
        curSIsNull.(fieldName)=vertcat(deGroupIsNullCMat{:,iField});
    end
else
%FIXME - normally we should extract type information from the relation
%   header and use it to generate an empty relation
    [curSData,curSIsNull]=self.generateEmptyDataSet();
end
%
self.setDataInternal(curSData,curSIsNull,'transactionSafe',...
    false,'checkConsistency',false,'fieldMetaData',deGroupFieldMetaData,...
    'mdFieldNameList',deGroupFieldNameList,'checkStruct',...
    [false false false]);
%