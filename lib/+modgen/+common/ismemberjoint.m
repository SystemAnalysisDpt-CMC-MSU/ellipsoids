function [isThereVec,indThereVec]=ismemberjoint(leftCArr,rightCArr,varargin)
% ISMEMBERJOINT perform joint ismember operation for two cell arrays
%
% Usage: [isThereVec,indThereVec]=ismemberjoint(leftCArr,rightCArr)
%
% Input:
%   regular:
%       leftCArr: cell[n1,...,nk] of any[] -cell array of arbitrary size,
%          in the case dim is not given (see below for
%          details) it is assumed that all cells must contain either
%          columns or rows of some type and of the same size (either
%          [1,nLeft] or [nLeft,1]); if dim is given then size of all items
%          in inpCell should be the same (and equal to nLeft) only along
%          dimension equal to dim
%       rightCArr: cell[n1,...,nk] of any[] - cell array
%          of the same structure and size as leftCArr which
%          means that types and orientation (rows or columns, if dim is not
%          given) and size along other dimensions that dim (if the latter
%          is given) of respective cells in leftCArr and rightCArr should
%          be the same.
%
%     Note: empty elements present in both leftCArr and rightCArr on
%            THE SAME PLACES are ignored
%
%   optional:
%       dim: double [1,1] - main dimension along which ismemberjoint is
%           performed
%
%       checkSizeIfEmpty: logical[1,1] - if true, then consistency of
%           sizes  of the corresponding cells in leftCArr and rightCArr is
%           performed even in the case one of them is empty along dimension
%           given by dim, if false, this check is omitted; by default it is
%           true
%
%     Note: For other optional arguments and properties see descriptions of
%       modgen.common.ismemberrows and modgen.common.uniquerows functions
%       for their arguments immediately following after isInteger input
%       argument
%
% Output:
%   isThereVec: logical[nLeftElem,1]/[1,nLeft] array of membership indicators
%       of all respective elements within leftCArr to all respective
%       elements within rightCArr, nLeftElem is size of arrays contained
%       within leftCArr arrays for dimention dim
%   indThereVec: double[nLeftElem,1]/[1,nLeft]- indices indicating location of
%       respective elements within leftCArr in rightCArr elements
%
% Examples:
%
%   [isThereVec,indThereVec]=ismemberjoint({[1 2],{'a','b'};[3...
%       4],{'c','d'}},{[1 2 3],{'a','b','c'};[3 4 5],{'c','d','m'}})
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-10-09 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-19 $
%
import modgen.common.uniquejoint;
import modgen.common.throwerror;
import modgen.common.ismembersortableobj;
%
if nargin<2,
    throwerror('wrongInput',...
        'incorrect number of input arguments');
end
%
if ~iscell(leftCArr)||~iscell(rightCArr)
    throwerror('wrongInput',...
        'both arguments should be cell arrays');
end
%
[reg,prop]=parseparams(varargin);
nReg=numel(reg);
if nReg<1,
    dim=[];
else
    dim=reg{1};
    isnWrong=isnumeric(dim)&&numel(dim)==1;
    if isnWrong,
        dim=double(dim);
        isnWrong=isreal(dim)&&floor(dim)==dim&&dim>=1&&isfinite(dim);
    end
    if ~isnWrong,
        throwerror('wrongInput',...
            'scalar number expected as the third argument');
    end
end
%
leftCArr=leftCArr(:);
rightCArr=rightCArr(:);
%
nLeft=length(leftCArr);
%
if nLeft~=length(rightCArr)
    throwerror('wrongInput',...
        'both arguments should have the same size');
end
%
if nLeft==0
    throwerror('wrongInput',...
        'both arguments should be non-empty cells');
end
%
leftTypeCell=cellfun(@class,leftCArr,'UniformOutput',false);
rightTypeCell=cellfun(@class,rightCArr,'UniformOutput',false);
isEqualType=cellfun(@(x,y)isequal(x,y),leftTypeCell,rightTypeCell);
if ~all(isEqualType)
    throwerror('wrongInput',...
        'types of corresponding input cell content should be the same');
end
%
if isempty(dim),
    isEmptyVec=cellfun('isempty',leftCArr)&cellfun('isempty',rightCArr);
    leftCArr(isEmptyVec)=[];
    rightCArr(isEmptyVec)=[];
    nLeftComp=length(leftCArr);
    if nLeftComp==0
        isThereVec=false(0,1);
        indThereVec=zeros(0,1);
        return;
    end
    leftSize=size(leftCArr{1});
    isEqualLeftSize=modgen.common.checksize(leftCArr{:},leftSize);
    if ~isEqualLeftSize
        throwerror('wrongInput',...
            'size of all items of the first cell array should be the same');
    end
    %
    rightSize=size(rightCArr{1});
    isEqualRightSize=modgen.common.checksize(rightCArr{:},rightSize);
    if ~isEqualRightSize
        throwerror('wrongInput',...
            'size of all items of the second cell array should be the same');
    end
    %
    nLeftElem=numel(leftCArr{1});
    lengthLeft=length(leftCArr{1});
    %
    nRightElem=numel(rightCArr{1});
    lengthRight=length(rightCArr{1});
    %
    if (nLeftElem~=lengthLeft)||(nRightElem~=lengthRight)
        throwerror('wrongInput',...
            'all cell items should be either columns or rows ');
    end
    %
    if nLeftElem==0
        isThereVec=false(leftSize);
        indThereVec=nan(leftSize);
        return;
    end
    leftCArr=cellfun(@(x)x(:),leftCArr,'UniformOutput',false);
    rightCArr=cellfun(@(x)x(:),rightCArr,'UniformOutput',false);
else
    if nReg<2,
        checkSizeIfEmpty=true;
    else
        checkSizeIfEmpty=reg{2};
    end
    %
    nLeftElem=size(leftCArr{1},dim);
    %
    %cellfun('size',...,dim) doesn't work properly for cell arrays of
    %enums so we are forced to use a slower variant here: cellfun(@(x)...)
    isEqualLeftSize=all(cellfun(@(x)size(x,dim),leftCArr(:))==nLeftElem);
    if ~isEqualLeftSize
        throwerror('wrongInput',...
            ['size of all items in leftCArr along %d-th ',...
            'dimension should be the same'],dim);
    end
    %
    nRightElem=size(rightCArr{1},dim);
    %
    %cellfun('size',...,dim) doesn't work properly for cell arrays of
    %enums so we are forced to use a slower variant here: cellfun(@(x)...)
    isEqualRightSize=all(cellfun(@(x)size(x,dim),rightCArr)==nRightElem);
    if ~isEqualRightSize
        throwerror('wrongInput',...
            ['size of all items in rightCArr along %d-th ',...
            'dimension should be the same'],dim);
    end
    %
    if checkSizeIfEmpty||(nLeftElem>0&&nRightElem>0),
        if dim>1,
            permVec=[dim 1:dim-1 dim+1:max(vertcat(...
                cellfun('ndims',leftCArr(:)),cellfun('ndims',rightCArr(:))))];
            leftCArr=cellfun(@(x)permute(x,permVec),leftCArr,'UniformOutput',false);
            rightCArr=cellfun(@(x)permute(x,permVec),rightCArr,'UniformOutput',false);
        end
        leftSize=cellfun(@size,leftCArr,'UniformOutput',false);
        rightSize=cellfun(@size,rightCArr,'UniformOutput',false);
        %
        if ~isequal(cellfun(@(x)x(2:end),leftSize,'UniformOutput',false),...
                cellfun(@(x)x(2:end),rightSize,'UniformOutput',false)),
            throwerror('wrongInput',[...
                'sizes of all items in leftCArr and rightCArr '...
                'along all dimensions save %d-th one should be the same'],dim);
        end
    end
    %
    if nLeftElem==0,
        if dim>1,
            isThereVec=false(1,0);
            indThereVec=nan(1,0);
        else
            isThereVec=false(0,1);
            indThereVec=nan(0,1);
        end
        return;
    end
    %
    if nRightElem==0,
        if dim>1
            isThereVec=false(1,nLeftElem);
            indThereVec=zeros(1,nLeftElem);
        else
            isThereVec=false(nLeftElem,1);
            indThereVec=zeros(nLeftElem,1);
        end
        return;
    end
    %
    isReshape=max(cellfun('length',leftSize),cellfun('length',rightSize))>2;
    if any(isReshape),
        leftCArr(isReshape)=cellfun(@(x)reshape(x,nLeftElem,[]),...
            leftCArr(isReshape),'UniformOutput',false);
        rightCArr(isReshape)=cellfun(@(x)reshape(x,nRightElem,[]),...
            rightCArr(isReshape),'UniformOutput',false);
    end
    nLeftComp=length(leftCArr);
end
%
%use iterative unique operation
leftIndMat=zeros(nLeftElem,nLeftComp);
rightIndMat=zeros(nRightElem,nLeftComp);
for iRow=1:nLeftComp,
    leftMat=leftCArr{iRow};
    rightMat=rightCArr{iRow};
    if isa(rightMat,'function_handle'),
        leftMat=func2str(leftMat);
        rightMat=func2str(rightMat);
    end
    if isnumeric(rightMat)||islogical(rightMat)||ischar(rightMat),
        [rightMat,~,rightIndMat(:,iRow)]=modgen.common.uniquerows(rightMat,false,prop{:});
        [~,leftIndMat(:,iRow)]=modgen.common.ismemberrows(leftMat,rightMat,false,prop{:});
    else
        isCharStr=iscellstr(rightMat);
        if iscell(rightMat)&&~isCharStr,
            isCharStr=all(cellfun('isclass',rightMat(:),'function_handle'));
            if isCharStr,
                leftMat=cellfun(@func2str,leftMat,'UniformOutput',false);
                rightMat=cellfun(@func2str,rightMat,'UniformOutput',false);
            end
        end
        if isCharStr,
            nCols=size(rightMat,2);
            leftIndColMat=nan(nLeftElem,nCols);
            rightIndColMat=nan(nRightElem,nCols);
            for iCol=1:nCols
                [rightVec,~,rightIndColMat(:,iCol)]=unique(rightMat(:,iCol));
                [~,leftIndColMat(:,iCol)]=ismember(leftMat(:,iCol),rightVec);
            end
            if nCols==1
                leftIndMat(:,iRow)=leftIndColMat;
                rightIndMat(:,iRow)=rightIndColMat;
            else
                [rightIndColMat,~,rightIndMat(:,iRow)]=modgen.common.uniquerows(rightIndColMat,true,prop{:});
                [~,leftIndMat(:,iRow)]=modgen.common.ismemberrows(leftIndColMat,rightIndColMat,true,prop{:});
            end
        else
            isLeftOpaque=isa(leftCArr{1},'opaque');
            isRightOpaque=isa(rightCArr{1},'opaque');
            %
            isSortMethodDefined=ismethod(leftCArr{1},'sort')&&...
                ismethod(rightCArr{1},'sort');
            %
            isBothOpaque=isLeftOpaque&&isRightOpaque;
            %
            if isBothOpaque
                if isSortMethodDefined
                    [~,leftIndMat(:,iRow)]=ismembersortableobj(...
                        leftCArr{1},rightCArr{1});
                else
                    [~,leftIndMat(:,iRow)]=...
                        modgen.common.ismemberbyfunc(leftCArr{1},rightCArr{1});
                end
                nRightElems = numel(rightCArr{iRow});
                rightIndMat(:,iRow)=1:nRightElems;
            else
                [leftUniqCell,~,leftIndMat(:,iRow),isLeftSorted]=...
                    uniquejoint(leftCArr(iRow),1);
                [rightUniqCell,~,rightIndMat(:,iRow),...
                    isRightSorted]=uniquejoint(rightCArr(iRow),1);
                leftUniqMat=leftUniqCell{1};
                rightUniqMat=rightUniqCell{1};
                if ~isequaln(leftUniqMat,rightUniqMat),
                    if isLeftSorted&&isRightSorted,
                        nElems=size(leftUniqMat,1);
                        [~,~,curInd]=uniquejoint({vertcat(leftUniqMat,rightUniqMat)},1);
                        [~,curInd]=ismember(curInd(1:nElems),curInd(nElems+1:end),'legacy');
                    else
                        [~,curInd]=modgen.common.ismemberbyfunc(...
                            leftUniqMat,rightUniqMat);
                    end
                    leftIndMat(:,iRow)=curInd(leftIndMat(:,iRow));
                end
            end
        end
    end
end
%
isInd=nargout>1;
if nLeftComp==0,
    isThereVec=true(nLeftElem,1);
    indThereVec=nRightElem*ones(nLeftElem,1);
elseif nLeftComp==1,
    if isInd,
        [isThereVec,indThereVec]=ismember(leftIndMat,rightIndMat,'legacy');
    else
        isThereVec=ismember(leftIndMat,rightIndMat,'legacy');
    end
else
    if isInd,
        [isThereVec,indThereVec]=modgen.common.ismemberrows(leftIndMat,...
            rightIndMat,true,prop{:});
    else
        isThereVec=modgen.common.ismemberrows(leftIndMat,rightIndMat,...
            true,prop{:});
    end
end
%
if isempty(dim),
    isThereVec=reshape(isThereVec,leftSize);
    if nargout>1,
        indThereVec=reshape(indThereVec,leftSize);
    end
elseif dim>1,
    isThereVec=reshape(isThereVec,1,[]);
    if isInd,
        indThereVec=reshape(indThereVec,1,[]);
    end
end
end