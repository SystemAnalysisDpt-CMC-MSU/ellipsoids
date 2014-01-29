function sizeMat=getFieldValueSizeMat(self,varargin)
% GETFIELDVALUESIZEMAT - returns a matrix composed from the size vectors
%                        for the specified fields
%
% Input:
%   regular:
%       self:
%
%   optional:
%       fieldNameList: cell[1,nFields] - a list of fileds for which the size 
%          matrix is to be generated
%
%   properties:
%       skipMinDimensions: logical[1,1] - if true, the dimensions from 1 up 
%           to minDimensionality are skipped
%
%       minDimension: numeric[1,1] - minimum dimension which definies a
%          minimum number of columns in the resulting matrix
%
% Output:
%   sizeMat: double[nFields,nMaxDims]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.prohibitProperty('SData',varargin);
sizeMat=self.getFieldValueSizeMatInternal(varargin{:});