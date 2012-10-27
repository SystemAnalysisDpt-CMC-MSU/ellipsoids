function [isMemberVec,indMemberVec]=ismemberjointwithnulls(...
    leftCVec,leftIsNullCVec,rightCVec,rightIsNullCVec,dim)
% ISMEMBERJOINTWITHNULLS perform joint ismember operation for two cell
% arrays for which also cell arrays detemining positions of null values
% are given
%
% Usage: [isMemberVec,indMemberVec]=ismemberjointwithnulls(...
%            leftCVec,leftIsNullCVec,rightCVec,rightIsNullCVec,dim)
%
% input:
%   regular:
%     leftCVec: cell [1,nElems], all cells should contain arrays of
%        arbitrary types with size equal along dimension given by dim -
%        values of elements on the left
%     leftIsNullCVec: cell [1,nElems], i-th cell should contain logical
%        array with number of dimensions nDims_i and of sizes equal with
%        the ones for i-th cell within leftCVec along all dimensions
%        1..max(nDims_i,dim) - logical arrays determining what values are
%        null on the left
%     rightCVec: cell [1,nElems], all cells should contain arrays of
%        arbitrary types with size equal along dimension given by dim -
%        values of elements on the right
%     rightIsNullCVec: cell [1,nElems], i-th cell should contain logical
%        array with number of dimensions nDims_i and of sizes equal with
%        the ones for i-th cell within rightCVec along all dimensions
%        1..max(nDims_i,dim) - logical arrays determining what values are
%        null on the right
%   optional:
%     dim: double [1,1] - main dimension along which ismemberjointwithnulls
%        is performed; if not given, dim is taken equal to 1
% output:
%   regular:
%     isMemberVec: logical [nLeftElem,1] - array of membership indicators
%         of all respective elements within leftCVec (with taking into
%         account of leftIsNullCVec) to all respective elements within
%         rightCVec (with taking into account of rightIsNullCVec),
%         nLeftElem is size of arrays contained within leftCVec (and
%         leftIsNullCVec) arrays for dimention dim
%     indMemberVec: double [nLeftElem,1] - indices indicating location of
%         respective elements within leftCVec (with taking into account of
%         leftIsNullCVec) in rightCVec elements (with taking into account
%         of rightIsNullCVec)
%
% Example: [isMemberVec,indMemberVec]=ismemberjointwithnulls(...
%              {[1;2;1;2],{'a';'b';'c';'a'}},...
%              {[true;true;false;true],[true;true;true;false]},...
%              {[1;2;3],{'a';'b';'c'}},...
%              {[true;true;false],[true;true;true]},1);
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-08-27 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   comparison may be done even if sizes of corresponding elements on left
%   and right sides are not equal along additional dimensions
%

import modgen.common.type.simple.*;
%% initial actions
if nargin<4||nargin>5,
    error([mfilename,':wrongInput'],...
        'Incorrect number of input arguments');
end
checkgen(leftCVec,'iscell(x)');
checkgen(leftIsNullCVec,['iscell(x)&&isequal(size(x),' mat2str(size(leftCVec)) ')']);
checkgen(rightCVec,'iscell(x)');
checkgen(rightIsNullCVec,['iscell(x)&&isequal(size(x),' mat2str(size(rightCVec)) ')']);
nElems=numel(leftCVec);
if nElems==0
    error([mfilename,':wrongInput'],...
        'First four arguments should be non-empty cell arrays');
end
checkgen(rightCVec,['numel(x)==' num2str(nElems)]);
%
if nargin<5,
    dim=1;
else
    checkgen(dim,'isnumeric(x)&&numel(x)==1');
    dim=double(dim);
    checkgen(dim,'isreal(x)&&floor(x)==x&&x>=1&&isfinite(x)');
end
%
leftCVec=leftCVec(:);
leftIsNullCVec=leftIsNullCVec(:);
rightCVec=rightCVec(:);
rightIsNullCVec=rightIsNullCVec(:);
checkgen(leftIsNullCVec,'all(cellfun(''islogical'',x))');
checkgen(rightIsNullCVec,'all(cellfun(''islogical'',x))');
nDimsCVec=cellfun('ndims',leftIsNullCVec);
nMaxDims=max(max(nDimsCVec),dim);
isDecrDims=nDimsCVec==2;
isDecrDims(isDecrDims)=cellfun('size',leftIsNullCVec(isDecrDims),2)==1;
nDimsCVec(isDecrDims)=1;
nDimsCVec=num2cell(max(nDimsCVec,dim));
isPerm=dim>1;
if isPerm,
    permIndVec=[dim 1:dim-1 dim+1:nMaxDims];
end
[nLeftElem,leftSizeCVec,leftIsNullSizeCVec,...
    leftCVec,leftIsNullCVec,isnLeftValueVec]=...
    checkValueAndIsNullConsistency(...
    'left',leftCVec,leftIsNullCVec,nDimsCVec,false(nElems,1));
[nRightElem,rightSizeCVec,rightIsNullSizeCVec,...
    rightCVec,rightIsNullCVec,isnRightValueVec]=...
    checkValueAndIsNullConsistency(...
    'right',rightCVec,rightIsNullCVec,nDimsCVec,isnLeftValueVec);
if isPerm,
    isMemberVec=false(1,nLeftElem);
    indMemberVec=zeros(1,nLeftElem);
else
    isMemberVec=false(nLeftElem,1);
    indMemberVec=zeros(nLeftElem,1);
end
if ~isequal(leftIsNullSizeCVec,rightIsNullSizeCVec),
    error([upper(mfilename),':wrongInput'],...
        'leftIsNullCVec and rightIsNullCVec are not consistent in size');
end
if nLeftElem==0||nRightElem==0,
    return;
end
if all(isnLeftValueVec),
    rightIsNullMat=all(horzcat(rightIsNullCVec{:}),2);
    indLeft2RightNullVec=find(rightIsNullMat,1,'last');
    if ~isempty(indLeft2RightNullVec),
        isMemberVec(:)=true;
        indMemberVec(:)=indLeft2RightNullVec;
    end
    return;
elseif all(isnRightValueVec),
    leftIsNullMat=all(horzcat(leftIsNullCVec{:}),2);
    isMemberVec(:)=leftIsNullMat;
    indMemberVec(leftIsNullMat)=nRightElem;
    return;
end
isnSizeVec=~(isnLeftValueVec|isnRightValueVec);
if any(isnSizeVec),
    isnSizeVec(isnSizeVec)=~cellfun(@isequal,...
        leftSizeCVec(isnSizeVec),rightSizeCVec(isnSizeVec));
    %if any(isnSizeVec),
    %    error([upper(mfilename),':wrongInput'],...
    %        'leftCVec and rightCVec are not consistent in size');
    %end
end
%% perform comparison
leftIndMat=zeros(nLeftElem,nElems);
rightIndMat=zeros(nRightElem,nElems);
for iElem=1:nElems,
    if isnLeftValueVec(iElem),
        isRightNullVec=all(rightIsNullCVec{iElem},2);
        if ~all(isRightNullVec),
            isnLeftValueVec(iElem)=false;
            leftIndMat(:,iElem)=1;
            rightIndMat(isRightNullVec,iElem)=1;
        end
        continue;
    elseif isnSizeVec(iElem),
        isLeftNullVec=all(leftIsNullCVec{iElem},2);
        isRightNullVec=all(rightIsNullCVec{iElem},2);
        if any(isLeftNullVec)&&any(isRightNullVec),
            leftIndMat(:,iElem)=double(isLeftNullVec);
            rightIndMat(:,iElem)=double(~isRightNullVec)+1;
            continue;
        else
            return;
        end
    end
    [leftIsNullMat,~,indLeftNullVec]=modgen.common.uniquerows(leftIsNullCVec{iElem},true);
    [rightIsNullMat,~,indRightNullVec]=modgen.common.uniquerows(rightIsNullCVec{iElem},true);
    [isLeft2RightNullVec,indLeft2RightNullVec]=modgen.common.ismemberrows(leftIsNullMat,rightIsNullMat,true);
    if ~all(isLeft2RightNullVec),
        indLeft2RightNullVec=indLeft2RightNullVec(isLeft2RightNullVec);
        leftIsNullMat=leftIsNullMat(isLeft2RightNullVec,:);
        leftIndVec=cumsum(double(isLeft2RightNullVec),1);
        leftIndVec(~isLeft2RightNullVec)=0;
        indLeftNullVec=leftIndVec(indLeftNullVec);
    end
    nLeftRows=size(leftIsNullMat,1);
    if nLeftRows==0,
        return;
    end
    iInd=0;
    leftMat=leftCVec{iElem};
    rightMat=rightCVec{iElem};
    for iLeftRow=1:nLeftRows,
        isnNullColVec=leftIsNullMat(iLeftRow,:);
        isLeftNullVec=indLeftNullVec==iLeftRow;
        isRightNullVec=indRightNullVec==indLeft2RightNullVec(iLeftRow);
        if all(isnNullColVec),
            iInd=iInd+1;
            rightIndMat(isRightNullVec,iElem)=iInd;
            leftIndMat(isLeftNullVec,iElem)=iInd;
            continue;
        end
        isnNullColVec=~isnNullColVec;
        [uniqueRightMat,~,rightIndVec]=uniquejoint(...
            {rightMat(isRightNullVec,isnNullColVec,:)},1);
        nInds=max(rightIndVec);
        rightIndVec=rightIndVec+iInd;
        rightIndMat(isRightNullVec,iElem)=rightIndVec;
        [isLeft2RightVec,indLeft2RightVec]=ismemberjoint(...
            {leftMat(isLeftNullVec,isnNullColVec,:)},...
            uniqueRightMat,1);
        if any(isLeft2RightVec),
            isLeftNullVec(isLeftNullVec)=isLeft2RightVec;
            leftIndMat(isLeftNullVec,iElem)=...
                indLeft2RightVec(isLeft2RightVec)+iInd;
        end
        iInd=iInd+nInds;
    end
end
if any(isnLeftValueVec),
    leftIndMat(:,isnLeftValueVec)=[];
    rightIndMat(:,isnLeftValueVec)=[];
end
%
if nargout>1,
    [isMemberVec(:),indMemberVec(:)]=modgen.common.ismemberrows(leftIndMat,rightIndMat,true);
else
    isMemberVec(:)=modgen.common.ismemberrows(leftIndMat,rightIndMat,true);
end

    function [nElems,valueSizeCVec,isNullSizeCVec,...
            valueCVec,isNullCVec,isnValueVec]=...
            checkValueAndIsNullConsistency(...
            nameStr,valueCVec,isNullCVec,nDimsCVec,isnValueVec)
        valueSizeCVec=cellfun(@(x,y)[size(x) ones(1,max(y-ndims(x),0))],...
            valueCVec,nDimsCVec,'UniformOutput',false);
        isNullSizeCVec=cellfun(@(x,y)[size(x) ones(1,max(y-ndims(x),0))],...
            isNullCVec,nDimsCVec,'UniformOutput',false);
        if ~all(cellfun(@(x,y,z)isequal(x(1:z),y(1:z)),...
                valueSizeCVec,isNullSizeCVec,nDimsCVec)),
            error([upper(mfilename),':wrongInput'],[...
                nameStr 'CVec is not consitent with ' ...
                nameStr 'IsNullCVec in size']);
        end
        nElems=sort(cellfun(@(x)x(dim),isNullSizeCVec));
        if any(diff(nElems)~=0),
            error([upper(mfilename),':wrongInput'],[...
                'Cells in ' nameStr 'CVec and ' nameStr 'IsNullCVec '...
                'must have the same size along dimension dim=%d'],dim);
        end
        nElems=nElems(1);
        if isPerm,
            isNullCVec=cellfun(@(x)reshape(permute(x,permIndVec),nElems,[]),...
                isNullCVec,'UniformOutput',false);
        else
            isCurVec=cellfun('prodofsize',isNullSizeCVec)>2;
            if any(isCurVec),
                isNullCVec(isCurVec)=cellfun(@(x)reshape(x,nElems,[]),...
                    isNullCVec(isCurVec),'UniformOutput',false);
            end
        end
        isNullSizeCVec=cellfun(@(x)x([1:dim-1 dim+1:numel(x)]),...
            isNullSizeCVec,'UniformOutput',false);
        if all(isnValueVec),
            return;
        end
        isCurVec=~isnValueVec;
        isCurVec(isCurVec)=~cellfun(@(x)all(x(:)),isNullCVec(isCurVec));
        isnValueVec=~isCurVec;
        if all(isnValueVec),
            return;
        end
        nColsVec=num2cell(cellfun('size',isNullCVec(isCurVec),2));
        if isPerm,
            valueCVec(isCurVec)=cellfun(@(x,y)reshape(permute(x,...
                [permIndVec nMaxDims+1:ndims(x)]),nElems,y,[]),...
                valueCVec(isCurVec),nColsVec,'UniformOutput',false);
        else
            valueCVec(isCurVec)=cellfun(@(x,y)reshape(x,nElems,y,[]),...
                valueCVec(isCurVec),nColsVec,'UniformOutput',false);
        end
        valueSizeCVec(isCurVec)=cellfun(@(x)x([1:dim-1 dim+1:numel(x)]),...
            valueSizeCVec(isCurVec),'UniformOutput',false);
    end
end