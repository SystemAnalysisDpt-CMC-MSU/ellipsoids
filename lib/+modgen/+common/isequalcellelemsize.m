function isPositive=isequalcellelemsize(value1,value2)
isPositive=false;
nDimVec1=cellfun('ndims',value1);
nDimVec2=cellfun('ndims',value2);
if ~isequal(nDimVec1,nDimVec2)
    return;
end
for iDim=1:max(nDimVec1)
    if ~isequal(cellfun('size',value1,iDim),...
            cellfun('size',value2,iDim))
        return;
    end
end
isPositive=true;