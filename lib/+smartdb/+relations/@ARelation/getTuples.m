function obj=getTuples(self,subIndVec)
% GETTUPLES - selects tuples with given indices from given relation and  
%             returns the result as new relation
%
% Usage: obj=getTuples(self,subIndVec)
%
% input:
%   regular:
%     self: ARelation [1,1] - class object
%     subIndVec: double [nSubTuples,1]/logical[nTuples,1] - array of 
%         indices for tuples that are selected
% output:
%   regular:
%     obj: ARelation [1,1] - new class object containing only selected 
%         tuples
%         
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
p=metaclass(self);
obj=feval(p.Name);
%
obj.copyFromInternal(self,subIndVec);
obj.defineFieldsAsProps();