function catWithInternal(self,other,varargin)
% CATWITHINTERNAL concatenates two relations by unting their column lists
% Usage: self.catWith(other)
%
% Input:
%   regular:
%       self: DynamicRelation [1,1] - class object
%       other: ARelation[1,1] - object to concatenate with
%
%   properties:
%       duplicateFields: char[1,] - duplicate fields treat mode, the
%          following modes are supported:
%
%           'exception' - exception is thrown if some duplicate fields are
%              found
%           'useOriginal' - if some field exists in both original and new
%              relations, the one from the original relation is used
%           'useOther', - if some field exists in both original and new
%               relations, the one from the new relation is used
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-02-16 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
dupFieldsTreatMode='exception';
[~,prop]=modgen.common.parseparams(varargin,[],0);
%
for k=1:2:length(prop)-1
    switch lower(prop{k})
        case 'duplicatefields',
            dupFieldsTreatMode=prop{k+1};
    end
end
%
otherFieldNameList=other.getFieldNameList();
selfFieldNameList=self.getFieldNameList();
[isDuplicateVec,indThereVec]=ismember(otherFieldNameList,...
    selfFieldNameList);
isSelfDuplicateVec=false(1,numel(selfFieldNameList));
isSelfDuplicateVec(indThereVec(isDuplicateVec))=true;
%
switch lower(dupFieldsTreatMode)
    case 'exception',
        if any(isDuplicateVec)
            error([upper(mfilename),':wrongInput'],...
                ['fields %s present in both original and ',...
                'source relations'],...
                cell2sepstr([],otherFieldNameList(isDuplicateVec),...
                ',','isMatlabSyntax',true));
        end
    case 'useoriginal',
        otherFieldNameList(isDuplicateVec)=[];
    case 'useother',
        selfFieldNameList(isSelfDuplicateVec)=[];
    otherwise,
        error([upper(mfilename),':wrongInput'],...
            'field treat mode %s is unknown',...
            dupFieldsTreatMode);
end
%
if ~isempty(otherFieldNameList)
    %check if cube sizes are the same
    if ~isequal(self.getMinDimensionSizeInternal(),...
            other.getMinDimensionSizeInternal())
        error([upper(mfilename),':wrongInput'],...
            ['concatenation is not possible as sizes along the first ',...
            '%d (minDimensionality) dimentions are different'],...
            self.getMinDimensionality());
    end
    %concatenate meta data
    otherFieldMetaData=other.getFieldMetaData(otherFieldNameList);
    self.fieldMetaData=[self.getFieldMetaData(selfFieldNameList),...
        otherFieldMetaData.clone(self)];
    %concatenate data
    [SData,SIsNull,SIsValueNull]=other.getDataInternal(...
        'fieldNameList',otherFieldNameList);
    nNewFields=length(otherFieldNameList);
    for iField=1:nNewFields
        fieldName=otherFieldNameList{iField};
        self.SData.(fieldName)=SData.(fieldName);
        self.SIsNull.(fieldName)=SIsNull.(fieldName);
        self.SIsValueNull.(fieldName)=SIsValueNull.(fieldName);
    end
    self.defineFieldsAsProps(otherFieldNameList);
end