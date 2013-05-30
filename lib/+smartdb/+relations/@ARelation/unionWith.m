function unionWith(self,varargin)
% UNIONWITH - adds tuples of the input relation to the set of tuples of the
%             original relation
% Usage: self.unionWith(inpRel)
% 
% Input:
%   regular:
%     self: ARelation [1,1] - class object
%     inpRel1: ARelation [1,1] - object to get the additional tuples from
%       ...
%     inpRelN: ARelation [1,1] - object to get the additional tuples from
%
%   properties:
%       checkType: logical[1,1] - if true, union is only performed when the
%           types of relations is the same. Default value is false
%
%       checkStruct: logical[1,nStruct] - an array of indicators which when
%          true force checking of structure content (including presence 
%          of all required fields). The first element correspod to SData, 
%          the second and the third (if specified) to SIsNull and 
%          SIsValueNull correspondingly
%
%       checkConsistency: logical [1,1]/[1,2] - the
%           first element defines if a consistency between the value
%           elements (data, isNull and isValueNull) is checked;
%           the second element (if specified) defines if
%           value's type is checked. If isConsistencyChecked
%           is scalar, it is automatically replicated to form a
%           two-element vector.
%           Note: default value is true
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-09-13 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.unionWithAlongDimInternal(1,varargin{:});