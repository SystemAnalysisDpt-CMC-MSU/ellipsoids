function [isThereVec,indThereVec]=ismemberbyfunc(leftVec,rightVec,...
    fCompare)
% ISMEMBERBYFUNC - ismember implementation for arrays of any type where an
%   element comparison is performed by a specified function. This function
%   is useful when elements are not sortable i.e. EITHER an implementation
%   of @eq,@ne,@gt,@lt,@ge,@le does not define a full order OR there is no
%   an implementation of @sort method that calls these operators
%
% Usage: [isThereVec,indThereVec]=modgen.common.ismemberbyfunc(leftVec,...
% 	rightVec,fCompare);
%
% Input:
%   regular:
%       leftVec: any[nObjectsLeft,1]/[1,nObjectsLeft]
%       rightVec: any[nObjectsRight,1]/[1,nObjectsRight]
%   optional:
%   	fCompare: function_handle[1,1] - an element comparison function,
%       	default is @isequaln
%
% Output:
%   isThereVec: logical[nObjectsLeft,1]/[1,nObjectsLeft]
%   indThereVec: double[nObjectsLeft,1]/[1,nObjectsLeft]
%
% Examples:
%
%   leftVec={struct('a',1,'b',2)}
%   rightVec={struct('a',2,'b',2); struct('a',111,'g','555')}
%   [isThereVec,indThereVec]=ismemberbyfunc(leftVec,rightVec,@(x,y)x.a==y.a)
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
import modgen.common.throwerror;
if nargin<3
    fCompare=@isequaln;
end
%%
if isempty(rightVec)
    isThereVec=false(size(leftVec));
    indThereVec=zeros(size(leftVec));
else
    if ~isvector(leftVec)
        throwerror('wrongInput','leftVec is expected to be a vector');
    end
    if ~isvector(rightVec)
        throwerror('wrongInput','rightVec is expected to be a vector');
    end
    isCell=iscell(leftVec);
    if iscell(rightVec)~=isCell,
        throwerror('wrongInput',...
            ['leftVec and rightVec must be either cells or non cells ',...
            'simultaneosly']);
    end
    %
    if iscolumn(leftVec)
        isLeftCol=true;
        leftVec=leftVec.';
    else
        isLeftCol=false;
    end
    %
    if isrow(rightVec)
        rightVec=rightVec.';
    end
    %
    leftVecMat=repmat(leftVec,length(rightVec),1);
    rightVecMat=repmat(rightVec,1,length(leftVec));
    if isCell
        isEqualMat=cellfun(fCompare,leftVecMat,rightVecMat);
    else
        isEqualMat=arrayfun(fCompare,leftVecMat,rightVecMat);
    end
    %
    isThereVec=any(isEqualMat,1);
    if nargout>1,
        [indBMat,indAMat]=find(isEqualMat);
        indAVec=indAMat(:);
        indBVec=indBMat(:);
        indThereVec=accumarray(indAVec,indBVec,[numel(leftVec) 1],@min,0);
    end
    if isLeftCol
        isThereVec=isThereVec.';
    else
        indThereVec=indThereVec.';
    end
end