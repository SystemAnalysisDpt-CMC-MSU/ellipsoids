function [isThereVec,indLocVec]=ismembercellstr(leftList,rightList,...
    isHigherIndexUsed)
% ISMEMBERCELLSTR produces the same results as the built-in function
%   "ismember" looking for the higher index if isHigherIndexUsed =true and
%   lower index if isHigherIndexUsed=false (default)
%
% Input:
%   regular:
%       leftList: char[1,]/cell[1,nLeftElems] of char[1,] - list of strings
%       rightList: char[1,]/cell[1,nRightElems] of char[1,] - list of strings
%   optional:
%       isHigherIndexUsed: logical[1,1] - if true, higher index is
%           searched for, lower otherwise (default)
%
% Output:
%   isThereVec: logical[1,nLeftElems] - contains true for those elements of
%       aList for which a matching element is found in bList
%   indLocVec: double[1,nLeftElems] - contains indices for those elements of
%       aList for which... (see above) and zero otherwise
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-08 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
if nargin==2
    isHigherIndexUsed=false;
end
%
nRightElems=numel(rightList);
nLeftElems=numel(leftList);
%
if ischar(leftList)
    if ischar(rightList)
        isThereVec=strcmp(leftList,rightList);
        indLocVec=double(isThereVec);
    else
        isThereVec=false;
        indLocVec=0;
        if isHigherIndexUsed
            for iRightElem=1:nRightElems
                if strcmp(leftList,rightList{iRightElem})
                    isThereVec=true;
                    indLocVec=iRightElem;
                end
            end
        else
            for iRightElem=1:nRightElems
                if strcmp(leftList,rightList{iRightElem})
                    isThereVec=true;
                    indLocVec=iRightElem;
                    break;
                end
            end
        end
    end
else
    isThereVec=false(size(leftList));
    indLocVec=zeros(size(leftList));
    if ischar(rightList)
        if isHigherIndexUsed
            for iLeftElem=1:nLeftElems
                if strcmp(leftList{iLeftElem},rightList)
                    isThereVec(iLeftElem)=true;
                    indLocVec(iLeftElem)=1;
                end
            end
        else
            for iLeftElem=1:nLeftElems
                if strcmp(leftList{iLeftElem},rightList)
                    isThereVec(iLeftElem)=true;
                    indLocVec(iLeftElem)=1;
                    break;
                end
            end
        end
    else
        if isHigherIndexUsed
            for iLeftElem=1:nLeftElems
                for iRightElem=1:nRightElems
                    if strcmp(leftList{iLeftElem},rightList{iRightElem})
                        isThereVec(iLeftElem)=true;
                        indLocVec(iLeftElem)=iRightElem;
                    end
                end
            end
        else
            for iLeftElem=1:nLeftElems
                for iRightElem=1:nRightElems
                    if strcmp(leftList{iLeftElem},rightList{iRightElem})
                        isThereVec(iLeftElem)=true;
                        indLocVec(iLeftElem)=iRightElem;
                        break;
                    end
                end
            end
        end
    end
end