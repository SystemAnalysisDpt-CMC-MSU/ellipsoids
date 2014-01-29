function resRel=getJoinWith(self,otherRel,keyFieldNameList,varargin)
% GETJOINWITH - returns a result of INNER join of given relation with 
%               another relation by the specified key fields 
%
% LIMITATION: key fields by which the join is peformed are required to form
% a unique key in the given relation
%
% Input:
%   regular:
%       self:
%       otherRel: smartdb.relations.ARelation[1,1]
%       keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]
%
%   properties:
%       joinType: char[1,] - type of join, can be
%           'inner' (DEFAULT)
%           'leftOuter'
%
% Output:
%   resRel: smartdb.relations.ARelation[1,1] - join result
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
resRel=smartdb.relations.DynamicRelation(...
    self.getJoinWithInternal(otherRel,keyFieldNameList,varargin{:}));