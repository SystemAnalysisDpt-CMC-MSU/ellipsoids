function nElems=getNElemsInternal(self,varargin)
% GETNELEMSINTERNAL returns a number of elements in a given object
%
% Input:
%   regular:
%      self: 
%     
%   properties:
%       SData: struct[1,1] - data structure used as a source, self.SData is
%          used if SData is not specified
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if self.getNFields()>0
    nElems=prod(self.getMinDimensionSizeInternal(varargin{:}));
else
    nElems=0;
end