function removeTuples(self,subIndVec)
% REMOVETUPLES - removes tuples with given indices from given relation
%
% Usage: self.removeTuples(subIndVec)
% 
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%     subIndVec: double [nSubTuples,1]/logical[nTuples,1] - array of
%        indices for tuples that are selected to be removed
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if islogical(subIndVec),
    isTuple=~subIndVec;
else
    isTuple=true(self.getNTuples(),1);
    isTuple(subIndVec)=false;
end
%
self.copyFromInternal(self,isTuple);