function propVal=getField(self,fieldName,varargin)
% GETFIELD - returns values of given field 
%
% Usage: propVal=getField(self,fieldName)
%
% Input:
%   regular:
%     self: CubeStruct[1,1]
%     fieldName: char[1,] - name of field
%
% Output:
%   regular:
%     propVal: array [] of some type - values of given field 
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.checkIfObjectScalar();
propVal=self.SData.(fieldName);
