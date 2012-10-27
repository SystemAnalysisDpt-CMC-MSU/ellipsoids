function changeMinDimInternal(self,minDim)
% CHANGEMINDIM changes a dimensionality of CubeStruct object
%
% Input:
%   regular:
%       minDim: numeric[1,1] - new dimensionality
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if ~(isnumeric(minDim)&&numel(minDim)==1&&fix(minDim)==minDim&&minDim>=0)
    error([upper(mfilename),':wrongInput'],...
        'minDim is expected to be a non-negative scalar integer');
end
%
curMinDim=self.getMinDimensionality();
if curMinDim<minDim
    error([upper(mfilename),':wrongInput'],...
        'cannot increase dimensionality as it is not yet supported');
elseif curMinDim>minDim
    minDimSizeVec=self.getMinDimensionSizeInternal();
    nRestElems=prod(minDimSizeVec(minDim+1:end));
    firstDimSizeVec=minDimSizeVec(1:minDim);
    %
    fieldNameList=self.getFieldNameList();
    nFields=length(fieldNameList);
    if nRestElems~=1,
        for iField=1:nFields,
            fieldName=fieldNameList{iField};
            
            curIsValueNull=reshape(self.SIsValueNull.(fieldName),...
                [firstDimSizeVec nRestElems]);
            nextIsValueNull=any(curIsValueNull,minDim+1);
            %
            if ~isequal(curIsValueNull,repmat(nextIsValueNull,...
                    [ones(1,minDim) nRestElems])),
                error([upper(mfilename),':wrongInput'],[...
                    'It is impossible to remove key fields because SIsValueNull '...
                    'is not uniform along removed key fields for field %s'],...
                    fieldName);
            end
            self.SIsValueNull.(fieldName)=nextIsValueNull;
            %
        end
    end
    self.minDimensionality=minDim;
end