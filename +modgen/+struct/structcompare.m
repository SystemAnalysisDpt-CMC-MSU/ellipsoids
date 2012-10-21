function [isEqual,reportStr]= structcompare(SX,SY,tol)
% STRUCTCOMPARE compares two structures using the specified tolerance
%
% Input:
%   regular:
%       S1: struct[] - first input structure
%       S2: struct[] - second input structure
%   optional:
%       tol: double[1,] - maximum allowed tolerance, default value is 0
%
% Output:
%   isEqual: logical[1,1] - true if the structures are found equal
%   reportStr: char[1,1] report about the found differences
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2011-06-05 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2011 $
%
%

if nargin<3
    tol=0;
end
%
if ~isequal(size(SX),size(SY));
    isEqual=false;
    reportStr={'sizes are different'};
    return;
end
[isEqual,reportStrList]=structcompare1darray(SX(:),SY(:),tol);
nReports=length(reportStrList);
if nReports>1
    reportStrList(1:end-1)=cellfun(@(x)horzcat(x,sprintf('\n')),reportStrList(1:end-1),'UniformOutput',false);
end
if nReports>0
    reportStr=[reportStrList{:}];
else
    reportStr='';
end
end

function [isEqual,reportStrList]= structcompare1darray(SX,SY,tol)
% STRUCTCOMPARE1D compares 1-dimentional structural arrays
%
nElem=numel(SX);
[isEqualList,reportStrList]=arrayfun(@(x,y)structcomparescalar(x,y,tol),SX,SY,'UniformOutput',false);
nReportsList=num2cell(cellfun('prodofsize',reportStrList));
isEqualList=cellfun(@(x,y)repmat(x,1,y),isEqualList,nReportsList,'UniformOutput',false);
itemIndList=cellfun(@(x,y)repmat(x,1,y),num2cell(1:nElem).',nReportsList,'UniformOutput',false);
nReports=sum([nReportsList{:}]);
isEqualVec=[isEqualList{:}];
reportStrList=[reportStrList{:}];
itemIndVec=[itemIndList{:}];
isnEqualVec=~isEqualVec;
isEqual=~any(isnEqualVec);
for iReport=1:nReports
    if isnEqualVec(iReport)
        reportStrList{iReport}=sprintf('(%d)%s',itemIndVec(iReport),reportStrList{iReport});
    end
end
%
end

function [isEqual,reportStrList]= structcomparescalar(SX,SY,tol)
% STRUCTCOMPARE1D compares the scalar structures

if ~auxchecksize(SX,SY,[1 1])
    error([upper(mfilename),':wrongInput'],'both inputs are expected to be of size [1,1]');
end
%
if ~(isstruct(SX)&&isstruct(SY))
    error([upper(mfilename),':wrongInput'],'both inputs are expected to be structures');
end
%
reportStrList={};
fieldXList=sort(fieldnames(SX).');
fieldYList=sort(fieldnames(SY).');
isEqual=isequal(fieldXList,fieldYList);
if ~isEqual,
    reportStrList={['Field names are different, left:',...
        cell2sepstr('',fieldXList,'|'),', right: ',cell2sepstr('',fieldYList,'|')]};
    return;
end
%
nFields=length(fieldXList);
for iField=1:nFields
    fieldName=fieldXList{iField};
    [isEqualCur,reportStrCurList]=compfun(SX.(fieldName),SY.(fieldName),tol);
    isEqual=isEqual&&isEqualCur;
    if ~isEqualCur
        if ~isstruct(SX.(fieldName))
            reportStrCurList=strcat('--> ',reportStrCurList);
        end
        reportStrCurList=strcat('.',fieldName,reportStrCurList);
        reportStrList=[reportStrList,reportStrCurList];
    end
end
end

function [isEqual,reportStr]=compfun(x,y,tol)
% COMPFUN compares two different objects (ideally - of any type)
reportStr='';
isEqual=false;
xClass=class(x);
yClass=class(y);
%
if ~isequal(xClass,yClass)
    reportStr='Different types';
    return;
end
%
if isnumeric(x)
    xSizeVec=size(x);
    ySizeVec=size(y);
    if ~isequal(xSizeVec,ySizeVec)
        reportStr=sprintf('Different sizes (left: %s, right: %s)',mat2str(xSizeVec),mat2str(ySizeVec));
        return;
    end
    x=toNumericSupportingMinus(x);
    y=toNumericSupportingMinus(y);
    maxDiff=max(abs(x(:)-y(:)));
    isUpperTolVec=maxDiff>tol;
    if any(isUpperTolVec)
        reportStr=sprintf('Max. difference (%d) is greater than the specified tolerance(%d)',maxDiff,tol);
        return;
    end
    if ismember(xClass,{'double','single'})
        isNanX=isnan(x);
        isNanY=isnan(y);
        if ~isequal(isNanX,isNanY);
            reportStr='Nans are on the different places';
            return;
        end
    end
elseif isstruct(x)
    [isEqual,reportStr]=modgen.struct.structcompare(x,y,tol);
    if ~isEqual
        return;
    end
elseif iscell(x)&&~iscellstr(x),
    nElems=numel(x);
    if nElems==0,
        isEqual=true;
        return;
    end
    for iElem=1:nElems,
        [isEqual,reportStr]=compfun(x{iElem},y{iElem},tol);
        if ~isEqual,
            break;
        end
    end
    if ~isEqual,
        reportStr=strcat('{',num2str(iElem),'}',reportStr);
        return;
    end
elseif  isa(x,'function_handle'),
    isEqual=isequal(func2str(x),func2str(y));
    if ~isEqual,
        reportStr='values are different';
        return;
    end
elseif ~isequal(x,y)
    reportStr='values are different';
    return;
end
isEqual=true;
end
function x=toNumericSupportingMinus(x)
if isa(x,'uint64')||isa(x,'int64')
    x=double(x);
end
end