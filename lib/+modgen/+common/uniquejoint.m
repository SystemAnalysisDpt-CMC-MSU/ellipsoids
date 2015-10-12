function [unqCArr,indRight2LeftVec,indLeft2RightVec,isSorted]=...
    uniquejoint(inpCArr,varargin)
% UNIQUEJOINT perform joint unique operation for cell arrays
%
% Usage: [uniqueCell,indRight2LeftVec,indLeft2RightVec]=uniquejoint(inpCell)
%
% Input:
%   regular:
%       inpCArr: cell [n_1,n_2,...,n_k] - cell array;
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
%
% Output:
%   uniqueCell: cell[n_1,n_2,...,n_k] - cell array of the same size and
%       structure as inpCell but with shrinked items
%
%   indRight2LeftVec: double[nUnique,1] - indices such that
%       uniqueCell=cellfun(@(x)x(indRight2LeftVec),inpCell,...
%           'UniformOutput',false)
%       if dim is not given, otherwise, for example, if dim=1, then
%       uniqueCell=cellfun(@(x)reshape(x(indRight2LeftVec,:),[...
%           numel(indRight2LeftVec) subsref(size(x),...
%           struct('type','()','subs',{{2:ndims(x)}}))]),inpCell,...
%           'UniformOutput',false)
%
%   indLeft2RightVec: double[nInp,1] - indices such that
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
%
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
%
% TODO allow for cells containing 1-dimentional double arrays the same
% size - unique(..,'rows') can be used for this case
%
import modgen.common.throwerror;
import modgen.common.uniquejoint;
import modgen.common.uniquebyfunc;
import modgen.common.uniquesortableobj;
%
if nargin<1,
    throwerror('wrongInput',...
        'incorrect number of input arguments');
end
%
if ~iscell(inpCArr)
    throwerror('wrongInput',...
        'cell array expected as the first argument');
end
%
nInp=numel(inpCArr);
%
if nInp==0
    throwerror('wrongInput',...
        'an input argument should be non-empty cell array');
end
%
[reg,prop]=parseparams(varargin);
nReg=numel(reg);
if nReg<1,
    indDim=[];
else
    indDim=reg{1};
    isnWrong=isnumeric(indDim)&&numel(indDim)==1;
    if isnWrong,
        indDim=double(indDim);
        isnWrong=isreal(indDim)&&floor(indDim)==indDim&&indDim>=1&&...
            isfinite(indDim);
    end
    if ~isnWrong,
        throwerror('wrongInput',...
            'scalar number expected as the second argument');
    end
end
%
if isempty(indDim),
    inpSizeVec=size(inpCArr{1});
    isEqualSize=modgen.common.checksize(inpCArr{:},inpSizeVec);
    if ~isEqualSize
        throwerror('wrongInput',...
            'size of all items of the first cell array should be the same');
    end
    %
    isnColumn=inpSizeVec(1)<=1;
    %turn all cell elements into columns
    if isnColumn
        inpArr=cellfun(@transpose,inpCArr,'UniformOutput',false);
    else
        inpArr=inpCArr;
    end
    %
    nInpElem=numel(inpArr{1});
    lengthInp=max(inpSizeVec);
else
    nInpElem=size(inpCArr{1},indDim);
    %
    %cellfun('size',...,dim) doesn't work properly for cell arrays of
    %enums so we are forced to use a slower variant here: cellfun(@(x)...)
    isEqualSize=all(cellfun(@(x)size(x,indDim),inpCArr(:))==nInpElem);
    %
    if ~isEqualSize
        throwerror('wrongInput',...
            ['size of all items in inpCell along %d-th ',...
            'dimension should be the same'],indDim);
    end
    %
    inpSizeVec=cellfun(@size,inpCArr,'UniformOutput',false);
    nDimsVec=cellfun('length',inpSizeVec(:));
    if indDim>1,
        permVec=[indDim 1:indDim-1 indDim+1:max(nDimsVec)];
        inpArr=cellfun(@(x)reshape(permute(x,permVec),nInpElem,[]),...
            inpCArr,'UniformOutput',false);
    else
        inpArr=inpCArr;
        isReshape=cellfun('length',inpSizeVec)>2;
        if any(isReshape),
            inpArr(isReshape)=cellfun(@(x)reshape(x,nInpElem,[]),...
                inpArr(isReshape),'UniformOutput',false);
        end
    end
    lengthInp=nInpElem;
end
%
if nInpElem==0
    if lengthInp>0,
        unqCArr=cellfun(@(x)x(1,:),inpArr,'UniformOutput',false);
        if isnColumn
            unqCArr=cellfun(@transpose,unqCArr,'UniformOutput',false);
        end
        indRight2LeftVec=1;
        indLeft2RightVec=ones(1,lengthInp);
    else
        unqCArr=inpCArr;
        if isempty(indDim),
            indRight2LeftVec=[];
            indLeft2RightVec=[];
        elseif indDim==1,
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
if isempty(indDim),
    if (nInpElem~=lengthInp)
        throwerror('wrongInput',...
            'all cell items should be either columns or rows ');
    end
else
    inpCArr=inpArr;
end
%
%apply iterative unique operation
indMat=zeros(nInpElem,nInp);
isnSorted=false(1,nInp);
for iRow=1:nInp,
    inpMat=inpArr{iRow};
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
                [~,~,indColMat(:,iCol)]=unique(inpMat(:,iCol),'legacy');
            end
        elseif isNumCell||isStructCell||isCharCell,
            for iCol=1:nCols,
                inpVec=inpMat(:,iCol);
                curIndMat=zeros(nInpElem,2);
                if isStructCell,
                    inpMat=cellfun(@orderfields,inpVec,'UniformOutput',false);
                    curMat=cellfun(@fieldnames,inpVec,'UniformOutput',false);
                    [sizeVars,~,curIndMat(:,1)]=unique(cellfun('prodofsize',curMat),...
                        'legacy');
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
        elseif isa(inpMat,'opaque')&&ismethod(inpMat,'sort')
            for iCol=1:nCols,
                [~,~,indColMat(:,iCol)]=uniquesortableobj(inpMat(:,iCol));
            end
        else
            isnSorted(iRow)=true;
            for iCol=1:nCols,
                [~,~,indColMat(:,iCol)]=uniquebyfunc(inpMat(:,iCol));
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
if isempty(indDim),
    %index inpCell, not inpArray since an initial size should be preserved
    unqCArr=cellfun(@(x)(x(indRight2LeftVec)),inpCArr,'UniformOutput',false);
else
    if all(nDimsVec>=indDim),
        nOutElem=length(indRight2LeftVec);
        inpSizeVec=cellfun(@(x)[nOutElem x([1:indDim-1 indDim+1:end])],inpSizeVec,...
            'UniformOutput',false);
    end
    if indDim>1,
        unqCArr=cellfun(...
            @(x,y)ipermute(reshape(x(indRight2LeftVec,:),y),permVec),...
            inpCArr,inpSizeVec,'UniformOutput',false);
    else
        unqCArr=cellfun(...
            @(x,y)reshape(x(indRight2LeftVec,:),y),...
            inpCArr,inpSizeVec,'UniformOutput',false);
    end
end