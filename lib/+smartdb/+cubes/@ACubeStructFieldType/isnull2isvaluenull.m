function isNullArray=isnull2isvaluenull(isNullArray,minDim)
% ISNULL2ISVALUENULL transaltes is-null indicators for cells of
% CubeStruct object field value into is-null indicators for the cells
% in whole
%
% Input:
%   regular:
%       isNullArray: logical[]/cell[]
%   optional:
%       minDim: double[1,1] - dimensionality of CubeStruct, by
%       default it equals ndims(isNullArray)
%
% Output:
%   isNullValueArray: logical[]
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if nargin<2
    minDim=ndims(isNullArray);
end
%
sizeVec=modgen.common.getfirstdimsize(isNullArray,...
    max(ndims(isNullArray),minDim+1));
minDimSizeVec=sizeVec(1:minDim);
valueDimSizeVec=sizeVec(minDim+1:end);
%
if isempty(isNullArray)
    if isempty(minDimSizeVec)
        isNullArray=logical.empty(0,0);
    else
        isNullArray=false([minDimSizeVec,1]);
    end
else
    if modgen.common.iscelllogical(isNullArray)
        isNullArray=modgen.common.cellfunallelem(...
            @all,isNullArray)&...
            ~cellfun('isempty',isNullArray);
    elseif iscell(isNullArray)
        isNullArray=cellfun(...
            @smartdb.cubes.ACubeStructFieldType.isnull2isvaluenull,...
            isNullArray,'UniformOutput',false);
        isNullArray=modgen.common.cellfunallelem(...
            @all,isNullArray)&...
            ~cellfun('isempty',isNullArray);
    end
    isNullArray=applyAllForValueDims(isNullArray);
end
    function outArray=applyAllForValueDims(inpArray)
        if isempty(minDimSizeVec)
            outArray=logical.empty(0,0);
        else
            outArray=all(...
                reshape(inpArray,[minDimSizeVec,prod(valueDimSizeVec)]),...
                minDim+1);
        end
    end
end