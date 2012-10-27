function clearDataInternal(self)
% CLEARDATA deletes all the data from the object
%
% Usage: self.clearData(self)
%
% Input:
%   regular:
%     self: CubeStruct [1,1] - class object
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
minDim=self.getMinDimensionality();
[self.SData,self.SIsNull,self.SIsValueNull]=self.generateDefaultDataSet(zeros(1,minDim));