function resObj=getCopy(self,varargin)
% GETCOPY - returns an object copy
%
% Usage: resObj=getCopy(self)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] - current CubeStruct object
%   optional:
%     same as for getData
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
p=metaclass(self);
resObj=feval(p.Name,self,varargin{:});