function [SDataNew,SIsNullNew,SIsValueNullNew]=generateDefaultDataSet(...
    self,minDimensionSizeVec,varargin)
% GENERATEDEFAULTDATASET generates data structures of specified size filled
% with default values
%
% Usage: [SData, SIsNull,SIsValueNull]=self.generateEmptyDataSet()
%
% Input:
%   regular:
%       self: CubeStruct [1,1] - class object
%
%   optional:
%       minDimensionSizeVec: numeric[1,minDimensionality] - 
%           vector of the first dimension sizes     
%
%   properties:
%       fieldNameList: cell[1,] of char[1,] - list of fields for which data
%           should be generated, if not specified, all fields from the
%           relation are taken
%
% Output:
%   SData: struct[1,1] - data structure with cells
%   SIsNull: struct[1,1] - is null indicator structure for CubeStruct
%      cells' content
%   SIsValueNull: struct[1,1] - is null indicators for CubeStruct cells' in
%      whole
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-21 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargin<2
    minDimensionSizeVec=self.getMinDimensionSizeVec();
end
[~,~,fieldNameList]=modgen.common.parseparext(varargin,...
    {'fieldNameList';self.fieldNameList;'iscellofstring(x)'},0);
%
nFields=length(fieldNameList);
SDataNew=struct();
SIsNullNew=struct();
SIsValueNullNew=struct();
fieldMetaDataVec=self.getFieldMetaData(fieldNameList);
for iField=1:nFields
    fieldName=fieldNameList{iField};
    [SDataNew.(fieldName),...
        SIsNullNew.(fieldName),...
        SIsValueNullNew.(fieldName)]=...
                fieldMetaDataVec(iField).generateDefaultFieldValue(minDimensionSizeVec);
end