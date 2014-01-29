function value=getFieldDescrList(self,fieldNameList)
% GETFIELDDESCRLIST - returns the list of CubeStruct field descriptions
%
% Usage: value=getFieldDescrList(self)
%
% Input:
%   regular:
%       self: CubeStruct [1,1]
%   optional:
%       fieldNameList: cell[1,nSpecFields] of char[1,] - field names for
%          which descriptions should be returned
%
% Output:
%   regular:
%     value: char cell [1,nFields] - list of CubeStruct object field
%         descriptions
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-06 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.checkIfObjectScalar();
if nargin==1
    value=self.fieldDescrList;
else
    modgen.common.type.simple.checkgen(fieldNameList,'iscellofstrvec(x)');
    value=self.getFieldMetaData(fieldNameList).getDescriptionList();
end