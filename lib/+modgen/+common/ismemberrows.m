function [isMemberVec,indMemberVec]=ismemberrows(inpLeftMat,inpRightMat,...
    isInteger,forceMode)
% ISMEMBERROWS finds indices of rows from the first matrix in 
%   the second matrix, i.e. it is the more efficient version 
%   of ISMEMBER(...,'rows')
%
% Usage: [isMemberVec,indMemberVec]=ismemberrows(inpLeftMat,inpRightMat)
%
% Input:
%   regular:
%       inpLeftMat: double/logical/char[nLeftRows,nCols] - first matrix
%       inpRightMat: double/logical/char[nRightRows,nCols] - second matrix
%   optional:
%   	isInteger: logical[1,1] - if true then no checks that inpLeftMat and
%           inpRightMat contain finite integer values are performed
%       forceMode: char[1,] - if given, then determines mode to be used,
%           may be 'standard' (in this case built-in version is forced to
%         be used) or 'optimized' (then optimized version is to be used
%         instead of built-in one in the case it is possible)
% Output:
%   isMemberVec: logical [nLeftRows,1] - whether corresponding row from
%       inpLeftMat equals to some row in matrix inpRightMat
%   indMemberVec: double [nLeftRows,1] - indices of corresponding rows
%       from inpLeftMat in matrix inpRightMat (0 if there is no equal row in b)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-19 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $
%
%
import modgen.common.throwerror;
persistent maxVal sqMaxVal logMaxVal;
%
if nargin<3,
    isInteger=false;
end
[nLeftRows,nCols]=size(inpLeftMat);
if size(inpRightMat,2)~=nCols,
    throwerror('wrongInput',...
        'Number of columns in inpLeftMat and inpRightMat must be the same');
end
nRightRows=size(inpRightMat,1);
isInd=nargout>1;
if nLeftRows==0||nRightRows==0||nCols==0,
    if nCols==0,
        isMemberVec=true(nLeftRows,1);
        indMemberVec=repmat(nRightRows,nLeftRows,1);
    else
        isMemberVec=false(nLeftRows,1);
        indMemberVec=zeros(nLeftRows,1);
    end
    return;
end
if ~isInteger,
    isNum=isnumeric(inpLeftMat)&&isnumeric(inpRightMat);
    if isNum,
        if ~(isreal(inpLeftMat)&&isreal(inpRightMat)),
            % transform complex numbers to real ones separating them on real
            % and imaginery parts
            nCols=2*nCols;
            inpLeftMat=[real(inpLeftMat) imag(inpLeftMat)];
            inpRightMat=[real(inpRightMat) imag(inpRightMat)];
        end
    end
end
if nCols<2,
    % for simple situation use ismember
    if ~isInteger,
        % find nans
        isLeftMat=isnan(inpLeftMat);
        isRightMat=isnan(inpRightMat);
        isLeftNan=any(isLeftMat);
        isRightNan=any(isRightMat);
        isInteger=~(isLeftNan||isRightNan);
    end
    if isInteger,
        % perform ismember
        if isInd,
            [isMemberVec,indMemberVec]=ismember(inpLeftMat,inpRightMat,'legacy');
        else
            isMemberVec=ismember(inpLeftMat,inpRightMat,'legacy');
        end
    else
        isMemberVec=false(nLeftRows,1);
        indMemberVec=zeros(nLeftRows,1);
        % perform ismember for NaNs
        if isLeftNan,
            if isRightNan,
                isMemberVec(isLeftMat)=true;
                indMemberVec(isLeftMat)=find(isRightMat,1,'last');
            end
        end
        if isLeftNan||isRightNan,
            isLeftMat=~isLeftMat;
            isRightMat=~isRightMat;
        end
        % peform ismember for non-NaNs
        if isInd,
            [isCurMemberVec,indCurMemberVec]=ismember(inpLeftMat(isLeftMat),inpRightMat(isRightMat),'legacy');
            if isRightNan&&any(isCurMemberVec),
                inpRightMat=find(isRightMat);
                indCurMemberVec(isCurMemberVec)=inpRightMat(indCurMemberVec(isCurMemberVec));
            end
            isMemberVec(isLeftMat)=isCurMemberVec;
            indMemberVec(isLeftMat)=indCurMemberVec;
        else
            isMemberVec(isLeftMat)=ismember(inpLeftMat(isLeftMat),inpRightMat(isRightMat),'legacy');
        end
    end
else
    % initial actions
    isForceMode=nargin>=4;
    if ~strcmp(class(inpLeftMat),class(inpRightMat)),
        throwerror('wrongInput',...
            'Classes of inpLeftMat and inpRightMat differ');
    end
    if isempty(maxVal)||isempty(sqMaxVal)||isempty(logMaxVal),
        maxVal=1/eps('double');
        sqMaxVal=sqrt(maxVal);
        logMaxVal=log2(maxVal);
    end
    isnOptimized=true;
    isIntType=isinteger(inpLeftMat);
    isLogicalType=islogical(inpLeftMat);
    isCharType=ischar(inpLeftMat);
    isInteger=isInteger||isIntType||isLogicalType||isCharType;
    isReshape=~isInteger;
    if isReshape,
        if ~isNum,
            throwerror(':wrongInput',...
                'Type of inpLeftMat and inpRightMat is wrong');
        end
        % reshape matrices into column vectors
        inpLeftMat=inpLeftMat(:);
        inpRightMat=inpRightMat(:);
        isLeftMat=isfinite(inpLeftMat);
        isRightMat=isfinite(inpRightMat);
        if (all(isLeftMat)&&all(isRightMat)),
            minInpVal=min(min(inpLeftMat),min(inpRightMat));
            maxInpVal=max(max(inpLeftMat),max(inpRightMat));
        else
            % replace non-finite numbers by finite ones
            inpMat=[inpLeftMat(isLeftMat);inpRightMat(isRightMat)];
            % determine range of finite values
            if isempty(inpMat),
                minInpVal=0;
                maxInpVal=0;
            else
                minInpVal=min(inpMat);
                maxInpVal=max(inpMat);
            end
            isLeftMat=~isLeftMat;
            isRightMat=~isRightMat;
            inpMat=[inpLeftMat(isLeftMat);inpRightMat(isRightMat)];
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
                    throwerror('wrongInput',...
                        ['Range of values in inpLeftMat and inpRightMat is ',...
                        'too large to process it correctly']);
                end
                nextVal=curVal+1;
                if nextVal==curVal,
                    nextVal=2*curVal;
                end
                maxInpVal=nextVal;
                inpMat(isMat)=nextVal;
            end
            % update non-finite values
            curVal=sum(isLeftMat);
            inpLeftMat(isLeftMat)=inpMat(1:curVal);
            inpRightMat(isRightMat)=inpMat(curVal+1:end);
        end
        rangeVal=maxInpVal-minInpVal+1;
        if rangeVal<=sqMaxVal,
            isInteger=all(fix(inpLeftMat)==inpLeftMat)&&...
                all(fix(inpRightMat)==inpRightMat);
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
                inpLeftMat=inpLeftMat(:);
                inpRightMat=inpRightMat(:);
            end
            minInpVal=double(min(min(inpLeftMat),min(inpRightMat)));
            maxInpVal=double(max(max(inpLeftMat),max(inpRightMat)));
        end
        % determine whether optimized version may be performed or not
        rangeVal=maxInpVal-minInpVal+1;
        isnOptimized=rangeVal>sqMaxVal;
    end
    % reshape inpLeftMat and inpRightMat from column vectors into matrices if
    % necessary
    if isReshape,
        inpLeftMat=reshape(inpLeftMat,nLeftRows,nCols);
        inpRightMat=reshape(inpRightMat,nRightRows,nCols);
    end
    if isForceMode,
        isnOptimized=isnOptimized||~strcmpi(forceMode,'optimized');
    elseif ~isnOptimized,
        % determine what version (standard or optimized) is to be used
        nRows=nLeftRows+nRightRows;
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
            [isMemberVec,indMemberVec]=ismember(inpLeftMat,inpRightMat,...
                'rows');
        else
            isMemberVec=ismember(inpLeftMat,inpRightMat,'rows');
        end
        return;
    end
    % unite all values in single matrix
    inpLeftMat=[inpLeftMat;inpRightMat];
    clear inpRightMat;
    inpLeftMat=double(inpLeftMat)+(1-minInpVal);
    % calculate codes for rows
    allSizeVec=max(inpLeftMat,[],1);
    while nCols>1,
        iCol=0;
        lenVec=[];
        % break all columns on segments
        while iCol<nCols,
            curInd=max(find(cumprod(allSizeVec(iCol+1:end))<=maxVal,1,...
                'last'),2);
            if isempty(curInd),
                curInd=2;
            end
            lenVec=horzcat(lenVec,curInd); %#ok<AGROW>
            iCol=iCol+curInd;
        end
        % perform num2cell(inpLeftMat,1)
        auxCell=cell(1,nCols);
        for iCol=1:nCols,
            auxCell{iCol}=inpLeftMat(:,iCol);
        end
        nCurCols=nCols;
        nCols=numel(lenVec);
        if nCols==1,
            % get column vector with codes
            inpLeftMat=sub2ind(allSizeVec,auxCell{:});
        else
            inpLeftMat=inpLeftMat(:,1:nCols);
            sizeVec=nan(1,nCols);
            % adjust lenVec
            lenVec(end)=lenVec(end)+nCurCols-sum(lenVec);
            % if necessary, process last segment with single column
            if lenVec(end)==1,
                inpLeftMat(:,nCols)=auxCell{nCurCols};
                sizeVec(nCols)=allSizeVec(nCurCols);
                nCurCols=nCols-1;
            else
                nCurCols=nCols;
            end
            % get codes for all segments
            leftIndVec=[1 cumsum(lenVec(1:nCurCols-1))+1];
            for iCol=1:nCurCols,
                curInd=leftIndVec(iCol)+(0:lenVec(iCol)-1);
                [uniqueLinInd,~,inpLeftMat(:,iCol)]=unique(...
                    sub2ind(allSizeVec(curInd),auxCell{curInd}),'legacy');
                sizeVec(iCol)=length(uniqueLinInd);
            end
            allSizeVec=sizeVec;
        end
    end
    % perform built-in ismember for codes
    if nCols==0,
        isMemberVec=true(nLeftRows,1);
        indMemberVec=nRightRows*ones(nLeftRows,1);
    else
        if isInd,
            [isMemberVec,indMemberVec]=ismember(inpLeftMat(1:nLeftRows),...
                inpLeftMat(nLeftRows+1:end),'legacy');
        else
            isMemberVec=ismember(inpLeftMat(1:nLeftRows),...
                inpLeftMat(nLeftRows+1:end),'legacy');
        end
    end
end