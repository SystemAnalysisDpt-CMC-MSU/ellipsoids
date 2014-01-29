function checkStruct(self,SData,isConsistencyChecked,selfFieldNameList)
% CHECKSTRUCT perform check that contains values of all cells for all
% fields
%
% Usage: checkStruct(SData)
%
% Input:
%   regular:
%       SData: struct [1,1] - structure with values of all cells for all
%           fields
%       isConsistencyChecked: logical[1,1] - if true, a consistency between
%       
%   optional:
%       fieldNameList: cell[1,nFields] of char[1,] - field name list
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-05-25 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwwarn;
import modgen.common.throwerror;
if numel(SData)>1
    throwerror('wrongInput','a scalar structure is expected');
end
%
fieldNameList=fieldnames(SData).';
if nargin<4
    selfFieldNameList=self.getFieldNameList();
end
selfNFields=numel(selfFieldNameList);
%
if ~isequal(selfFieldNameList,fieldNameList)
    isAllInVec=ismember(selfFieldNameList,fieldNameList);
    if ~all(isAllInVec)
        missingFieldList=selfFieldNameList(~isAllInVec);
        throwerror('wrongInput',...
            ['input structure doesnt''t contain all necessary fields, ',...
            'the following fields are missing: %s'],...
            cell2sepstr([],missingFieldList,','));
    end
    if length(fieldNameList)>selfNFields&&selfNFields>0
        extraFieldList=fieldNameList(...
            ~ismember(fieldNameList,selfFieldNameList));
        throwwarn('redundantData',...
            ['input data structure contains the following ',...
            'redundant fields: %s'],cell2sepstr([],extraFieldList,','));
    end
    %
end
%
if isConsistencyChecked
    minDimensionality=self.getMinDimensionality();
    sizeCVec=struct2cell(structfun(...
        @(x)modgen.common.getfirstdimsize(x,minDimensionality),...
        SData,'UniformOutput',false));
    %
    if ~isempty(sizeCVec)
        sizeFVec=sizeCVec{1};
        isEqual=cellfun(@(x)isequal(x,sizeFVec),sizeCVec);
        %
        if ~all(isEqual)
            throwerror('wrongInput',...
                ['all fields should have the same size along ',...
                'with the first %d dimensions'],...
                minDimensionality);
        end
    end
end