function initByNullDataSet(self,dimVec)
% INITBYDEFAULTDATASET - initializes cube struct object with null value 
%                        arrays of specified size based on minDimVec 
%                        specified. 
% 
% For instance, if minDimVec=[2,3,4,5,6] and minDimensionality of cube 
% struct object cb is 2, then cb.initByEmptyDataSet(minDimVec) will create 
% a cube struct object with element array of [2,3] size where each element 
% has size of [4,5,6]
%
% Input:
%   regular:
%       self:
%   optional
%       minDimVec: double[1,nDims] - size vector of null value arrays
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-18 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
if nargin<2
    dimVec=self.getMinDimensionSizeByDataInternal();
end
dimVec=[dimVec,1];
nMinDims=length(dimVec);
%
[self.SData,self.SIsNull,self.SIsValueNull]=self.generateDefaultDataSet(...
    [dimVec,ones(1,max(0,2-nMinDims))]);