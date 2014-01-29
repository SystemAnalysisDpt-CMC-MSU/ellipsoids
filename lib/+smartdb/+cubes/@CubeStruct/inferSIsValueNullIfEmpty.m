function inferSIsValueNullIfEmpty(self)
% INFERSISVALUENULLIFEMPTY reconstructs SIsValueNull structure
% if it is empty
%
% Input:
%   regular:
%       self: CubeStruct [1,1]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if isempty(fieldnames(self.SIsValueNull))
    fieldNameList=self.getFieldNameList();
    if ~isempty(fieldNameList)
        self.SIsValueNull=struct();
        for iField=1:self.getNFields()
            fieldName=fieldNameList{iField};
            self.SIsValueNull.(fieldName)=...
                smartdb.cubes.ACubeStructFieldType.isnull2isvaluenull(self.SIsNull.(fieldName));
        end
    end
end