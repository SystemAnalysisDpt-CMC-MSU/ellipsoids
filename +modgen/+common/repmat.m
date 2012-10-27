function outArray=repmat(inpArray,varargin)
if nargin==2&&isempty(varargin{1})
    outArray=modgen.common.type.createarray(class(inpArray),[0 0]);
else
    outArray=repmat(inpArray,varargin{:});
end
    