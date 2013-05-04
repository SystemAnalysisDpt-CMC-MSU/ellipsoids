function  obj=getFieldProjection(self,fieldNameList)
% GETFIELDPROJECTION - project object with specified fields.
%
% Input:
%   regular:
%       self: ARelation[1,1] - original object
%       fieldNameList: cell[1,nFields] of char[1,] - field name list
%   
% Output:
%   obj: DynamicRelation[1,1] - projected object
%   
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-07-23 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
dataList=cell(1,3);
[dataList{:}]=self.getDataInternal('fieldNameList',fieldNameList);
obj=smartdb.relations.DynamicRelation(dataList{:},'fieldMetaData',...
    self.getFieldMetaData(fieldNameList));