function  obj=getFieldProjection(self,fieldNameList)
% GETFIELDPROJECTION - create object with specified fields using existing 
%                      table
%
% Input:
%   regular:
%       self: CubeStruct[1,1] - original object
%       fieldNameList: cell[1,nFields] of char[1,] - field name list
%   
% Output:
%   obj: DynamicCubeStruct[1,1] - projected object
%   
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-23 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
dataList=cell(1,3);
[dataList{:}]=self.getDataInternal('fieldNameList',fieldNameList);
obj=smartdb.cubes.DynamicCubeStruct(dataList{:},'fieldMetaData',...
    self.getFieldMetaData(fieldNameList),'minDimensionality',...
    self.getMinDimensionality());