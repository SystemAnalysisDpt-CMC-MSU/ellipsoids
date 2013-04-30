function nFields=getNFields(self)
% GETNFIELDS - returns number of fields in given object
%
% Usage: nFields=getNFields(self)
%
% Input:
%   regular:
%     self: CubeStruct [1,1]
% Output:
%   regular:
%     nFields: double [1,1] - number of fields in given object
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
nFields=self.getNFieldsInternal();