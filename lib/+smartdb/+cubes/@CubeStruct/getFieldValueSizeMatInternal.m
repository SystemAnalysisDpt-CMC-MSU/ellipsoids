function sizeMat=getFieldValueSizeMatInternal(self,varargin)
% GETFIELDVALUESIZEMAT returns a matrix composed from the size
% vectros for the specified fields
%
% Input:
%   regular:
%       self:
%
%   optional:
%       fieldNameList: cell[1,nFields] - a list of fileds for
%          which the size matrix is to be generated
%
%   properties:
%       skipMinDimensions: logical[1,1] - if true, the
%           dimensions from 1 up to minDimensionality are skipped
%           (false by default)
%
%       minDimension: numeric[1,1] - minimum dimension which definies a
%          minimum number of columns in the resulting matrix
%
%       SData: struct[1,1] - structure to be used instead of self.SDat
%       
%
% Output:
%   sizeMat: double[nFields,nMaxDims]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-09-08 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
self.checkIfObjectScalar();
[reg,prop]=modgen.common.parseparams(varargin);
if numel(reg)>1
    error([upper(mfilename),':wrongInput'],...
        'too many regular parameters');
elseif numel(reg)==0
    fieldNameList=self.getFieldNameList();
else
    fieldNameList=reg{1};
    if ischar(fieldNameList)
        fieldNameList={fieldNameList};
    end
end
%
isMinDimSkipped=false;
isMinDimSpec=false;
isSDataSpec=false;
%
nProp=length(prop);
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'skipmindimensions',
            isMinDimSkipped=prop{k+1};
        case 'mindimension',
            minDim=prop{k+1};
            isMinDimSpec=true;
        case 'sdata',
            isSDataSpec=true;
            SData=prop{k+1};
        otherwise,
            error([upper(mfilename),':unknownProp'],...
                'property %s is not supported',prop{k});
    end
end
%
if ~isSDataSpec
    SData=self.SData;
end
%
if ~isMinDimSpec
    minDim=self.getMinDimensionality();
end
%
nFields=length(fieldNameList);
maxDim=minDim;
if nFields>0
    maxDim=max(max(self.applyGetFuncInternal(@ndims,fieldNameList,...
        'SData',SData)),...
        maxDim);
end
%
sizeMat=ones(nFields,maxDim);
for iField=1:nFields
    fieldName=fieldNameList{iField};
    nDims=ndims(SData.(fieldName));
    sizeMat(iField,1:nDims)=size(SData.(fieldName));
end
%
if isMinDimSkipped
    sizeMat(:,1:self.getMinDimensionality)=[];
end