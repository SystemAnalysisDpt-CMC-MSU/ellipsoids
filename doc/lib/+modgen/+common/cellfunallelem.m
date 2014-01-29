function resArray=cellfunallelem(hFunc,inpCell,varargin)
% CELLFUNALLELEM applies the specified function to all elements 
% in each cell of the specified cell array and returns array of results 
% for each cell
% 
% 
% Input:
%   regular:
%       hFunc: function_handle[1,1] - function to apply to all elements
%       inpCell: cell[nElem1,...,nElemN] - input array
%
%   properties:
%       same properties as a built-in cellfun function 
%          (UniformOutput for instance is supported)
%       
% Output:
%   resArray: numeric/logical[nElem1,...,nElemN] - calcualtion result
%
%   
% Example:
%   modgen.common.cellfunallelem(@any,{true,[false true;true true]})
%   ans =
%        1     1
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-08 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
nDimVec=cellfun('ndims',inpCell);
nDims=max(nDimVec(:));
sizeMat=zeros([nDims size(inpCell)]);
for iDim=1:nDims
    sizeMat(iDim,:)=reshape(cellfun('size',inpCell,iDim),1,[]);
end
%
nRealDimMat=sum(sizeMat~=1,1);
nRealDims=max(nRealDimMat(:));
%
for iRealDim=1:nRealDims-1
    inpCell=cellfun(hFunc,inpCell,'UniformOutput',false);
end
%
resArray=cellfun(hFunc,inpCell,varargin{:});