function [unqVec,indRight2LeftVec,indLeft2RightVec]=...
    uniquesortableobj(inpVec)
% UNIQUE implementation strictly for sortable entities i.e. for those
% that have 
%   1) full order defined by implementation of comparison operators 
%       @eq/isequal/isequaln/isequalwithequalnans, @ne, @gt, @lt, @le, @ge 
%   2) an implementation of @sort method that uses these operators 
%
% Usage: [outUnqVec,indRightToLeftVec,indLeftToRightVec]=...
%   modgen.common.uniquesortableobj(inpVec,fCompare);
%
% Input:
%   regular:
%     inpVec: cell[nObjects,1]/[1,nObjects] of objects
%
% Output:
%   outUnqVec: cell[nUniqObjects,1]/[1,nUniqObjects]
%   indRightToLeftVec: double[nUniqObjects,1] : all
%       fCompare(inpVec(indRightToLeftVec)==outUnqVec)==true
%   indLeftToRightVec: double[nObjects,1] : all
%       all(fCompare(outUnqVec(indLeftToRightVec)==inpVec))
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2015-Oct-09 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
isRowInput = isrow(inpVec);
%
inpVec = inpVec(:);
nInpElems = numel(inpVec);
%
if nargout > 1
    [sortedInpVec,indSortedVec] = sort(inpVec);
else
    sortedInpVec = sort(inpVec);
end
%
isEqualSortedNeighborVec=sortedInpVec(1:nInpElems-1)~=...
    sortedInpVec(2:nInpElems);
%
if (nInpElems ~= 0)
    isEqualSortedNeighborVec = [true; isEqualSortedNeighborVec];
else
    isEqualSortedNeighborVec = zeros(0,1);
end
%
unqVec = sortedInpVec(isEqualSortedNeighborVec);
if nargout > 1
    indRight2LeftVec = indSortedVec(isEqualSortedNeighborVec);
end
%
if nargout == 3
    isEqualSortedNeighborVec = full(isEqualSortedNeighborVec);
    if nInpElems == 0
        indLeft2RightVec = zeros(0,1);
    else
        indLeft2RightVec = cumsum(isEqualSortedNeighborVec);
        indLeft2RightVec(indSortedVec) = indLeft2RightVec;
    end
end
%
if isRowInput
    unqVec = unqVec.';
end

