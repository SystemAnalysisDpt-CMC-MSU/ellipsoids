function [uniqueMat,varargout]=uniquerows(inpMat,isInteger,forceMode)
% UNIQUEROWS finds unique rows in input matrix, i.e. the more effective
% version of UNIQUE(...,'rows')
%
% Usage: [uniqueMat,indRight2LeftVec,indLeft2RightVec]=uniquerows(inpMat)
%
% input:
%   regular:
%     inpMat: double/logical/char [nRows,nCols] - input matrix
%   optional:
%     isInteger: logical [1,1] - if true then no checks that inpMat contain
%         finite integer values are performed
%     forceMode: char [1,] - if given, then determines mode to be used,
%         may be 'standard' (in this case built-in version is forced to
%         be used) or 'optimized' (then optimized version is to be used
%         instead of built-in one in the case it is possible)
% output:
%   regular:
%     uniqueMat: double/logical/char [nUniqueRows,nCols] - output
%         matrix with unique rows
%     indRight2LeftVec: double [nUniqueRows,1] - indices such that
%         uniqueMat coincides with inpMat(indRight2LeftVec,:)
%     indLeft2RightVec: double [nRows,1] - indices such that
%         uniqueMat(indLeft2RightVec,:) coincides with inpMat
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-07-13 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   the situation when nCols==0 is fixed
%

persistent maxVal sqMaxVal logMaxVal;

nOuts=nargout;
isInd=nOuts>1;
if isInd,
    varargout=cell(1,nOuts-1);
else
    varargout=cell(1,0);
end
if nargin<2,
    isInteger=false;
end
%%
[nRows nCols]=size(inpMat);
if nRows==0||nCols==0,
    if nRows>0,
        uniqueMat=inpMat(1,:);
    else
        uniqueMat=inpMat;
    end
    if isInd,
        [varargout{:}]=deal(ones(min(nRows,1),1));
    end
    return;
end
isComplex=false;
if ~isInteger,
    isNum=isnumeric(inpMat);
    if isNum,
        isComplex=~isreal(inpMat);
        if isComplex,
            % transform complex numbers to real ones separating them on real
            % and imaginery parts
            nCols=2*nCols;
            indMat=feval(class(inpMat),zeros(nRows,nCols));
            indMat(:,1:2:nCols)=real(inpMat);
            indMat(:,2:2:nCols)=imag(inpMat);
            inpMat=indMat;
        end
    end
end
if nCols<2,
    % for simple situation use unique
    if ~isInteger,
        % find nans
        isMat=isnan(inpMat);
        isInteger=~any(isMat);
    end
    if isInteger,
        % perform unique
        [uniqueMat,varargout{:}]=unique(inpMat);
    else
        if isInd,
            curInd=find(isMat,1,'last');
        end
        isMat=~isMat;
        [uniqueMat,varargout{:}]=unique(inpMat(isMat));
        % add info for NaNs
        uniqueMat=[uniqueMat;NaN];
        if isInd,
            indRight2LeftVec=find(isMat);
            varargout{1}=[indRight2LeftVec(varargout{1});curInd];
            if nOuts>2,
                indLeft2RightVec=repmat(numel(uniqueMat),nRows,1);
                indLeft2RightVec(isMat)=varargout{2};
                varargout{2}=indLeft2RightVec;
            end
        end
    end
else
    % initial actions
    isForceMode=nargin>=3;
    if isempty(maxVal)||isempty(sqMaxVal)||isempty(logMaxVal),
        maxVal=1/eps('double');
        sqMaxVal=sqrt(maxVal);
        logMaxVal=log2(maxVal);
    end
    isnOptimized=true;
    isIntType=isinteger(inpMat);
    isLogicalType=islogical(inpMat);
    isCharType=ischar(inpMat);
    isInteger=isInteger||isIntType||isLogicalType||isCharType;
    isReshape=~isInteger;
    indMat=inpMat;
    isAllFinite=false;
    if isReshape,
        if ~isNum,
            error([upper(mfilename),':wrongInput'],...
                'Type of inpMat is wrong');
        end
        % reshape matrix into column vector
        indMat=indMat(:);
        isMat=isfinite(indMat);
        isAllFinite=all(isMat);
        if isAllFinite,
            minInpVal=min(indMat);
            maxInpVal=max(indMat);
        else
            % replace non-finite numbers by finite ones
            uniqueMat=indMat(isMat);
            % determine range of finite values
            if isempty(uniqueMat),
                minInpVal=0;
                maxInpVal=0;
            else
                minInpVal=min(uniqueMat);
                maxInpVal=max(uniqueMat);
            end
            isMat=~isMat;
            % replace -Inf
            isCurMat=isMat;
            isCurMat(isMat)=indMat(isMat)==-Inf;
            if any(isCurMat),
                curVal=minInpVal;
                nextVal=curVal-1;
                if nextVal==curVal,
                    nextVal=2*curVal;
                end
                minInpVal=nextVal;
                indMat(isCurMat)=nextVal;
            end
            % replace Inf
            isCurMat(isMat)=indMat(isMat)==Inf;
            if any(isCurMat),
                curVal=maxInpVal;
                nextVal=curVal+1;
                if nextVal==curVal,
                    nextVal=2*curVal;
                end
                maxInpVal=nextVal;
                indMat(isCurMat)=nextVal;
            end
            % replace NaN
            isCurMat(isMat)=isnan(indMat(isMat));
            if any(isCurMat),
                curVal=maxInpVal;
                if curVal==Inf,
                    error([upper(mfilename),':wrongInput'],...
                        'Range of values in inpMat is too large to process it correctly');
                end
                nextVal=curVal+1;
                if nextVal==curVal,
                    nextVal=2*curVal;
                end
                maxInpVal=nextVal;
                indMat(isCurMat)=nextVal;
            end
        end
        rangeVal=maxInpVal-minInpVal+1;
        if rangeVal<=sqMaxVal,
            isInteger=all(fix(indMat)==indMat);
            isnOptimized=~isInteger;
        end
    end
    if isInteger&&isnOptimized,
        % calculate range of values
        if isLogicalType,
            minInpVal=0;
            maxInpVal=1;
        elseif isCharType,
            minInpVal=0;
            maxInpVal=double(intmax('uint16'));
        else
            if ~isReshape,
                isReshape=true;
                indMat=indMat(:);
            end
            minInpVal=double(min(indMat));
            maxInpVal=double(max(indMat));
        end
        % determine whether optimized version may be performed or not
        rangeVal=maxInpVal-minInpVal+1;
        isnOptimized=rangeVal>sqMaxVal;
    end
    if isForceMode,
        isnOptimized=isnOptimized||~strcmpi(forceMode,'optimized');
    elseif ~isnOptimized,
        % determine what version (standard or optimized) is to be used 
        if rangeVal<=pow2(logMaxVal/nCols),
            isOptimized=nRows>=500;
        else
            isOptimized=false;
        end
        isnOptimized=~isOptimized;
    end
    % reshape indMat from column vector into matrix if necessary
    if isReshape&&~(isnOptimized&&isAllFinite),
        indMat=reshape(indMat,nRows,nCols);
    end
    if isnOptimized,
        % perform built-in version of unique
        if isAllFinite,
            [uniqueMat,varargout{:}]=unique(inpMat,'rows');
        else
            [~,indRight2LeftVec,varargout{2:end}]=unique(indMat,'rows');
            uniqueMat=inpMat(indRight2LeftVec,:);
            if isInd,
                varargout{1}=indRight2LeftVec;
            end
        end
        if isComplex,
            uniqueMat=complex(uniqueMat(:,1:2:nCols),uniqueMat(:,2:2:nCols));
        end
        return;
    end
    % calculate codes for rows
    nAllCols=nCols;
    if ~isa(indMat,'double')
        indMat=double(indMat);
    end
    indMat=indMat+(1-minInpVal);
    indMat=indMat(:,nCols:-1:1); % flip columns to obtain desired sorting
    allSizeVec=max(indMat,[],1);
    while nCols>1,
        iCol=0;
        lenVec=[];
        % break all columns on segments
        while iCol<nCols,
            curInd=max(find(cumprod(allSizeVec(iCol+1:end))<=maxVal,1,'last'),2);
            if isempty(curInd),
                curInd=2;
            end
            lenVec=horzcat(lenVec,curInd); %#ok<AGROW>
            iCol=iCol+curInd;
        end
        % perform num2cell(inpMat1,1)
        auxCell=cell(1,nCols);
        for iCol=1:nCols,
            auxCell{iCol}=indMat(:,iCol);
        end
        nCurCols=nCols;
        nCols=numel(lenVec);
        if nCols==1,
            % get column vector with codes
            indMat=sub2ind(allSizeVec,auxCell{:});
        else
            indMat=indMat(:,1:nCols);
            sizeVec=nan(1,nCols);
            % adjust lenVec
            lenVec(end)=lenVec(end)+nCurCols-sum(lenVec);
            % if necessary, process last segment with single column
            if lenVec(end)==1,
                indMat(:,nCols)=auxCell{nCurCols};
                sizeVec(nCols)=allSizeVec(nCurCols);
                nCurCols=nCols-1;
            else
                nCurCols=nCols;
            end
            % get codes for all segments
            leftIndVec=[1 cumsum(lenVec(1:nCurCols-1))+1];
            for iCol=1:nCurCols,
                curInd=leftIndVec(iCol)+(0:lenVec(iCol)-1);
                [uniqueLinInd,~,indMat(:,iCol)]=unique(...
                    sub2ind(allSizeVec(curInd),auxCell{curInd}));
                sizeVec(iCol)=length(uniqueLinInd);
            end
            allSizeVec=sizeVec;
        end
    end
    % perform built-in unique for codes
    if nCols==0,
        indRight2LeftVec=1;
        if nOuts>2,
            varargout{2}=ones(nRows,1);
        end
    else
        [~,indRight2LeftVec,varargout{2:end}]=unique(indMat);
    end
    uniqueMat=inpMat(indRight2LeftVec,:);
    if isComplex,
        uniqueMat=complex(uniqueMat(:,1:2:nAllCols),uniqueMat(:,2:2:nAllCols));
    end
    if isInd,
        varargout{1}=indRight2LeftVec;
    end
end