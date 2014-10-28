function [isEqMat,reportStr]=eq(self,otherObj,varargin)
% EQ returns true if CubeStruct objects are equal and false
% otherwise; EQ(A,B) overloads symbolic A == B
%
% Usage: isEqMat=eq(self,otherObj,varargin)
%
% Input:
%   regular:
%     self: CubeStruct [n_1,n_2,...,n_k] or CubeStruct [1,1] - current
%         CubeStruct object(s)
%     otherObj: CubeStruct [n_1,n_2,...,n_k] or CubeStruct [1,1] - other
%         CubeStruct object(s)
% Output:
%   regular:
%     isEqMat: [n_1,n_2,...,n_k] - the element is true if the
%         corresponding objects are equal, false otherwise
%   optional:
%     reportStr: char - report about the found differences
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%   reportStr is returned
%

if nargin<2,
    error([upper(mfilename),':wrongInput'],...
        'both object to be compared must be given');
end
if ~isempty(varargin),
    if ~ischar(varargin{1}),
        error([upper(mfilename),':wrongInput'],...
            'Additional regular arguments must not be passed');
    end
end
reportStr='';
sizeVec=size(self);
if ~isequal(sizeVec,size(otherObj)),
    if numel(self)==1,
        sizeVec=size(otherObj);
        self=repmat(self,sizeVec);
    elseif numel(otherObj)==1,
        otherObj=repmat(otherObj,sizeVec);
    else
        error('MATLAB:dimagree',...
            'Matrix dimensions must agree.');
    end
end
isEqMat=true(sizeVec);
if eq@handle(self,otherObj),
    return;
end
if ~isa(otherObj,class(self)),
    isEqMat(:)=false;
    if nargout>1,
        reportStr='Not equal classes of objects';
    end
    return;
end
if isempty(isEqMat),
    return;
end
prop=varargin;
if ~isempty(prop),
    if ~ischar(prop{1}),
        error([upper(mfilename),':wrongInput'],...
            'Additional regular arguments must not be passed');
    end
end
nElems=numel(self);
reportStrList=cell(1,nElems);
for iElem=1:nElems,
    if nargout>1,
        [isEqCur,reportStrCur]=isEqual(self(iElem),otherObj(iElem),prop{:});
        if ~isempty(reportStrCur),
            reportStrList{iElem}=sprintf('(%d-th elements):%s',iElem,reportStrCur);
        end
    else
        isEqCur=isEqual(self(iElem),otherObj(iElem),prop{:});
    end
    isEqMat(iElem)=isEqCur;
end
if nargout>1,
    reportStrList(cellfun('isempty',reportStrList))=[];
    if length(reportStrList)>1,
        reportStr=modgen.string.catwithsep(reportStrList,sprintf('\n'));
    elseif ~isempty(reportStrList),
        reportStr=reportStrList{:};
    end
end
end