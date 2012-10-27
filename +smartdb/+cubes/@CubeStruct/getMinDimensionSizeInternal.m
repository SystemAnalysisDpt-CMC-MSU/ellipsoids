function minDimensionSizeVec=getMinDimensionSizeInternal(self,varargin)
% GETMINDIMENSIONSIZE returns a size vector for the specified
% dimensions. If no dimensions are specified, a size vector for
% all dimensions up to minimum CubeStruct dimension is returned
%
% Input:
%   regular:
%       self:
%   optional:
%       dimNumVec: numeric[1,nDims] - a vector of dimension
%           numbers
%   property:
%       SData: struct[1,1] - data structure used as a source, if not
%          specified, self.SData is used
%
% Output:
%   minDimensionSizeVec: double [1,nDims] - a size vector for
%      the requested dimensions
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
minDimensionSizeVec=self.getMinDimensionSizeByDataInternal(varargin{:});