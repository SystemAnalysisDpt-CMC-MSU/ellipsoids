function value=getFieldNameList(self)
% GETFIELDNAMELIST - returns the list of CubeStruct object field names
%
% Usage: value=getFieldNameList(self)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] 
% Iutput:
%   regular:
%     value: char cell [1,nFields] - list of CubeStruct object field
%         names
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.checkIfObjectScalar();
value=self.fieldNameList;