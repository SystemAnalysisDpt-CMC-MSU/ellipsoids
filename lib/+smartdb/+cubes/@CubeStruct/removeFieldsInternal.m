function removeFieldsInternal(self,removeFieldNameList)
% REMOVEFIELDSINTERNAL removes fields from given object
%
% Usage: removeFieldsInternal(self,varargin)
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - class object
%       removeFieldNameList: cell[1,] of char - list of field names to
%          delete
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
[~,indDel]=self.getIsFieldVecCheck(removeFieldNameList);
%
clearFieldNameList=self.fieldNameList(indDel);
self.SData=rmfield(self.SData,clearFieldNameList);
self.SIsNull=rmfield(self.SIsNull,clearFieldNameList);
self.SIsValueNull=rmfield(self.SIsValueNull,clearFieldNameList);
%
self.fieldMetaData(indDel)=[];
%
self.clearFieldsAsProps(clearFieldNameList);