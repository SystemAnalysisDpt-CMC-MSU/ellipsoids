function varargout=getTuplesJoinedWith(self,otherRel,...
    keyFieldNameList,varargin)
% GETTUPLESJOINEDWITH - returns the tuples of the given relation 
%                       INNER-joined with other relation by the specified 
%                       key fields 
%
% Input:
%   regular:
%       self:
%       otherRel: smartdb.relations.ARelation[1,1]
%       keyFieldNameList: char[1,]/cell[1,nFields] of char[1,]
%
%   properties:
%       joinType: char[1,] - type of join, can be
%           'inner' (DEFAULT) - inner join
%           'leftOuter' - left outer join
%           'rightOuter' - right outer join
%           'fullOuter' - full outer join
%
%       fieldDescrSource: char[1,] - defines where the field descriptions
%          are taken from, can be
%           'useOriginal' - field descriptions are taken from the left hand
%               side argument of the join operation
%           'useOther' - field descriptions are taken from the right hand
%               side of the join operation
%
% Output:
%   resRel: smartdb.relations.ARelation[1,1] - join result
%       
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-08-21 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargout>0
    varargout=cell(1,nargout);
    [varargout{:}]=self.getTuplesJoinedWithInternal(otherRel,...
        keyFieldNameList,varargin{:});
else
    self.getTuplesJoinedWithInternal(otherRel,keyFieldNameList,varargin{:});
end
    
  