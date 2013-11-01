function [uniqueCell,indRight2LeftVec,indLeft2RightVec,isSorted]=uniquejoint(inpCell,varargin)
% UNIQUEJOINT perform joint unique operation for cell array
% 
% Usage: [uniqueCell,indRight2LeftVec,indLeft2RightVec]=uniquejoint(inpCell)
% 
% Input:
%   regular:
%       inpCell: cell [n_1,n_2,...,n_k] - cell array;
%          in the case dim is not given (see below for details) it is
%          assumed that size of all items in inpCell should be the same
%          (either [1,nInp] or [nInp,1]); if dim is given then size of all
%          items in inpCell should be the same only along dimension equal
%          to dim
%   optional:
%       dim: double [1,1] - main dimension along which uniquejoint is
%           performed
%           
%       For other optional arguments and properties see description of
%       modgen.common.uniquerows function for its arguments immediately
%       following after isInteger input argument

%       Please note that for entries of numeric type types or cell array of
%       strings unique function is used while for other types (cell arrays
%       of numeric arrays for instance uniqueobjinternal function is
%       called)
%
% Output:
%   uniqueCell: cell [n_1,n_2,...,n_k] - cell array of the same size and
%       structure as inpCell but with shrinked items
%
%   indRight2LeftVec: empty or double [1,nUnique] - indices such that
%       uniqueCell=cellfun(@(x)x(indRight2LeftVec),inpCell,...
%           'UniformOutput',false)
%       if dim is not given, otherwise, for example, if dim=1, then
%       uniqueCell=cellfun(@(x)reshape(x(indRight2LeftVec,:),[...
%           numel(indRight2LeftVec) subsref(size(x),...
%           struct('type','()','subs',{{2:ndims(x)}}))]),inpCell,...
%           'UniformOutput',false)
%
%   indLeft2RightVec: empty or double [1,nInp] - indices such that
%       inpCell=cellfun(@(x)x(indLeft2Right),uniqueCell,...
%           'UniformOutput',false)       
%       if dim is not given, otherwise, for example, if dim=1, then
%       inpCell=cellfun(@(x)reshape(x(indLeft2RightVec,:),[...
%           numel(indLeft2RightVec) subsref(size(x),...
%           struct('type','()','subs',{{2:ndims(x)}}))]),uniqueCell,...
%           'UniformOutput',false)
%
%   isSorted: logical [1,1] - determines whether values in uniqueCell are
%       sorted or not; this function tries always to sort all values
%       in ascending order if it is possible jointly for all cells; if this
%       is possible then isSorted is true, otherwise isSorted is false and
%       hence there are some cells whose values are not sortable
%   
% Examples:
%     [uniqueCell,indRight2LeftVec,indLeft2RightVec]=...
%         uniquejoint({[1 2 1]; {'a','b','a'}})
%     [uniqueCell,indRight2LeftVec,indLeft2RightVec]=...
%         uniquejoint({[1 2;2 3;1 2],cat(3,{'a','c';'b','d';'a';'c'}...
%         {'e','f';'f','g';'e','f'}))
%
%
% $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2012-10-09 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   added a possibility to handle the arbitraty types that support isequal
%   function
%   processing of NaNs and empty arrays is fixed
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-02-03 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   added support for empty arrays (like zeros(10,0))
%   added dim argument, added support for multidimensional arrays in cells
%   of inpCell so that unique slices are determined along dimension given
%   by dim
%   Bug was fixed for the case when dim is not passed
%   partition on columns is removed, uniquerows is used

% TODO allow for cells containing 1-dimentional double arrays the same
% size - unique(..,'rows') can be used for this case

%
if nargin<1,
    error([mfilename,':incorrectInput'],...
        'incorrect number of input arguments');
end
%
if ~iscell(inpCell)
    error([mfilename,':incorrectInput'],...
        'cell array expected as the first argument');
end
%
nInp=numel(inpCell);
%
if nInp==0
    error([mfilename,':incorrectInput'],...
        'an input argument should be non-empty cell array');
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
        error([mfilename,':incorrectInput'],...
            'scalar number expected as the second argument');
    end
end
%
if isempty(dim),
    inpSize=size(inpCell{1});
    isEqualSize=auxchecksize(inpCell{:},inpSize);
    if ~isEqualSize
        error([mfilename,':incorrectInput'],...
            'size of all items of the first cell array should be the same');
    end
    %
    isnColumn=inpSize(1)<=1;
    %turn all cell elements into columns
    if isnColumn
        inpArray=cellfun(@transpose,inpCell,'UniformOutput',false);
    else
        inpArray=inpCell;
    end
    %
    nInpElem=numel(inpArray{1});
    lengthInp=max(inpSize);
else
    nInpElem=size(inpCell{1},dim);
    %
    %cellfun('size',...,dim) doesn't work properly for cell arrays of 
    %enums so we are forced to use a slower variant here: cellfun(@(x)...)
    isEqualSize=all(cellfun(@(x)size(x,dim),inpCell(:))==nInpElem);
    %
    if ~isEqualSize
        error([mfilename,':incorrectInput'],...
            ['size of all items in inpCell along %d-th ',...
            'dimension should be the same'],dim);
    end
    %
    inpSize=cellfun(@size,inpCell,'UniformOutput',false);
    nDimsVec=cellfun('length',inpSize(:));
    if dim>1,
        permVec=[dim 1:dim-1 dim+1:max(nDimsVec)];
        inpArray=cellfun(@(x)reshape(permute(x,permVec),nInpElem,[]),...
            inpCell,'UniformOutput',false);
    else
        inpArray=inpCell;
        isReshape=cellfun('length',inpSize)>2;
        if any(isReshape),
            inpArray(isReshape)=cellfun(@(x)reshape(x,nInpElem,[]),...
                inpArray(isReshape),'UniformOutput',false);
        end
    end
    lengthInp=nInpElem;
end
%
if nInpElem==0
    if lengthInp>0,
        uniqueCell=cellfun(@(x)x(1,:),inpArray,'UniformOutput',false);
        if isnColumn
            uniqueCell=cellfun(@transpose,uniqueCell,'UniformOutput',false);
        end
        indRight2LeftVec=1;
        indLeft2RightVec=ones(1,lengthInp);
    else
        uniqueCell=inpCell;
        if isempty(dim),
            indRight2LeftVec=[];
            indLeft2RightVec=[];
        elseif dim==1,
            indRight2LeftVec=nan(0,1);
            indLeft2RightVec=nan(0,1);
        else
            indRight2LeftVec=nan(1,0);
            indLeft2RightVec=nan(1,0);
        end
    end
    return;
end
%
if isempty(dim),
    if (nInpElem~=lengthInp)
        error([mfilename,':incorrectInput'],'all cell items should be either columns or rows ');
    end
else
    inpCell=inpArray;
end
%
%apply iterative unique operation
indMat=zeros(nInpElem,nInp);
isnSorted=false(1,nInp);
for iRow=1:nInp,
    inpMat=inpArray{iRow};
    if isa(inpMat,'function_handle'),
        inpMat=func2str(inpMat);
    end
    if isnumeric(inpMat)||islogical(inpMat)||ischar(inpMat),
        [~,~,indMat(:,iRow)]=modgen.common.uniquerows(inpMat,false,prop{:});
    elseif isstruct(inpMat),
        curMat=reshape(modgen.common.num2cell(...
            permute(struct2cell(inpMat),[2 3 1]),[1 2]),1,[]);
        [~,~,indMat(:,iRow)]=uniquejoint(curMat,1);
    else
        nCols=size(inpMat,2);
        isCharStr=iscellstr(inpMat);
        isNumCell=iscell(inpMat)&&~isCharStr;
        isStructCell=false;
        isCharCell=false;
        isIntCell=false;
        if isNumCell,
            inpMat=inpMat(:);
            isIntCell=all(cellfun(@(x)isinteger(x)||islogical(x),inpMat));
            if ~isIntCell,
                isNumCell=all(cellfun(@isnumeric,inpMat));
            end
            if ~isNumCell,
                isStructCell=all(cellfun('isclass',inpMat,'struct'));
                if ~isStructCell,
                    isCharStr=all(cellfun('isclass',inpMat,'function_handle'));
                    if isCharStr,
                        inpMat=cellfun(@func2str,inpMat,'UniformOutput',false);
                    else
                        isCharCell=all(cellfun(@iscellstr,inpMat));
                    end
                end
            end
            inpMat=reshape(inpMat,[],nCols);
        end
        indColMat=nan(nInpElem,nCols);
        if isCharStr,
            for iCol=1:nCols,
                [~,~,indColMat(:,iCol)]=unique(inpMat(:,iCol));
            end
        elseif isNumCell||isStructCell||isCharCell,
            for iCol=1:nCols,
                inpVec=inpMat(:,iCol);
                curIndMat=zeros(nInpElem,2);
                if isStructCell,
                    inpMat=cellfun(@orderfields,inpVec,'UniformOutput',false);
                    curMat=cellfun(@fieldnames,inpVec,'UniformOutput',false);
                    [sizeVars,~,curIndMat(:,1)]=unique(cellfun('prodofsize',curMat));
                    nVars=size(sizeVars,1);
                    for iVar=1:nVars,
                        isVar=curIndMat(:,1)==iVar;
                        [~,~,curIndMat(isVar,2)]=uniquejoint({horzcat(curMat{isVar}).'},1);
                    end
                    [~,~,curMat]=modgen.common.uniquerows(curIndMat,true,prop{:});
                    transformFunc=@(x)reshape(struct2cell(reshape(x,1,numel(x))),1,[]);
                elseif isCharCell,
                    curMat=[];
                    transformFunc=@(x)reshape(x,1,[]);
                else
                    curMat=[];
                    transformFunc=@(x)reshape(double(x),1,[]);
                end
                [sizeVars,~,curIndMat(:,1)]=modgen.common.uniquerows(...
                    [cellfun('ndims',inpVec),...
                    cellfun('prodofsize',inpVec),curMat],true,prop{:});
                nVars=size(sizeVars,1);
                nDims=1;
                for iVar=1:nVars,
                    isVar=curIndMat(:,1)==iVar;
                    curMat=[cellfun(@size,inpVec(isVar),'UniformOutput',false),...
                        cellfun(transformFunc,inpVec(isVar),'UniformOutput',false)];
                    nElems=size(curMat,1);
                    curMat=horzcat(curMat{:});
                    if isNumCell,
                        nDims=sizeVars(iVar,1);
                    end
                    curMat=[...
                        transpose(reshape(curMat(1:nDims*nElems),[],nElems)),...
                        transpose(reshape(curMat(nDims*nElems+1:end),[],nElems))];
                    if isNumCell,
                        [~,~,curIndMat(isVar,2)]=modgen.common.uniquerows(curMat,isIntCell,prop{:});
                    else
                        curMat=[{vertcat(curMat{:,1})},modgen.common.num2cell(curMat(:,2:end),1)];
                        [~,~,curIndMat(isVar,2)]=uniquejoint(curMat,1);
                    end
                end
                if nVars>1,
                    [~,~,indColMat(:,iCol)]=modgen.common.uniquerows(curIndMat,true,prop{:});
                else
                    indColMat(:,iCol)=curIndMat(:,2);
                end
            end
        else
            isnSorted(iRow)=true;
            for iCol=1:nCols,
                [~,~,indColMat(:,iCol)]=uniqueobjinternal(inpMat(:,iCol));
            end
        end
        if nCols==1,
            indMat(:,iRow)=indColMat;
        else
            [~,~,indMat(:,iRow)]=modgen.common.uniquerows(indColMat,true,prop{:});
        end
    end
end
isSorted=~any(isnSorted);
if ~isSorted,
    indMat=[indMat(:,~isnSorted) indMat(:,isnSorted)];
end
%
isBackwardInd=nargout>2;
if nInp==0,
    indRight2LeftVec=1;
    if isBackwardInd,
        indLeft2RightVec=ones(nInpElem,1);
    end
elseif nInp==1,
    if isBackwardInd,
        [~,indRight2LeftVec,indLeft2RightVec]=unique(indMat);
    else
        [~,indRight2LeftVec]=unique(indMat);
    end
else
    if isBackwardInd,
        [~,indRight2LeftVec,indLeft2RightVec]=modgen.common.uniquerows(indMat,true,prop{:});
    else
        [~,indRight2LeftVec]=modgen.common.uniquerows(indMat,true,prop{:});
    end
end
%
if isempty(dim)||dim>1,
    %indices should be rows
    indRight2LeftVec=reshape(indRight2LeftVec,1,[]);
    if isBackwardInd,
        indLeft2RightVec=reshape(indLeft2RightVec,1,[]);
    end
end    
if isempty(dim),
    %index inpCell, not inpArray since an initial size should be preserved
    uniqueCell=cellfun(@(x)(x(indRight2LeftVec)),inpCell,'UniformOutput',false);
else
    if all(nDimsVec>=dim),
        nOutElem=length(indRight2LeftVec);
        inpSize=cellfun(@(x)[nOutElem x([1:dim-1 dim+1:end])],inpSize,...
            'UniformOutput',false);
    end
    if dim>1,
        uniqueCell=cellfun(...
            @(x,y)ipermute(reshape(x(indRight2LeftVec,:),y),permVec),...
            inpCell,inpSize,'UniformOutput',false);
    else
        uniqueCell=cellfun(...
            @(x,y)reshape(x(indRight2LeftVec,:),y),...
            inpCell,inpSize,'UniformOutput',false);
    end
end