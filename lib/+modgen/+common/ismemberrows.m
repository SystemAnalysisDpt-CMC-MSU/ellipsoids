function [isMemberVec,indMemberVec]=ismemberrows(inpMat1,inpMat2,isInteger,forceMode)
% ISMEMBERROWS finds indices of rows first matrix in the second matrix,
% i.e. it is the more effective version of ISMEMBER(...,'rows')

%
% Usage: [isMemberVec,indMemberVec]=ismemberrows(inpMat1,inpMat2)
%
% input:
%   regular:
%     inpMat1: double/logical/char [nRows1,nCols] - first matrix
%     inpMat2: double/logical/char [nRows2,nCols] - second matrix
%   optional:
%     isInteger: logical [1,1] - if true then no checks that inpMat1 and
%         inpMat2 contain finite integer values are performed
%     forceMode: char [1,] - if given, then determines mode to be used,
%         may be 'standard' (in this case built-in version is forced to
%         be used) or 'optimized' (then optimized version is to be used
%         instead of built-in one in the case it is possible)
% output:
%   regular:
%     isMemberVec: logical [nRows1,1] - whether corresponding row from
%         inpMat1 equals to some row in matrix inpMat2
%     indMemberVec: double [nRows1,1] - indices of corresponding rows
%         from inpMat1 in matrix inpMat2 (0 if there is no equal row in b)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-19 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%   the situation when nCols==0 is fixed
%

persistent maxVal sqMaxVal logMaxVal;

if nargin<3,
    isInteger=false;
end
[nRows1 nCols]=size(inpMat1);
if size(inpMat2,2)~=nCols,
    error([upper(mfilename),':wrongInput'],...
        'Number of columns in inpMat1 and inpMat2 must be the same');
end
nRows2=size(inpMat2,1);
isInd=nargout>1;
if nRows1==0||nRows2==0||nCols==0,
    if nCols==0,
        isMemberVec=true(nRows1,1);
        indMemberVec=repmat(nRows2,nRows1,1);
    else
        isMemberVec=false(nRows1,1);
        indMemberVec=zeros(nRows1,1);
    end
    return;
end
if ~isInteger,
    isNum=isnumeric(inpMat1)&&isnumeric(inpMat2);
    if isNum,
        if ~(isreal(inpMat1)&&isreal(inpMat2)),
            % transform complex numbers to real ones separating them on real
            % and imaginery parts
            nCols=2*nCols;
            inpMat1=[real(inpMat1) imag(inpMat1)];
            inpMat2=[real(inpMat2) imag(inpMat2)];
        end
    end
end
if nCols<2,
    % for simple situation use ismember
    if ~isInteger,
        % find nans
        isMat1=isnan(inpMat1);
        isMat2=isnan(inpMat2);
        isNan1=any(isMat1);
        isNan2=any(isMat2);
        isInteger=~(isNan1||isNan2);
    end
    if isInteger,
        % perform ismember
        if isInd,
            [isMemberVec,indMemberVec]=ismember(inpMat1,inpMat2);
        else
            isMemberVec=ismember(inpMat1,inpMat2);
        end
    else
        isMemberVec=false(nRows1,1);
        indMemberVec=zeros(nRows1,1);
        % perform ismember for NaNs
        if isNan1,
            if isNan2,
                isMemberVec(isMat1)=true;
                indMemberVec(isMat1)=find(isMat2,1,'last');
            end
        end
        if isNan1||isNan2,
            isMat1=~isMat1;
            isMat2=~isMat2;
        end
        % peform ismember for non-NaNs
        if isInd,
            [isCurMemberVec,indCurMemberVec]=ismember(inpMat1(isMat1),inpMat2(isMat2));
            if isNan2&&any(isCurMemberVec),
                inpMat2=find(isMat2);
                indCurMemberVec(isCurMemberVec)=inpMat2(indCurMemberVec(isCurMemberVec));
            end
            isMemberVec(isMat1)=isCurMemberVec;
            indMemberVec(isMat1)=indCurMemberVec;
        else
            isMemberVec(isMat1)=ismember(inpMat1(isMat1),inpMat2(isMat2));
        end
    end
else
    % initial actions
    isForceMode=nargin>=4;
    if ~strcmp(class(inpMat1),class(inpMat2)),
        error([upper(mfilename),':wrongInput'],...
            'Classes of inpMat1 and inpMat2 differ');
    end
    if isempty(maxVal)||isempty(sqMaxVal)||isempty(logMaxVal),
        maxVal=1/eps('double');
        sqMaxVal=sqrt(maxVal);
        logMaxVal=log2(maxVal);
    end
    isnOptimized=true;
    isIntType=isinteger(inpMat1);
    isLogicalType=islogical(inpMat1);
    isCharType=ischar(inpMat1);
    isInteger=isInteger||isIntType||isLogicalType||isCharType;
    isReshape=~isInteger;
    if isReshape,
        if ~isNum,
            error([upper(mfilename),':wrongInput'],...
                'Type of inpMat1 and inpMat2 is wrong');
        end
        % reshape matrices into column vectors
        inpMat1=inpMat1(:);
        inpMat2=inpMat2(:);
        isMat1=isfinite(inpMat1);
        isMat2=isfinite(inpMat2);
        if (all(isMat1)&&all(isMat2)),
            minInpVal=min(min(inpMat1),min(inpMat2));
            maxInpVal=max(max(inpMat1),max(inpMat2));
        else
            % replace non-finite numbers by finite ones
            inpMat=[inpMat1(isMat1);inpMat2(isMat2)];
            % determine range of finite values
            if isempty(inpMat),
                minInpVal=0;
                maxInpVal=0;
            else
                minInpVal=min(inpMat);
                maxInpVal=max(inpMat);
            end
            isMat1=~isMat1;
            isMat2=~isMat2;
            inpMat=[inpMat1(isMat1);inpMat2(isMat2)];
            % replace -Inf
            isMat=inpMat==-Inf;
            if any(isMat),
                curVal=minInpVal;
                nextVal=curVal-1;
                if nextVal==curVal,
                    nextVal=2*curVal;
                end
                minInpVal=nextVal;
                inpMat(isMat)=nextVal;
            end
            % replace Inf
            isMat=inpMat==Inf;
            if any(isMat),
                curVal=maxInpVal;
                nextVal=curVal+1;
                if nextVal==curVal,
                    nextVal=2*curVal;
                end
                maxInpVal=nextVal;
                inpMat(isMat)=nextVal;
            end
            % replace NaN
            isMat=isnan(inpMat);
            if any(isMat),
                curVal=maxInpVal;
                if curVal==Inf,
                    error([upper(mfilename),':wrongInput'],...
                        'Range of values in inpMat1 and inpMat2 is too large to process it correctly');
                end
                nextVal=curVal+1;
                if nextVal==curVal,
                    nextVal=2*curVal;
                end
                maxInpVal=nextVal;
                inpMat(isMat)=nextVal;
            end
            % update non-finite values
            curVal=sum(isMat1);
            inpMat1(isMat1)=inpMat(1:curVal);
            inpMat2(isMat2)=inpMat(curVal+1:end);
        end
        rangeVal=maxInpVal-minInpVal+1;
        if rangeVal<=sqMaxVal,
            isInteger=all(fix(inpMat1)==inpMat1)&&all(fix(inpMat2)==inpMat2);
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
                inpMat1=inpMat1(:);
                inpMat2=inpMat2(:);
            end
            minInpVal=double(min(min(inpMat1),min(inpMat2)));
            maxInpVal=double(max(max(inpMat1),max(inpMat2)));
        end
        % determine whether optimized version may be performed or not
        rangeVal=maxInpVal-minInpVal+1;
        isnOptimized=rangeVal>sqMaxVal;
    end
    % reshape inpMat1 and inpMat2 from column vectors into matrices if
    % necessary
    if isReshape,
        inpMat1=reshape(inpMat1,nRows1,nCols);
        inpMat2=reshape(inpMat2,nRows2,nCols);
    end
    if isForceMode,
        isnOptimized=isnOptimized||~strcmpi(forceMode,'optimized');
    elseif ~isnOptimized,
        % determine what version (standard or optimized) is to be used
        nRows=nRows1+nRows2;
        if rangeVal<=pow2(logMaxVal/nCols),
            isOptimized=nRows>=3;
        elseif nCols>=250&&nRows>=100,
            isOptimized=rangeVal<=pow2(nRows^3.62,-24);
        else
            isOptimized=rangeVal<=pow2(nRows^3.62,-34);
        end
        isnOptimized=~isOptimized;
    end
    if isnOptimized,
        % perform built-in version of ismember
        if isInd,
            [isMemberVec,indMemberVec]=ismember(inpMat1,inpMat2,'rows');
        else
            isMemberVec=ismember(inpMat1,inpMat2,'rows');
        end
        return;
    end
    % unite all values in single matrix
    inpMat1=[inpMat1;inpMat2];
    clear inpMat2;
    inpMat1=double(inpMat1)+(1-minInpVal);
    % calculate codes for rows
    allSizeVec=max(inpMat1,[],1);
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
            auxCell{iCol}=inpMat1(:,iCol);
        end
        nCurCols=nCols;
        nCols=numel(lenVec);
        if nCols==1,
            % get column vector with codes
            inpMat1=sub2ind(allSizeVec,auxCell{:});
        else
            inpMat1=inpMat1(:,1:nCols);
            sizeVec=nan(1,nCols);
            % adjust lenVec
            lenVec(end)=lenVec(end)+nCurCols-sum(lenVec);
            % if necessary, process last segment with single column
            if lenVec(end)==1,
                inpMat1(:,nCols)=auxCell{nCurCols};
                sizeVec(nCols)=allSizeVec(nCurCols);
                nCurCols=nCols-1;
            else
                nCurCols=nCols;
            end
            % get codes for all segments
            leftIndVec=[1 cumsum(lenVec(1:nCurCols-1))+1];
            for iCol=1:nCurCols,
                curInd=leftIndVec(iCol)+(0:lenVec(iCol)-1);
                [uniqueLinInd,~,inpMat1(:,iCol)]=unique(...
                    sub2ind(allSizeVec(curInd),auxCell{curInd}));
                sizeVec(iCol)=length(uniqueLinInd);
            end
            allSizeVec=sizeVec;
        end
    end
    % perform built-in ismember for codes
    if nCols==0,
        isMemberVec=true(nRows1,1);
        indMemberVec=nRows2*ones(nRows1,1);
    else
        if isInd,
            [isMemberVec,indMemberVec]=ismember(inpMat1(1:nRows1),inpMat1(nRows1+1:end));
        else
            isMemberVec=ismember(inpMat1(1:nRows1),inpMat1(nRows1+1:end));
        end
    end
end