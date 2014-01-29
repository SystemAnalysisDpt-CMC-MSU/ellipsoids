function [SData,SIsNull,SIsValueNull]=generateEmptyDataSet(self,...
    minDimSizeVec,varargin)
% GENERATEEMPTYDATASET generates an empty data set in form of
% SData and SIsNull structures
%
% Usage: [SData, SIsNull]=self.generateEmptyDataSet()
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
    isZeroMinDim=true;
else
    isZeroMinDim=false;
end
if isZeroMinDim
    minDim=self.getMinDimensionality();
    [SData,SIsNull,SIsValueNull]=self.generateDefaultDataSet(...
        zeros(1,max(minDim+1,2)),varargin{:});
else
    minDimSizeVec=[minDimSizeVec,0];
    nMinDims=length(minDimSizeVec);
    %
    [SData,SIsNull,SIsValueNull]=self.generateDefaultDataSet(...
        [minDimSizeVec,zeros(1,max(0,2-nMinDims))],varargin{:});
end