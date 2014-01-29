function [resRel,resOtherRel]=getTuplesJoinedWithInternal(self,otherRel,...
    keyFieldNameList,varargin)
% GETTUPLESJOINEDWITHINTERNAL returns the tuples of the given relation
% joined with other relation by the specified key fields 
%
% Input:
%   regular:
%       self:
%       otherRel: smartdb.relations.ARelation[1,1]
%       keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]
%
%   properties:
%       joinType: char[1,] - type of join, can be
%           'inner' (DEFAULT) - inner join
%           'leftOuter' - left outer join
%           'rightOuter' - right outer join
%           'fullOuter' - full outer join
%
% Output:
%   resRel: smartdb.relations.ARelation[1,1] - relation containing tuples
%       corresponding to tuples with the key values from otherRel
%   otherRel: smartdb.relations.ARelation[1,1] - contains tuples
%       corresponding to tuples with key values from resRel
%       
%       
% Note: if keyFieldNameList forms a unique key in otherRel the order of
% tuples in the resulting relation (resRel) is guaranteed to be in sync
% with the order of tuples in otherRel
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-09-14 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
import modgen.common.type.simple.*;
%
[~,~,joinType]=modgen.common.parseparext(varargin,...
    {'joinType';'inner';@(x)(lib.isstring(x)&&any(strcmpi(x,...
    {'inner','leftOuter','rightOuter','fullOuter'})))},0);
self.isFieldsCheck(keyFieldNameList);
if ischar(keyFieldNameList)
    keyFieldNameList={keyFieldNameList};
end
%
self.checkIfObjectScalar();
if ~isa(otherRel,'smartdb.relations.ARelation')
    throwerror('wrongInput','otherRel is expected to be a relation');
end
%
otherRel.checkIfObjectScalar();
otherRel.isFieldsCheck(keyFieldNameList);
%
[selfURel,~,indSBackwardVec]=self.getUniqueTuples(...
    'fieldNameList',keyFieldNameList);
%
[isThereVec,indOtherBVec]=otherRel.isMemberTuples(selfURel,...
    keyFieldNameList);
%
isSThereVec=ismember(indSBackwardVec,indOtherBVec(isThereVec));
indSelfBVec=indSBackwardVec;
indSelfBVec(~isSThereVec)=0;
%
nSelfElems=length(indSelfBVec);
nOtherElems=length(indOtherBVec);
%
if numel(indSelfBVec)>0
    indSelfCVec=accumarray(indSelfBVec+1,1:nSelfElems,[],@(x){x});    
    indSelfNotBelongVec=indSelfCVec{1};
    indSelfCVec=indSelfCVec(2:end);    
else
    indSelfNotBelongVec=double.empty(1,0);
    indSelfCVec=cell(1,0);
end
%
if numel(indOtherBVec)>0
    indOtherCVec=accumarray(indOtherBVec+1,1:nOtherElems,[],@(x){x});    
    indOtherNotBelongVec=indOtherCVec{1};
    indOtherCVec=indOtherCVec(2:end);    
else
    indOtherNotBelongVec=double.empty(1,0);
    indOtherCVec=cell(1,0);
end
%
isnOtherEmptyVec=~cellfun('isempty',indOtherCVec);
indIsNotOtherEmptyVec=find(isnOtherEmptyVec);
indOtherMinIndVec=cellfun(@min,indOtherCVec(isnOtherEmptyVec));
[~,indOtherSortVec]=sort(indOtherMinIndVec);
indSelfCVec(isnOtherEmptyVec)=indSelfCVec(indIsNotOtherEmptyVec(indOtherSortVec));
indOtherCVec(isnOtherEmptyVec)=indOtherCVec(indIsNotOtherEmptyVec(indOtherSortVec));
%
if numel(indSelfCVec)>0
    indCombCVec=cellfun(@(x,y)combvec(x.',y.').',indSelfCVec,...
        indOtherCVec,'UniformOutput',false);
else
    indCombCVec=cell(1,0);
end
%
isnEmptyVec=~cellfun('isempty',indCombCVec);
indSelfCombCVec=cell(size(indCombCVec));
indOtherCombCVec=cell(size(indCombCVec));
%
indSelfCombCVec(isnEmptyVec)=cellfun(@(x)x(:,1),indCombCVec(isnEmptyVec),'UniformOutput',false);
indOtherCombCVec(isnEmptyVec)=cellfun(@(x)x(:,2),indCombCVec(isnEmptyVec),'UniformOutput',false);
%
indSelfThereVec=vertcat(indSelfCombCVec{:});
indOtherThereVec=vertcat(indOtherCombCVec{:});
%
if strcmpi(joinType,'inner')
    indSelfNotThereVec=[];
    indOtherNotThereVec=[];
elseif strcmpi(joinType,'leftOuter')
    indSelfNotThereVec=indSelfNotBelongVec;
    indOtherNotThereVec=[];
elseif strcmpi(joinType,'rightOuter')
    indOtherNotThereVec=indOtherNotBelongVec;    
    indSelfNotThereVec=[]; 
elseif strcmpi(joinType,'fullOuter')
    indSelfNotThereVec=indSelfNotBelongVec;
    indOtherNotThereVec=indOtherNotBelongVec;   
else
    throwerror('wrongInput','joinType = %s is not supported',joinType);
end
nOtherNotThere=numel(indOtherNotThereVec);
nSelfNotThere=numel(indSelfNotThereVec);
%
nSelfTuples=self.getNTuples();
nOtherTuples=otherRel.getNTuples();
%
if nSelfTuples==0
    refRel=self.getCopy();
    refRel.initByEmptyDataSet(1);
else
    refRel=self;
end
resRel=refRel.getTuples([indSelfThereVec;indSelfNotThereVec;ones(nOtherNotThere,1)]);
    
%%
if nOtherTuples==0
    refRel=otherRel.getCopy();
    refRel.initByEmptyDataSet(1);
else
    refRel=otherRel;
end
resOtherRel=refRel.getTuples([indOtherThereVec;...
    ones(nSelfNotThere,1);indOtherNotThereVec]);
%
nTuples=resRel.getNTuples();
[SOtherData,SOtherIsNull,SOtherIsValueNull]=resOtherRel.getDataInternal();
[SSelfData,SSelfIsNull,SSelfIsValueNull]=resRel.getDataInternal();
%
fieldOtherNameList=fieldnames(SOtherIsValueNull);
[isOtherKeyFieldVec,indOtherKeyFieldVec]=...
    ismember(fieldOtherNameList,keyFieldNameList);
nOtherFields=length(fieldOtherNameList);
isOtherKeyFieldNullVec=otherRel.getIsFieldValueNull(keyFieldNameList);
%
indVec=(nTuples-nOtherNotThere-nSelfNotThere+1):(nTuples-nOtherNotThere);    
for iField=1:nOtherFields
    fieldName=fieldOtherNameList{iField};
    if isOtherKeyFieldVec(iField)
        isNullVec=SSelfIsValueNull.(fieldName)(indVec);            
        if isOtherKeyFieldNullVec(indOtherKeyFieldVec(iField))
            SOtherData.(fieldName)=SSelfData.(fieldName);
            SOtherIsNull.(fieldName)=SSelfIsNull.(fieldName);
        else
            indNotNullVec=indVec(~isNullVec);
            if ~isempty(indNotNullVec)
                try
                    SOtherData.(fieldName)(indNotNullVec,:)=SSelfData.(fieldName)(indNotNullVec,:);
                    SOtherIsNull.(fieldName)(indNotNullVec,:)=SSelfIsNull.(fieldName)(indNotNullVec,:);
                catch meObj
                    newMeObj=modgen.common.throwerror('incompatibleFieldSizes',...
                        sprintf(['size of field %s in left relation ',...
                        'is %s and %s in the right; join cannot be ',...
                        'performed as sizes are incompatible'],fieldName,...
                        mat2str(size(SOtherData.(fieldName))),...
                        mat2str(size(SSelfData.(fieldName)))));
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                end
            end
        end
        SOtherIsValueNull.(fieldName)(indVec)=isNullVec;
    else
        isValueNullVec=SOtherIsValueNull.(fieldName);
        isValueNullVec(indVec)=true;
        SOtherIsValueNull.(fieldName)=isValueNullVec;
    end
end
%
resOtherRel.setDataInternal(SOtherData,SOtherIsNull,SOtherIsValueNull,...
    'checkConsistency',false);
%%
fieldSelfNameList=fieldnames(SSelfIsValueNull);
[isSelfKeyFieldVec,indSelfKeyFieldVec]=...
    ismember(fieldSelfNameList,keyFieldNameList);
nSelfFields=length(fieldSelfNameList);
isSelfKeyFieldNullVec=self.getIsFieldValueNull(keyFieldNameList);
%
indVec=(nTuples-nOtherNotThere+1):nTuples;
for iField=1:nSelfFields
    fieldName=fieldSelfNameList{iField};
    if isSelfKeyFieldVec(iField)
        isNullVec=SOtherIsValueNull.(fieldName)(indVec);        
        if isSelfKeyFieldNullVec(indSelfKeyFieldVec(iField))
            SSelfData.(fieldName)=SOtherData.(fieldName);
            SSelfIsNull.(fieldName)=SOtherIsNull.(fieldName);
        else
            indNotNullVec=indVec(~isNullVec);
            if ~isempty(indNotNullVec)
                try
                    SSelfData.(fieldName)(indNotNullVec,:)=SOtherData.(fieldName)(indNotNullVec,:);
                    SSelfIsNull.(fieldName)(indNotNullVec,:)=SOtherIsNull.(fieldName)(indNotNullVec,:);
                catch meObj
                    newMeObj=modgen.common.throwerror('incompatibleFieldSizes',...
                        sprintf(['size of field %s in left relation ',...
                        'is %s and %s in the right; join cannot be ',...
                        'performed as sizes are incompatible'],fieldName,...
                        mat2str(size(SSelfData.(fieldName))),...
                        mat2str(size(SOtherData.(fieldName)))));
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                end
            end            
        end
        SSelfIsValueNull.(fieldName)(indVec)=isNullVec;
    else
        isValueNullVec=SSelfIsValueNull.(fieldName);
        isValueNullVec(indVec)=true;
        SSelfIsValueNull.(fieldName)=isValueNullVec;
    end
end
resRel.setDataInternal(SSelfData,SSelfIsNull,SSelfIsValueNull,...
    'checkConsistency',false);