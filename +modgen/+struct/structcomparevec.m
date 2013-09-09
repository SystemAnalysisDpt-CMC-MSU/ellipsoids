function [isEqualVec,reportStr]= structcomparevec(SX,SY,absTol,relTol)
% STRUCTCOMPARE compares two structures using the specified tolerance
%
% Input:
%   regular:
%       SLeft: struct[] - first input structure array
%       SRight: struct[] - second input structure array
%   optional:
%       absTol: double[1,1] - maximum allowed tolerance, default value is 0
%       relTol: double[1,1] - maximum allowed relative tolerance, isn't
%                             used by default
%
% Output:
%   isEqualVec: logical[1,] - true if the structures are found equal
%   reportStr: char[1,] report about the found differences
%
%
% $Author: Vadim Kaushanskiy  <vkaushanskiy@gmail.com> $	$Date: 2012-23-11 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Cybernetics,
%            System Analysis Department 2012 $
%
%

if nargin<3
    absTol=0;
end
if nargin<4
    relTol=[];
end
%
if ~isequal(size(SX),size(SY));
    isEqualVec=false;
    reportStr={'sizes are different'};
    return;
end
[isEqualVec,reportStrList]=structcompare1darray(SX(:),SY(:),absTol,relTol);
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


function [isEqualVec,reportStrList]= structcompare1darray(SX,SY,absTol,relTol)
% STRUCTCOMPARE1D compares 1-dimentional structural arrays
%
nElem=numel(SX);
[isEqualList,reportStrList]=arrayfun(@(x,y)structcomparescalar(x,y,absTol,relTol),SX,SY,'UniformOutput',false);
nReportsList=num2cell(cellfun('prodofsize',reportStrList));
isEqualVec=[isEqualList{:}];
isEqualList=cellfun(@(x,y)repmat(x,1,y),isEqualList,nReportsList,'UniformOutput',false);
itemIndList=cellfun(@(x,y)repmat(x,1,y),num2cell(1:nElem).',nReportsList,'UniformOutput',false);
nReports=sum([nReportsList{:}]);
reportStrList=[reportStrList{:}];
itemIndVec=[itemIndList{:}];
isnEqualVec=~[isEqualList{:}];
isEqual=~any(isnEqualVec);
for iReport=1:nReports
    if isnEqualVec(iReport)
        reportStrList{iReport}=sprintf('(%d)%s',itemIndVec(iReport),reportStrList{iReport});
    end
end
%
end

function [isEqual,reportStrList]= structcomparescalar(SX,SY,absTol,relTol)
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
    [isEqualCur,reportStrCurList]=compfun(SX.(fieldName),SY.(fieldName),absTol,relTol);
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

function [isEqual,reportStr]=compfun(x,y,absTol,relTol)
% COMPFUN compares two different objects (ideally - of any type)
import modgen.common.absrelcompare;
%
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
    if ismember(xClass,{'double','single'})
        isNanX=isnan(x);
        isNanY=isnan(y);
        if ~isequal(isNanX,isNanY);
            reportStr='Nans are on the different places';
            return;
        end
        isMinusInfX=x==-Inf;
        isMinusInfY=y==-Inf;
        if ~isequal(isMinusInfX,isMinusInfY);
            reportStr='-Infs are on the different places';
            return;
        end
        isInfX=x==Inf;
        isInfY=y==Inf;        
        if ~isequal(isInfX,isInfY);
            reportStr='-Inf are on the different places';
            return;
        end
        isCompX=~(isNanX|isMinusInfX|isInfX);
        isCompY=~(isNanY|isMinusInfY|isInfY);
    else
        isCompX=true(size(x));
        isCompY=true(size(y));
    end
    %
    [isEqual, ~, ~, ~, ~, reportStr] = absrelcompare(x(isCompX), ...
        y(isCompY), absTol, relTol, @abs);
    %
    if ~isEqual
        reportStr = horzcat('Max. ', reportStr);
        return;
    end
elseif isstruct(x)
    [isEqual,reportStr]=modgen.struct.structcompare(x,y,absTol,relTol);
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
        [isEqual,reportStr]=compfun(x{iElem},y{iElem},absTol,relTol);
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