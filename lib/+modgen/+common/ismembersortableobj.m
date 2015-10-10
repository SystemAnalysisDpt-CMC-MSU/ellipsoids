function [isThereVec,indThereVec] = ismembersortableobj(firstVec,secVec)
% ISMEMBER implementation strictly for sortable entities i.e. for those
% that have 
%   1) full order defined by implementation of comparison operators 
%       @eq/isequal/isequaln/isequalwithequalnans, @ne, @gt, @lt, @le, @ge 
%   2) an implementation of @sort method that uses these operators 
%
% Usage: [isThereVec,indThereVec]=...
%   modgen.common.ismembersortableobj(leftVec,rightVec);
%
% Input:
%   regular:
%       leftVec: any[nObjectsLeft,1]
%       rightVec: any[nObjectsRight,1]
%
% Output:
%   isThereVec: logical[nObjectsLeft,1]
%   indThereVec: double[nObjectsLeft,1]
% 
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 09-Oct-2015 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2015 $
%
import modgen.common.uniquesortableobj;
%
if isscalar(firstVec) || isscalar(secVec)
    unitedVec = [firstVec(:);secVec(:)];
    nFirstElems = numel(firstVec);
    isThereVec = unitedVec(1:nFirstElems)==unitedVec(1+nFirstElems:end);
    if any(isThereVec)
        if isscalar(secVec)
            indThereVec = double(isThereVec);        
        else
            indThereVec = find(isThereVec);
            indThereVec = indThereVec(1);
            isThereVec = any(isThereVec);
        end
    else
        isThereVec  = false(size(firstVec));
        indThereVec = zeros(size(firstVec));
    end
else
    [unqFirstVec,~,indFirstLeft2RightVec] = uniquesortableobj(firstVec(:));
    if nargout <= 1
        unqSecVec = uniquesortableobj(secVec(:));
    else
        [unqSecVec,indSecRight2LeftVec] = uniquesortableobj(secVec(:));
    end
	%
    [unionSortedVec,indUnionSortedVec] = sort([unqFirstVec;unqSecVec]);
	%
    isSortedUnionNeighborEqVec = unionSortedVec(1:end-1)==...
        unionSortedVec(2:end);
    indSortedUnionNeighborEqVec = indUnionSortedVec(...
        isSortedUnionNeighborEqVec);
    %
    if nargout <= 1
        isThereVec = ismember(indFirstLeft2RightVec,...
            indSortedUnionNeighborEqVec);
    else
        nFirstUnqElems = size(unqFirstVec,1);
        isSortedUnionNeighborEqVec = find(isSortedUnionNeighborEqVec);
        [isThereVec,indThereVec] = ismember(indFirstLeft2RightVec,...
            indSortedUnionNeighborEqVec);
        isFirstAmonthEqSortedUnionNeighborsVec =...
            isSortedUnionNeighborEqVec(indThereVec(isThereVec));
        indWhereFirstAmongEqNeighborsVec =...
            indSecRight2LeftVec(indUnionSortedVec(...
            isFirstAmonthEqSortedUnionNeighborsVec+1)-nFirstUnqElems);
        indThereVec(isThereVec) = indWhereFirstAmongEqNeighborsVec;
    end
end
isThereVec = reshape(isThereVec,size(firstVec));
if nargout > 1
    indThereVec = reshape(indThereVec,size(firstVec));
end