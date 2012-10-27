function reshapeDataInternal(self,sizeVec)
% RESHAPEDATAINTERNAL reshapes CubeStruct elements based on a specified size vector
%
% Input:
%   regular:
%       self: CubeStruct[1,1]
%       sizeVec: [1,nDims]/[nDims,1] - expected size vector for resulting
%          CubeStruct object
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
self.checkIfObjectScalar();
minDimSize=self.getMinDimensionSizeInternal();
%
if ~(modgen.common.isvec(sizeVec)&&isnumeric(sizeVec)&&all(sizeVec>=0)&&...
        all(fix(sizeVec)==sizeVec))
    error([upper(mfilename),':wrongInput'],...
        'sizeVec is expected to be a vector of not-negative integers');
end
%
if size(sizeVec,1)>1
    sizeVec=sizeVec.';
end
%
if prod(sizeVec)~=prod(minDimSize)
    error([upper(mfilename),':wrongInput'],...
        'number of cube elements cannot change');
end
%
newMinDim=length(sizeVec);
%
valueSizeMat=self.getFieldValueSizeMat('skipMinDimensions',true);
fieldNameList=self.getFieldNameList();
for iField=1:length(fieldNameList)
    fieldName=fieldNameList{iField};
    %
    self.SData.(fieldName)=reshapeRelaxed(...
        self.SData.(fieldName),[sizeVec,valueSizeMat(iField,:)]);
    self.SIsNull.(fieldName)=reshapeRelaxed(...
        self.SIsNull.(fieldName),[sizeVec,valueSizeMat(iField,:)]);
    self.SIsValueNull.(fieldName)=reshapeRelaxed(...
        self.SIsValueNull.(fieldName),sizeVec);
end
%
self.minDimensionality=newMinDim;
end
function value=reshapeRelaxed(value,sizeVec)
if numel(sizeVec)==1
    sizeVec=[sizeVec,1];
elseif numel(sizeVec)==0
    sizeVec=[0 0];
end
value=reshape(value,sizeVec);
end