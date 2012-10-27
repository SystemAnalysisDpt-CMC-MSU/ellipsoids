function minDimensionSizeVec=getMinDimensionSizeByDataInternal(self,varargin)
% GETMINDIMENSIONSIZEBYDATAINTERNAL returns a size vector for the specified
% dimensions. If no dimensions are specified, a size vector for
% all dimensions up to minimum CubeStruct dimension is returned
%
% Input:
%   regular:
%       self:
%   optional:
%       dimNumVec: numeric[1,nDims] - a vector of dimension
%           numbers
%   property:
%       SData: struct[1,1] - data structure used as a source, if not
%          specified, self.SData is used
%
% Output:
%   minDimensionSizeVec: double [1,nDims] - a size vector for
%      the requested dimensions
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-01-31 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
[reg,prop]=modgen.common.parseparams(varargin,{'SData'},[0,1]);
%
if ~isempty(prop)
    SData=prop{2};
else
    SData=self.SData;
end
%
fieldNameList=fieldnames(SData);
nFields=length(fieldNameList);
if nFields>0
    fieldName=fieldNameList{1};
end
%
self.checkIfObjectScalar();
minDim=self.getMinDimensionality();
if nFields==0
    minDimensionSizeVec=zeros(1,minDim);
else
    minDimensionSizeVec=modgen.common.getfirstdimsize(...
        SData.(fieldName),minDim);
end
if ~isempty(reg)
    dimNumVec=reg{1};
    if max(dimNumVec)>minDim
        error([upper(mfilename),':wrongInput'],...
            ['projection of dimension vector is only ',...
            'supported up to the minimum CubeStruct dimension']);
    end
    minDimensionSizeVec=minDimensionSizeVec(dimNumVec);
end