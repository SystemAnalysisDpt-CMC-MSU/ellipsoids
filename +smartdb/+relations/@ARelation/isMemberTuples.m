function varargout=isMemberTuples(self,other,keyFieldNameList)
% ISMEMBER - performs ismember operation for tuples of two relations by key
%            fields given by special list
%
% Usage: isTuple=isMemberTuples(self,otherRel,keyFieldNameList) or
%        [isTuple indTuples]=isMemberTuples(self,otherRel,keyFieldNameList)
%
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%     other: ARelation [1,1] - other class object
%   optional:
%     keyFieldNameList: char or char cell [1,nKeyFields] - list of fields
%         to which ismember is applied; by default all fields of first
%         (self) object are used
% Output:
%   regular:
%     isTuple: logical [nTuples,1] - determines for each tuple of first
%         (self) object whether combination of values for key fields is in
%         the second (other) relation or not
%     indTuples: double [nTuples,1] - zero if the corresponding coordinate
%         of isTuple is false, otherwise the highest index of the
%         corresponding tuple in the second (other) relation
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-08-16 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if nargin>2
    inpArgList={'keyFieldNameList',keyFieldNameList};
else
    inpArgList={};
end
if nargout>0
    varargout=cell(1,nargout);
    [varargout{:}]=self.isMemberAlongDimInternal(other,1,inpArgList{:});
else
    self.isMemberAlongDimInternal(other,1,inpArgList{:})
end