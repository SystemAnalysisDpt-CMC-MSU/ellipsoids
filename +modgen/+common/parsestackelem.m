function [methodName,className]=parsestackelem(SStackElem)
% PARSESTACKELEM parses structure for given element of stack and returns
% the corresponding function/script name or method name together with class
% name in the case the element corresponds to some method of class 
%
% Usage: methodName=parsestackelem(SStackElem) OR
%        [methodName className]=parsestackelem(SStackElem)
%
% input:
%   regular:
%     SStackElem: struct [1,1] - structure with the same fields as those
%         that are given by dbstack (see info for dbstack for details)
% output:
%   regular:
%     methodName: char - name of function/script or method
%     className: char - empty if it is not a method of some class,
%        otherwise name of the corresponding class
%
% Note: 1) In the case an element corresponds to a method of some class,
%          className contains also info on packages, otherwise info on
%          packages is included into methodName. Thus, for example, for
%          method PCAForecast of equivolent.forecast.pca.PCAForecast class
%          we would have:
%            methodName='PCAForecast';
%            className='equivolent.forecast.pca.PCAForecast';
%          If we have function modgen.common.num2cell, then we would have
%            methodName='modgen.common.num2cell';
%            className='';
%          The last is true also for scripts.
%       2) In the case an element corresponds to a subfunction of some
%          method or function methodName contains also the whole path to
%          this subfunction, for instance, for subfunction subfunc of
%          function package.subpackage.func we would have:
%            methodName='package.subpackage.func/subfunc';
%            className='';
%          Analogous situation is for scripts and methods of classes.
%
%
% $Author: Ilya Roublev  <iroublev@gmail.com> $	$Date: 2014-08-12 $ 
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2014 $
%
%

if nargin==0,
    modgen.common.throwerror('wrongInput',...
        'SStackElem must be given');
end
modgen.common.checkvar(SStackElem,'isstruct(x)&&numel(x)==1',...
    'SStackElem');
modgen.common.checkvar(SStackElem,'all(isfield(x,{''file'',''name''}))',...
    'SStackElem');
[pathStr,fileName]=fileparts(SStackElem.file);
if isempty(strfind(pathStr,[filesep '+']))&&isempty(strfind(pathStr,[filesep '@'])),
    pathStr='';
    isClass=false;
    isPath=false;
else
    pathStr=strrep(pathStr,[filesep '+'],'.');
    indClass=strfind(pathStr,[filesep '@']);
    isClass=~isempty(indClass);
    if isClass,
        pathStr(indClass)='.';
        pathStr(indClass+1)=[];
    end
    curInd=find(pathStr==filesep,1,'last');
    if ~isempty(curInd),
        pathStr=pathStr(curInd+1:end);
    end
    curInd=find(pathStr=='.',1,'first');
    if isempty(curInd),
        isPath=false;
    else
        pathStr=pathStr(curInd+1:end);
        isPath=~isempty(pathStr);
    end
end
methodName=SStackElem.name;
curInd=find(methodName=='.',1,'last');
if ~isempty(curInd),
    methodName=methodName(curInd+1:end);
    if ~isClass,
        if isPath,
            pathStr=[pathStr '.' fileName];
        else
            pathStr=fileName;
            isPath=true;
        end
        isClass=true;
    end
end
className='';
if isPath&&isClass,
    className=pathStr;
end
curInd=find(methodName=='/'|methodName=='\',1,'first');
if isempty(curInd),
    mainMethodName=methodName;
else
    mainMethodName=methodName(1:curInd-1);
end
curInd=find(className=='.',1,'last');
if isempty(curInd),
    mainClassName=className;
else
    mainClassName=className(curInd+1:end);
end
if ~(isequal(fileName,mainMethodName)||(isClass&&isequal(fileName,mainClassName))),
    methodName=[fileName '/' methodName];
end
if isPath&&~isClass,
    methodName=[pathStr '.' methodName];
end