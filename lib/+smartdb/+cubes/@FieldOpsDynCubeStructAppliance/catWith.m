function catWith(self,varargin)
% CATWITH concatenates two CubeStruct objects by combining their fields
% Usage: self.catWith(inpObj)
%
% Input:
%   regular:
%       self: 
%       inpObj: CubeStruct[1,1] - object to concatenate with
%
%   properties:
%       duplicateFields: char[1,] - duplicate fields treat mode, the
%          following modes are supported:
%
%           'exception' - exception is thrown if some duplicate fields are
%              found
%           'useOriginal' - if some field exists in both original and new
%              relations, the one from the original relation is used
%
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-04-15 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.catWithInternal(varargin{:});