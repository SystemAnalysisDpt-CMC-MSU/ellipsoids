function outArray=cat(dimNum,varargin)
if nargin>=2
    className=class(varargin{1});
    isEmptyVec=cellfun(@(x)max(size(x)),varargin)==0;
    if all(isEmptyVec)
        outArray=modgen.common.type.createarray(className,[0 0]);
    else
        outArray=cat(dimNum,varargin{~isEmptyVec});
    end
else
    outArray=cat(dimNum);
end