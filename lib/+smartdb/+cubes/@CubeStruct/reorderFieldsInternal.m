function reorderFieldsInternal(self,newFieldNameList)
% REORDERFIELDSINTERNAL reorders CubeStruct fields according to 
% the specified field name list
% 
% Input:
%   regular:
%       self:
%       newFieldNameList: cell[1,nFields] of char - new field name list
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if ~(modgen.common.isrow(newFieldNameList)&&iscellstr(newFieldNameList))
    error([upper(mfilename),':wrongInput'],...
        'newFieldNameList is expected to be a cellstr row-vector');
end
if ~(numel(unique(newFieldNameList))==length(newFieldNameList))
    error([upper(mfilename),':wrongInput'],...
        'newFieldNameList should contain only unique elements');
end
%
origFieldNameList=self.getFieldNameList();
%
if numel(origFieldNameList)~=numel(newFieldNameList)
    error([upper(mfilename),':wrongInput'],...
        'new and old field lists should be of the same length');
end
%
[isThereVec,indLoc]=ismember(newFieldNameList,origFieldNameList);
if ~all(isThereVec)
    error([upper(mfilename),':wrongInput'],...
        'newFieldNameList should cosists of field names only');
end
%
self.fieldMetaData=self.fieldMetaData(indLoc);