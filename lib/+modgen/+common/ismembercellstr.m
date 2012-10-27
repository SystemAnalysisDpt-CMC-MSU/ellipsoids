function [isThereVec,indLocVec]=ismembercellstr(aList,bList,isHigherIndexUsed)
% ISMEMBERCELLSTR produces the same results as a built-in function
% "ismember" looking for the higher index if isHigherIndexUsed =true and
% lower index if isHigherIndexUsed=false (default)
%
% Input:
%   regular:
%       aList: char[1,]/cell[1,nAElem] of char[1,] - list of strings
%       bList: char[1,]/cell[1,nBElem] of char[1,] - list of strings
%
%   optional:
%       isHigherIndexUsed: logicalp[1,1] - if true, higher index is
%           searched for, lower otherwise (default)
%
% Output:
%   isThereVec: logical[1,nAElem] - contains true for those elements of
%       aList for which a matching element is found in bList
%   indLocVec: double[1,nAElem] - contains indices for those elements of
%   aList for which... (see above) and zero otherwise
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-05-08 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%
if nargin==2
    isHigherIndexUsed=false;
end
%
if ischar(aList)
    if ischar(bList)
        isThereVec=strcmp(aList,bList);
        indLocVec=double(isThereVec);
    else
        isThereVec=false;
        indLocVec=0;
        if isHigherIndexUsed
            for iB=1:length(bList)
                if strcmp(aList,bList{iB})
                    isThereVec=true;
                    indLocVec=iB;
                end
            end
        else
            for iB=1:length(bList)
                if strcmp(aList,bList{iB})
                    isThereVec=true;
                    indLocVec=iB;
                    break;
                end
            end
        end
    end
else
    isThereVec=false(size(aList));
    indLocVec=zeros(size(aList));
    if ischar(bList)
        if isHigherIndexUsed
            for iA=1:length(aList)
                if strcmp(aList{iA},bList)
                    isThereVec(iA)=true;
                    indLocVec(iA)=1;
                end
            end
        else
            for iA=1:length(aList)
                if strcmp(aList{iA},bList)
                    isThereVec(iA)=true;
                    indLocVec(iA)=1;
                    break;
                end
            end
        end
    else
        
        if isHigherIndexUsed
            for iA=1:length(aList)
                for iB=1:length(bList)
                    if strcmp(aList{iA},bList{iB})
                        isThereVec(iA)=true;
                        indLocVec(iA)=iB;
                    end
                end
            end
        else
            for iA=1:length(aList)
                for iB=1:length(bList)
                    if strcmp(aList{iA},bList{iB})
                        isThereVec(iA)=true;
                        indLocVec(iA)=iB;
                        break;
                    end
                end
            end
        end
    end
end