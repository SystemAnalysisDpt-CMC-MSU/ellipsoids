function obj=getTuplesIndexedBy(self,indexFieldName,indexValueVec)
% GETTUPLESINDEXEDBY - selects tuples from given relation such that fixed 
%                      index field contains given in a specified order  
%                      values and returns the result as new relation. 
%                      It is required that the original relation
%                      contains only one record for each field value
%
% input:
%   regular:
%     self: ARelation [1,1] - class object
%     indexFieldName: char - name of index field
%     indexValueVec: numeric or char cell [nValues,1] - vector of index 
%         values
% output:
%   regular:
%     obj: ARelation [1,1] - new class object containing only selected 
%         tuples
%
%TODO add type check
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-08-17 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   check that index field contains unique values is added
%
%
import modgen.common.throwerror;
self.isFieldsCheck(indexFieldName)
%
fieldValueVec=self.(indexFieldName);
if length(unique(fieldValueVec))<length(fieldValueVec),
    throwerror('wrongInput',...
        'field %s of relation contains nonunique values',indexFieldName);
end
[isThereVec,indLocVec]=ismember(indexValueVec,fieldValueVec);
if ~all(isThereVec)
    throwerror('wrongInput',...
        'not all index field values can be found in field ''%s''',...
        indexFieldName);
end
obj=self.getTuples(indLocVec);