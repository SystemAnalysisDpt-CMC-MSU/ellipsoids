function sortInd=groupBy(self,groupFieldNameList)
% GROUPBY groups all tuples of given relation with respect to some
% of its fields
%
% Usage: groupBy(self,groupFieldNameList)
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%     groupFieldNameList: char or char cell [1,nFields] - list of field
%         names with respect to which tuples are grouped
%
% Output:
%   sortInd: [nTuples,1] - order in which the tuples of the original
%       relation are sorted before grouping
%   
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-02-07 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
%% Initial actions
if nargin<2,
    error([upper(mfilename),':wrongInput'],...
        'groupFieldNameList must be given for grouping');
end
if ischar(groupFieldNameList),
    groupFieldNameList={groupFieldNameList};
end
groupFieldNameList=groupFieldNameList(:).';
if ~iscellstr(groupFieldNameList),
    error([upper(mfilename),':wrongInput'],...
        'groupFieldNameList must be array of strings');
end
[isField indField]=ismember(groupFieldNameList,self.fieldNameList);
if ~all(isField),
    error([upper(mfilename),':wrongInput'],...
        'groupFieldNameList must contain names of given relation fields');
end
if any(diff(sort(indField))==0),
    error([upper(mfilename),':wrongInput'],...
        'groupFieldNameList must contain unique names');
end
fieldNameList=self.fieldNameList;
nFields=length(fieldNameList);
isGroupField=false(1,nFields);
isGroupField(indField)=true;
%
[~,linIndTuples]=...
    self.getUniqueData('fieldNameList',groupFieldNameList,...
    'structNameList',{},'checkInputs',false);
[linIndTuples sortInd]=sort(linIndTuples);
indStart=find(diff([0;linIndTuples(:);Inf]));
lenVec=diff(indStart);
indStart=indStart(1:end-1);
nGroups=length(indStart);
%
%% Construct grouped relation
curSData=struct;
curSIsNull=struct;
[SData,SIsNull,SIsValueNull]=self.getTuplesInternal(sortInd);
%
aggrFieldNameList=fieldNameList(~isGroupField);
aggrFieldMetaData=self.getFieldMetaData(aggrFieldNameList);
aggrTypeSpecList=aggrFieldMetaData.getTypeSpecList;
aggrTypeSpecList=cellfun(@(x)['cell',x],aggrTypeSpecList,'UniformOutput',false);
aggrFieldMetaData.setTypeBySpec(aggrTypeSpecList);
%
for iField=1:nFields,
    curFieldName=fieldNameList{iField};
    %
    curData=SData.(curFieldName);
    curIsNull=SIsNull.(curFieldName);
    curIsValueNull=SIsValueNull.(curFieldName);
    %
    curSize=num2cell(size(curData));
    if isGroupField(iField)
        %
        curSData.(curFieldName)=curData(indStart,:);
        curSIsNull.(curFieldName)=curIsNull(indStart,:);
        curSIsValueNull.(curFieldName)=curIsValueNull(indStart,:);
        %
    else
        curSData.(curFieldName)=mat2cell(curData,lenVec,curSize{2:end});
        %
        curSIsNull.(curFieldName)=mat2cell(curIsNull,lenVec,curSize{2:end});
        %
        if ~isempty(curIsValueNull)
            curIsValueNullGroupedCVec=mat2cell(curIsValueNull,lenVec,1);
            %
            if iscell(curIsNull)
                for iGroup=1:nGroups
                    curSIsNull.(curFieldName){iGroup}(curIsValueNullGroupedCVec{iGroup},:)={true};
                end
            end
            %
            curSIsValueNull.(curFieldName)=cellfun(@all,curIsValueNullGroupedCVec);
        else
            curSIsValueNull.(curFieldName)=false(size(curIsValueNull));
        end
    end
end
%
self.setDataInternal(curSData,curSIsNull,curSIsValueNull,...
    'transactionSafe',false,...
    'checkConsistency',false,'fieldMetaData',aggrFieldMetaData,...
    'mdFieldNameList',aggrFieldNameList,'checkStruct',[false false false]);