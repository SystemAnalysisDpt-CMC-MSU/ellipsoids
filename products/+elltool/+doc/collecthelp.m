function FuncData=collecthelp(classNames, packNames, ignorList)
%COLLECTHELP -  collects helps of m files in given classes and packages
%
% Input:
%    classNames:cell[1, n] - the names of classes for scanning
%    packNames:cell[1, n]  - the names of packages for scanning
%    ignorList:cell[1, 1]  - the names of ignored subpackages.
% Output:
%   FuncData: struct[1,1] with the following fields
%       funcName: cell[nElems,1] - list of function names
%       help: cell[nElems,1] - list of help headers
%       isScript: logical[nElems,1] - a vector of 
%                          "is script" indicators
% 
%Usage: FuncData=collecthelp(classNames, packNames, ignorList)
%
%
%$Author: Peter Gagarinov  <pgagarinov@gmail.com> $
%$Date: 2013-04-01 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $

%%
import elltool.doc.collecthelp;
FuncData = [];
scriptNamePattern = 's_\w+\.m';
SfuncInfo = extractHelpFromClass(classNames);
FuncData=modgen.struct.unionstructsalongdim(1,FuncData,SfuncInfo);
dirLength = length(packNames);
for iElem = 1:dirLength
    mp = meta.package.fromName(char(packNames(iElem)));
    if isempty(mp.FunctionList)
        SfuncInfo=struct();
    else
       SfuncInfo = extractHelpFromFunc(mp);
    end
    FuncData=modgen.struct.unionstructsalongdim(1,FuncData,SfuncInfo);
    if isempty(mp.ClassList)
       SfuncInfo=struct();
    else
       classVec = mp.ClassList;
       myClassList = arrayfun(@(x)x.Name,classVec,'UniformOutput',false);
       SfuncInfo = extractHelpFromClass(myClassList');
    end
    FuncData=modgen.struct.unionstructsalongdim(1,FuncData,SfuncInfo);
    if isempty(mp.PackageList)
        SfuncInfo=struct();
    else
        pLength = length(mp.PackageList);
        myPack = mp.PackageList;
        for iPack = 1:pLength
            classVec = myPack(iPack).ClassList;
            myClassList = arrayfun(@(x)x.Name,classVec,'UniformOutput',false);
            packVec = myPack(iPack).PackageList;
            myPackList = arrayfun(@(x)x.Name,packVec,'UniformOutput',false);
            ignorPackFlag = regexp(myPackList, ignorList);
            ignorClassFlag = regexp(myClassList, ignorList);
            newPackList = myPackList;
            newClassList = myClassList;
            for j = 1:length(myPackList)
                if ~isnan(cell2mat(ignorPackFlag(j)))
                    newPackList = setdiff(newPackList,myPackList(j));
                end
            end
            for j = 1:length(myClassList)
                if ~isnan(cell2mat(ignorClassFlag(j)))
                    newClassList = setdiff(newClassList,myClassList(j));
                end
            end
            SfuncInfo = collecthelp(newClassList', newPackList', ignorList);
            FuncData=modgen.struct.unionstructsalongdim(1,FuncData,SfuncInfo);
        end
    end
    
end

%%

function SFuncInfo=extractHelpFromClass(classList)
SFuncInfo = struct();
PUBLIC_ACCESS_MOD='public';
nLength = length(classList);
for iClass = 1:nLength
    className = char(classList(iClass));
    mc = meta.class.fromName(className);
    handleClassMethodNameList=arrayfun(@(x)x.Name,...
         meta.class.fromName('handle').MethodList,'UniformOutput',false);
    if isempty(mc)
        bufFuncInfo=struct();
    else
        methodVec=mc.MethodList;
        curClassMethodNameList=arrayfun(@(x)x.Name,...
                        methodVec,'UniformOutput',false);
        methodFlag = any([methodVec.Abstract]);
        propFlag =  any([mc.PropertyList.Abstract]);
        isAbstractClass  = methodFlag | propFlag;
        if (~isAbstractClass)
            emptyObj=eval([className,'.empty(0,0)']);
            isHandleClass=isa(emptyObj,'handle');
            if isHandleClass
                isHandleMethodVec=ismember(curClassMethodNameList,...
                         handleClassMethodNameList);
                methodVec= methodVec(~isHandleMethodVec);
            end
        isPublicVec=arrayfun(@(x)isequal(x.Access,PUBLIC_ACCESS_MOD),...
                         methodVec);
        publicMethodVec=methodVec(isPublicVec);
        fullNameList=arrayfun(@(x)[className,'.',x.Name],publicMethodVec,...
                      'UniformOutput',false);
        bufFuncNameList = arrayfun(@(x)[className,'/',x.Name],publicMethodVec,...
                      'UniformOutput',false);
        helpList=cellfun(@help,fullNameList,'UniformOutput',false);
        helpList=cellfun(@(x, y)fDeleteHelpStr(x, y),helpList,...
            bufFuncNameList, 'UniformOutput',false);
        bufFuncInfo.funcName=fullNameList;
        possibleScript=regexp(fullNameList,scriptNamePattern,'once','match');
        bufFuncInfo.isScript=logical(cellfun(@(x,y) isequal(x,y),...
             fullNameList,possibleScript));
        bufFuncInfo.help=helpList;
        SFuncInfo=modgen.struct.unionstructsalongdim(1,SFuncInfo,bufFuncInfo);
        end
    end
end
end


function SFuncInfo=extractHelpFromFunc(mPack)
   funcVec = mPack.FunctionList;
   funcNameList=arrayfun(@(x)x.Name,funcVec,'UniformOutput',false);
   funcNameList = strcat(mPack.Name,'.',funcNameList);
   helpList=cellfun(@help,funcNameList,'UniformOutput',false);
   SFuncInfo.funcName=funcNameList;
   possibleScript=regexp(funcNameList,scriptNamePattern,'once','match');
   SFuncInfo.isScript=logical(cellfun(@(x,y) isequal(x,y),funcNameList,...
        possibleScript));
   SFuncInfo.help=helpList;
end

function result = fDeleteHelpStr(helpText, helpStr)
    indStartDel=strfind(helpText,sprintf('Help for %s', helpStr));
    helpText(indStartDel:end)=[];
    result = helpText;
end
end
