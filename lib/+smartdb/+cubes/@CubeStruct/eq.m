function [isEq,reportStr]=eq(self,otherObj,varargin)
% EQ returns true if CubeStruct objects are equal and false
% otherwise; EQ(A,B) overloads symbolic A == B
%
% Usage: isEq=eq(self,otherObj,varargin)
%
% Input:
%   regular:
%     self: CubeStruct [1,nElems] - current CubeStruct object(s)
%     otherObj: CubeStruct [1,nElems] - other CubeStruct object(s)
%
%   properties:
%     isFullCheck: logical [1,1] - if true, then all elements of arrays are
%         compared, otherwise (default) check is performed up to the first
%         difference
%
% Output:
%   regular:
%     isEq: logical[1,1] - true if the specified objects are equal
%   optional:
%     reportStr: char - report about the found differences
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-03-29 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%   reportStr is returned, isFullCheck property is added
%

if nargin<2,
    error([upper(mfilename),':wrongInput'],...
        'both object to be compared must be given');
end
reportStr='';
isEq=isequal(size(self),size(otherObj));
if ~isEq,
    if nargout>1,
        reportStr='Not equal sizes of objects';
    end
    return;
end
if eq@handle(self,otherObj)
    isEq=true;
    return;
end
isEq=strcmp(class(self),class(otherObj));
if ~isEq,
    if nargout>1,
        reportStr='Not equal classes of objects';
    end
    return;
end
isEq=isempty(self)&&isempty(otherObj);
if isEq,
    return;
end
isFullCheck=false;
prop=varargin;
if ~isempty(prop),
    if ~ischar(prop{1}),
        error([upper(mfilename),':wrongInput'],...
            'Additional regular arguments must not be passed');
    end
    indProp=find(strcmpi('isfullcheck',prop(1:2:end-1)),1,'first');
    if ~isempty(indProp),
        indProp=2*indProp;
        isFullCheck=prop{indProp};
        prop([indProp-1 indProp])=[];
    end
end
nElems=numel(self);
reportStrList=cell(1,nElems);
isEq=true;
for iElem=1:nElems,
    if nargout>1,
        [isEqCur,reportStrCur]=isEqual(self(iElem),otherObj(iElem),prop{:});
        if ~isempty(reportStrCur),
            reportStrList{iElem}=sprintf('(%d-th elements):%s',iElem,reportStrCur);
        end
    else
        isEqCur=isEqual(self(iElem),otherObj(iElem),prop{:});
    end
    isEq=isEq&&isEqCur;
    if ~(isEq||isFullCheck),
        break;
    end
end
reportStrList(cellfun('isempty',reportStrList))=[];
nReports=length(reportStrList);
if nReports>1,
    reportStrList(1:end-1)=cellfun(@(x)horzcat(x,sprintf('\n')),reportStrList(1:end-1),'UniformOutput',false);
end
if nReports>0,
    reportStr=horzcat(reportStrList{:});
end
end