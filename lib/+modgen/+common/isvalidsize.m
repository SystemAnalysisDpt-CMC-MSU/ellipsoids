function isValidVec=isvalidsize(varargin)
% ISVALIDSIZE compares size of input arrays with size mask. 
%   Size mask can contain nans that allow any size for a corresponding dimension.
%   Function automatically adds 1 at the end of size. For example, array 3x2 is also
%   array 3x2x1 and 3x2x1x1x1 e.t.c;
%
% Usage isValid=isvalidsize(firstArr,secArr,lastArr,sizeVec);
%
% Input:
%   regular:
%       firstArr: any[]
%       secArr: any[]
%       ......
%       lastArr: any[]
%       sizeVec: double[1,nDims] - mask for check of size, can contain
%           nans that mean that a corresponding dimension's size is ignored
%
% Output:
%   isValidVec: logical[1,N] - true if corresponding array is proper with
%       mask
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
sizeCell=cellfun(@size,varargin(1:end-1),'UniformOutput',false);
sizeVec=varargin{end};
nCheckDim=numel(sizeVec);
%
if nCheckDim==0
    isValidVec=max(cellfun(@prod,sizeCell))==0;
else
    if nCheckDim==1
        sizeVec=[sizeVec 1];
        nCheckDim=2;
    end
    %
    nDimVec=cellfun('ndims',varargin(1:end-1));
    maxDim=max([nDimVec nCheckDim]);
    addVec=maxDim-nDimVec;
    isnZero=addVec~=0;
    if any(isnZero)
        addVec(~isnZero)=[];
        addCell=num2cell(addVec);
        sizeCell(isnZero)=cellfun(@(x,y)[x ones(1,y)],...
            sizeCell(isnZero),addCell,...
            'UniformOutput',false);
    end
    isToCheck=~isnan(sizeVec);
    checkSize=sizeVec(isToCheck);
    %
    isValidVec=(cellfun(@(x) isequal(x(isToCheck),checkSize),sizeCell))&...
        (nDimVec<=nCheckDim);
end