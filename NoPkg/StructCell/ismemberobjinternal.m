function [isIn,indIn]=ismemberobjinternal(aCell,bCell,funHandle)
% ISMEMBEROBJINTERNAL ismember for cellarrays of objects of any type
%
% Usage: [isIn,indIn]=ismemberobjinternal(aCell,bCell,funHandle);
%
%input:
%   regular:
%      aCell: cell[nObjectsLeft,1]
%      bCell: cell[nObjectsRight,1]
%   optional:
%      funHandle: compare function for objects,
%           if not present ismemberobjinternal uses isequalwithequalnans
%           funHandle:
%           @(objectLeft,objectRight)compare(objectLeft,objectRight)
%output:
%   isIn: logical[nObjectsLeft,1]
%   indIn: logical[nObjectsLeft,1]
%
%Example:
%
%   aCell={struct('a',1,'b',2)}
%   bCell={struct('a',2,'b',2); struct('a',111,'g','555')}
%   [isIn,indIn]=ismemberobjinternal(aCell,bCell,@(x,y)x.a==y.a)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%%
if nargin<3
    funHandle=@isequalwithequalnans;
end
%%
if isempty(bCell)
    isIn=false(size(aCell));
    indIn=zeros(size(aCell));
    return;
end
if size(aCell,2)~=1
    error('size of aCell must be [n,1]');
end
if size(bCell,2)~=1
    error('size of bCell must be [n,1]');
end
isCell=iscell(aCell);
if iscell(bCell)~=isCell,
    error('aCell and bCell must be either cells or non cells simultaneosly');
end
if ~isCell,
    aCell=num2cell(aCell);
    bCell=num2cell(bCell);
end
aCellMat=repmat(aCell.',length(bCell),1);
bCellMat=repmat(bCell,1,length(aCell));
isEqualMat=cellfun(funHandle,aCellMat,bCellMat);
isIn=any(isEqualMat,1);
if nargout>1,
    [indB,indA]=find(isEqualMat);
    indA=reshape(indA,[],1);
    indB=reshape(indB,[],1);
    indIn=accumarray(indA,indB,[length(aCell) 1],@min,0);
end