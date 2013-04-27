function isValueNullVec=getIsFieldValueNull(self,fieldNameList)
% GETISFIELDVALUENULL - returns a vector indicating whether a particular
%                       field is composed of null values completely
%
% Usage: isValueNullVec=getIsFieldValueNull(self,fieldNameList)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] 
%
%   optional:
%     fieldNameList: cell[1,nFields] of char[1,] - list of field names
%
% Output:
%   regular:
%     isValueNullVec: logical[1,nFields]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargin==2
    inpArgList={'fieldNameList',fieldNameList};
else
    inpArgList={};
end
isValueNullVec=modgen.common.cellfunallelem(@all,...
    struct2cell(self.getDataInternal('structNameList',...
    {'SIsValueNull'},inpArgList{:})));