function [isMember,indMember]=ismemberjoint(leftCell,rightCell,varargin)
% ISMEMBERJOINT perform joint ismember operation for two cell arrays
%
% Usage: [isMember,indMember]=ismemberjoint(leftCell,rightCell)
%
% Input:
%   regular:
%       leftCell: cell array; in the case dim is not given (see below for
%          details) it is assumed that all cells must contain either
%          columns or rows of some type and of the same size (either
%          [1,nLeft] or [nLeft,1]); if dim is given then size of all items
%          in inpCell should be the same (and equal to nLeft) only along
%          dimension equal to dim
%       rightCell: cell of the same structure and size as leftCell which
%          means that types and orientation (rows or columns, if dim is not
%          given) and size along other dimensions that dim (if the latter
%          is given) of respective cells in leftCell and rightCell should
%          be the same.
%
%         Note: empty elements present in both leftCell and rightCell on
%            THE SAME PLACES are ignored
%
%   optional:
%       dim: double [1,1] - main dimension along which ismemberjoint is
%           performed
%
%           Please note that for entries of numeric type types or cell
%           array of strings ismember function is used while for other
%           types (cell arrays of numeric arrays for instance
%           ismemberobjinternal function is called)
%       checkSizeIfEmpty: logical [1,1] - if true, then consistency of
%           sizes  of the corresponding cells in leftCell and rightCell is
%           performed even in the case one of them is empty along dimension
%           given by dim, if false, this check is omitted; by default it is
%           true
%  
%       For other optional arguments and properties see descriptions of
%       modgen.common.ismemberrows and modgen.common.uniquerows functions
%       for their arguments immediately following after isInteger input
%       argument
% Output:
%
%   isMember: logical [nLeftElem,1] ([1,nLeft]) array of membership indicators
%       of all respective elements within leftCell to all respective
%       elements within rightCell, nLeftElem is size of arrays contained 
%       within leftCell arrays for dimention dim
%   indMember: double [nLeftElem,1] ([1,nLeft])- indices indicating location of
%       respective elements within leftCell in rightCell elements
%
% Example:
% [isMember,indMember]=ismemberjoint({[1 2],{'a','b'};[3...
%   4],{'c','d'}},{[1 2 3],{'a','b','c'};[3 4 5],{'c','d','m'}})
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-10-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-19 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   skipping calculation of the second output if it is not necessary
%   processing of NaNs and empty arrays is fixed
%   added dim argument, added support for multidimensional arrays in cells
%   of leftCell and rightCell so that ismember is performed for slices
%   along dimension given by dim
%   relaxed the requirements for input cell arrays by allowing for empty
%   elements on the same places in leftCell and rightCell
%   partition on columns is removed, uniquerows and ismemberrows are used
%

%
if nargin<2,
    error([mfilename,':wrongInput'],...
        'incorrect number of input arguments');
end
%
if ~iscell(leftCell)||~iscell(rightCell)
    error([mfilename,':wrongInput'],...
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
        error([mfilename,':wrongInput'],...
            'scalar number expected as the third argument');
    end
end
%
leftCell=leftCell(:);
rightCell=rightCell(:);
%
nLeft=length(leftCell);
%
if nLeft~=length(rightCell)
    error([mfilename,':wrongInput'],...
        'both arguments should have the same size');
end
%
if nLeft==0
    error([mfilename,':wrongInput'],...
        'both arguments should be non-empty cells');
end
%
%
leftTypeCell=cellfun(@class,leftCell,'UniformOutput',false);
rightTypeCell=cellfun(@class,rightCell,'UniformOutput',false);
isEqualType=cellfun(@(x,y)isequal(x,y),leftTypeCell,rightTypeCell);
if ~all(isEqualType)
    error([mfilename,':wrongInput'],...
        'types of corresponding input cell content should be the same');
end
%
if isempty(dim),
    isEmptyVec=cellfun('isempty',leftCell)&cellfun('isempty',rightCell);
    leftCell(isEmptyVec)=[];
    rightCell(isEmptyVec)=[];
    nLeftComp=length(leftCell);
    if nLeftComp==0
        isMember=false(0,1);
        indMember=zeros(0,1);
        return;
    end
    leftSize=size(leftCell{1});
    isEqualLeftSize=auxchecksize(leftCell{:},leftSize);
    if ~isEqualLeftSize
        error([mfilename,':wrongInput'],...
            'size of all items of the first cell array should be the same');
    end
    %
    rightSize=size(rightCell{1});
    isEqualRightSize=auxchecksize(rightCell{:},rightSize);
    if ~isEqualRightSize
        error([mfilename,':wrongInput'],...
            'size of all items of the second cell array should be the same');
    end
    %
    nLeftElem=numel(leftCell{1});
    lengthLeft=length(leftCell{1});
    %
    nRightElem=numel(rightCell{1});
    lengthRight=length(rightCell{1});
    %
    if (nLeftElem~=lengthLeft)||(nRightElem~=lengthRight)
        error([mfilename,':wrongInput'],...
            'all cell items should be either columns or rows ');
    end
    %
    if nLeftElem==0
        isMember=false(leftSize);
        indMember=nan(leftSize);
        return;
    end
    leftCell=cellfun(@(x)x(:),leftCell,'UniformOutput',false);
    rightCell=cellfun(@(x)x(:),rightCell,'UniformOutput',false);
else
    if nReg<2,
        checkSizeIfEmpty=true;
    else
        checkSizeIfEmpty=reg{2};
    end
    %
    nLeftElem=size(leftCell{1},dim);
    %
    %cellfun('size',...,dim) doesn't work properly for cell arrays of
    %enums so we are forced to use a slower variant here: cellfun(@(x)...)
    isEqualLeftSize=all(cellfun(@(x)size(x,dim),leftCell(:))==nLeftElem);
    if ~isEqualLeftSize
        error([mfilename,':wrongInput'],...
            ['size of all items in leftCell along %d-th ',...
            'dimension should be the same'],dim);
    end
    %
    nRightElem=size(rightCell{1},dim);
    %
    %cellfun('size',...,dim) doesn't work properly for cell arrays of
    %enums so we are forced to use a slower variant here: cellfun(@(x)...)
    isEqualRightSize=all(cellfun(@(x)size(x,dim),rightCell)==nRightElem);
    if ~isEqualRightSize
        error([mfilename,':wrongInput'],...
            ['size of all items in rightCell along %d-th ',...
            'dimension should be the same'],dim);
    end
    %
    if checkSizeIfEmpty||(nLeftElem>0&&nRightElem>0),
        if dim>1,
            permVec=[dim 1:dim-1 dim+1:max(vertcat(...
                cellfun('ndims',leftCell(:)),cellfun('ndims',rightCell(:))))];
            leftCell=cellfun(@(x)permute(x,permVec),leftCell,'UniformOutput',false);
            rightCell=cellfun(@(x)permute(x,permVec),rightCell,'UniformOutput',false);
        end
        leftSize=cellfun(@size,leftCell,'UniformOutput',false);
        rightSize=cellfun(@size,rightCell,'UniformOutput',false);
        %
        if ~isequal(cellfun(@(x)x(2:end),leftSize,'UniformOutput',false),...
                cellfun(@(x)x(2:end),rightSize,'UniformOutput',false)),
            error([mfilename,':wrongInput'],[...
                'sizes of all items in leftCell and rightCell '...
                'along all dimensions save %d-th one should be the same'],dim);
        end
    end
    %
    if nLeftElem==0,
        if dim>1,
            isMember=false(1,0);
            indMember=nan(1,0);
        else
            isMember=false(0,1);
            indMember=nan(0,1);
        end
        return;
    end
    %
    if nRightElem==0,
        if dim>1
            isMember=false(1,nLeftElem);
            indMember=zeros(1,nLeftElem);
        else
            isMember=false(nLeftElem,1);
            indMember=zeros(nLeftElem,1);
        end
        return;
    end
    %
    isReshape=max(cellfun('length',leftSize),cellfun('length',rightSize))>2;
    if any(isReshape),
        leftCell(isReshape)=cellfun(@(x)reshape(x,nLeftElem,[]),...
            leftCell(isReshape),'UniformOutput',false);
        rightCell(isReshape)=cellfun(@(x)reshape(x,nRightElem,[]),...
            rightCell(isReshape),'UniformOutput',false);
    end
    nLeftComp=length(leftCell);
end
%
%use iterative unique operation
leftIndMat=zeros(nLeftElem,nLeftComp);
rightIndMat=zeros(nRightElem,nLeftComp);
for iRow=1:nLeftComp,
    leftMat=leftCell{iRow};
    rightMat=rightCell{iRow};
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
            for iCol=1:nCols,
                [rightVec,~,rightIndColMat(:,iCol)]=unique(rightMat(:,iCol));
                [~,leftIndColMat(:,iCol)]=ismember(leftMat(:,iCol),rightVec);
            end
            if nCols==1,
                leftIndMat(:,iRow)=leftIndColMat;
                rightIndMat(:,iRow)=rightIndColMat;
            else
                [rightIndColMat,~,rightIndMat(:,iRow)]=modgen.common.uniquerows(rightIndColMat,true,prop{:});
                [~,leftIndMat(:,iRow)]=modgen.common.ismemberrows(leftIndColMat,rightIndColMat,true,prop{:});
            end
        else
            [leftMat,~,leftIndMat(:,iRow),isLeftSorted]=uniquejoint(leftCell(iRow),1);
            [rightMat,~,rightIndMat(:,iRow),isRightSorted]=uniquejoint(rightCell(iRow),1);
            leftMat=leftMat{:};
            rightMat=rightMat{:};
            if ~isequalwithequalnans(leftMat,rightMat),
                if isLeftSorted&&isRightSorted,
                    nElems=size(leftMat,1);
                    [~,~,curInd]=uniquejoint({vertcat(leftMat,rightMat)},1);
                    [~,curInd]=ismember(curInd(1:nElems),curInd(nElems+1:end));
                else
                    if ismethod(rightMat,'isequal'),
                        inputCell={@isequal};
                    else
                        inputCell={};
                    end
                    [~,curInd]=ismemberobjinternal(leftMat,rightMat,inputCell{:});
                end
                leftIndMat(:,iRow)=curInd(leftIndMat(:,iRow));
            end
        end
    end
end
%
isInd=nargout>1;
if nLeftComp==0,
    isMember=true(nLeftElem,1);
    indMember=nRightElem*ones(nLeftElem,1);
elseif nLeftComp==1,
    if isInd,
        [isMember,indMember]=ismember(leftIndMat,rightIndMat);
    else
        isMember=ismember(leftIndMat,rightIndMat);
    end
else
    if isInd,
        [isMember,indMember]=modgen.common.ismemberrows(leftIndMat,rightIndMat,true,prop{:});
    else
        isMember=modgen.common.ismemberrows(leftIndMat,rightIndMat,true,prop{:});
    end
end
if isempty(dim),
    %member indices should be of the same size as leftCell
    isMember=reshape(isMember,leftSize);
    if nargout>1,
        indMember=reshape(indMember,leftSize);
    end
elseif dim>1,
    isMember=reshape(isMember,1,[]);
    if isInd,
        indMember=reshape(indMember,1,[]);
    end
end