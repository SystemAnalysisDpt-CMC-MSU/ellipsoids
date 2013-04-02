function FuncData=collecthelp(dirName,varargin)
% COLLECTHELP collects helps of m files in given directory
%
% Usage: FuncData=collecthelp(dirName,varargin)
%
% Input:
%   regular
%       dirName: string - the path contained functions data;
%   properties:
%       ignorDirList: cell[1,nIgnor] of strings -
%           list of ignored dir names (by default is empty),
%       isClass: logic[1,1] - is current dir class or not,
%           by default false.
%       scriptNamePattern: string - regular expression
%           by default equals 's_\w+\.m'
% Output:
%   FuncData: struct[1,1] with the following fields
%       funcName: cell[nElems,1] - list of function names
%       dirName: cell[nElems,1] - list of directory names
%       help: cell[nElems,1] - list of help headers
%       isClassMethod: logical[nElems,1] - a vector of "is class"
%           indicators
%       isScript: logical[nElems,1] - a vector of "is script" indicators
%
%
% $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2013-04-01 $
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $

import elltool.doc.collecthelp;
%% Parse params
[~,prop]=parseparams(varargin);
nProp=length(prop);
ignorDirList={};
isClass=false;
%
classPrefix='@';
%
scriptNamePattern='s_\w+\.m';
%
for k=1:2:nProp-1
    switch lower(prop{k})
        case 'ignordirlist',
            ignorDirList=prop{k+1};
        case 'isclass',
            isClass=prop{k+1};
        case 'scriptnamepattern',
            scriptNamePattern=prop{k+1};
        otherwise,
            warning('unidentified property name: %s ',prop{k});
    end;
end;
%%
FuncData=[];
%% find m files in current dir
funcList=what(dirName);

if ~isempty(funcList)
    funcNameList=funcList.m;
    funcClassList=funcList.classes;
else
    funcNameList=cell(1,0);
    funcClassList=cell(1,0);
end
%
FuncData.funcName=funcNameList;
%
FuncData.dirName=cell(length(funcNameList),1);
FuncData.help=FuncData.dirName;
FuncData.isClassMethod=repmat(isClass,size(funcNameList));
% dir
FuncData.dirName(:)={funcList.path};
% help
for iFunc=1:length(funcNameList)
    FuncData.help{iFunc}=help([funcList.path, '/', funcNameList{iFunc}]);
end
% is script
 possibleScript=regexp(funcNameList,scriptNamePattern,'once','match');
 FuncData.isScript=logical(cellfun(@(x,y) isequal(x,y),funcNameList,possibleScript));
%% find m files in subdirs
contentsList=dir(dirName);
dirList={contentsList.name};
dirList=dirList([contentsList.isdir]);
dirList=setdiff(dirList,['.','..',ignorDirList]);
%
classDir=cellfun(@(x) [classPrefix,x],funcClassList,'UniformOutput',false);
isClassDir=isClass | ismember(dirList,classDir);
% field names
dataFieldNames=fieldnames(FuncData);
length(dirList);
for iSubDir=1:length(dirList)
    FuncDataCur=...
        collecthelp([dirName '/' dirList{iSubDir}],'ignorDirList',ignorDirList,...
        'isClass',isClassDir(iSubDir),'scriptNamePattern',scriptNamePattern);
    %
    for iField=1:length(dataFieldNames)
        FuncData.(dataFieldNames{iField})=[FuncData.(dataFieldNames{iField});...
            FuncDataCur.(dataFieldNames{iField})];
    end
end
