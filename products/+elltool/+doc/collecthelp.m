function FuncData=collecthelp(classNames, packNames, ignorClassList)
%COLLECTHELP -  collects helps of m files in given classes and packages
%
% Input:
%    classNames:cell[1, n] - the names of classes for scanning
%    packNames:cell[1, n]  - the names of packages for scanning
%    ignorList:cell[1, 1]  - the names of ignored subpackages.
% Output:
%   FuncData: struct[1,1] with the following fields
%       sectionName:cell[mElems,1] - list of section names
%       funcName: cell[nElems,1] - list of function names
%       className: cell[nElems,1] - list of class names
%       defClassName: cell[nElems,1] - list of defining class names
%       help: cell[nElems,1] - list of help headers
%       numbOfFunc:double[length(className), 1] - quantity of functions in
%           each class
%       numbOfClass:double[length(className), 1] - quantity of classes in
%           each section
%       inhFuncNameList:cell[nElems,1] - list of inherited functions for
%              each class
%       infoOfInhClass:double[nElems, 1] - quantity of inherited functions 
%              in each class
%       numberOfInhClass:double[nElems, 1] - vector of classes'
%             indices , which inherit functions from other classes.
%       isScript: logical[nElems,1] - a vector of 
%           "is script" indicators
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

[classList defClassList] = fMakeList(classNames);
SfuncInfo = extractHelpFromClass(classList, defClassList);
SfuncInfo = fTransformData(SfuncInfo);
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
            myClassList = arrayfun(@(x)x.Name,classVec,'UniformOutput',...
                false);
            packVec = myPack(iPack).PackageList;
            myPackList = arrayfun(@(x)x.Name,packVec,'UniformOutput',false)
            ignorClassList = union(ignorClassList, classNames)
            ignorPackFlag = regexp(myPackList, ignorClassList);
            ignorClassFlag = regexp(myClassList, ignorClassList);
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
            SfuncInfo = collecthelp(newClassList', newPackList',...
                ignorClassList);
            FuncData=modgen.struct.unionstructsalongdim(1,FuncData,...
                SfuncInfo);
        end
    end
    
end

%%

function SFuncInfo=extractHelpFromClass(classList, defClassList)
SFuncInfo = struct();

PUBLIC_ACCESS_MOD='public';
nLength = length(classList);   
for iClass = 1:nLength
        bufFuncInfo=struct();
        className = char(classList{iClass});
        mc = meta.class.fromName(className);
        handleClassMethodNameList=arrayfun(@(x)x.Name,...
        meta.class.fromName('handle').MethodList,'UniformOutput',false);
        dynamicpropsClassMethodNameList=arrayfun(@(x)x.Name,...
        meta.class.fromName('dynamicprops').MethodList,'UniformOutput',...
        false);
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
                isDynamicpropsClass = isa(emptyObj,'dynamicprops');
                if isHandleClass
                    isHandleMethodVec=ismember(curClassMethodNameList,...
                         handleClassMethodNameList);
                    methodVec= methodVec(~isHandleMethodVec);
                end
                curClassMethodNameList=arrayfun(@(x)x.Name,...
                        methodVec,'UniformOutput',false);
                if isDynamicpropsClass
                    isDynamicpropsVec=ismember(curClassMethodNameList,...
                         dynamicpropsClassMethodNameList);
                    methodVec= methodVec(~isDynamicpropsVec);
                end
            
            else 
                isHandleMethodVec=ismember(curClassMethodNameList,...
                handleClassMethodNameList);
                methodVec= methodVec(~isHandleMethodVec);
                curClassMethodNameList=arrayfun(@(x)x.Name,...
                        methodVec,'UniformOutput',false);
                isDynamicpropsVec=ismember(curClassMethodNameList,...
                         dynamicpropsClassMethodNameList);
                methodVec= methodVec(~isDynamicpropsVec);
            end
            isPublicVec=arrayfun(@(x)isequal(x.Access,PUBLIC_ACCESS_MOD),...
                         methodVec);
            isHiddenVec=arrayfun(@(x)isequal(x.Hidden,1), methodVec);
            methodVec=methodVec(isPublicVec & ~isHiddenVec);
            definingClassNameList=arrayfun(@(x)x.DefiningClass.Name,...
                methodVec,'UniformOutput',false);
            isSourseClass= strcmp(className, definingClassNameList);
            isDefiningClassVec=ismember(definingClassNameList, defClassList);
            isDefClass = ismember(className, defClassList);
            finalDefMethodVec = methodVec(isDefiningClassVec &...
                ~isSourseClass & ~isDefClass);
            definingClassNameList = unique(arrayfun(@(x)x.DefiningClass.Name,...
                finalDefMethodVec,'UniformOutput',false));
            classLength = length(definingClassNameList);
            infoInhClass = zeros(classLength, 1);
            if (classLength ~= 0)
                 bufFuncInfo.numbOfInhClasses = classLength;
            end
            inheritedMethodList = cell(classLength, 1);
            for iBuf = 1:classLength
                isInheritedFromClass=arrayfun(@(x)isequal...
                (x.DefiningClass.Name,definingClassNameList{iBuf}),...
                finalDefMethodVec);
                bufDefMethodVec = finalDefMethodVec(isInheritedFromClass);
                inheritedMethodList{iBuf} = unique(arrayfun(@(x)x.Name,...
                bufDefMethodVec,'UniformOutput',false));
                infoInhClass(iBuf) = length(inheritedMethodList{iBuf});
            end
            if ~isempty(definingClassNameList)
                bufFuncInfo.numberOfInhClass = iClass;
                bufFuncInfo.defClassName = definingClassNameList;
            end
            finalMethodVec= methodVec(~isDefiningClassVec | isSourseClass);
            fullNameList= unique(arrayfun(@(x)[className,'.',x.Name],...
            finalMethodVec,'UniformOutput',false));
            funcNameList = unique(arrayfun(@(x)x.Name,finalMethodVec,...
            'UniformOutput',false));
            bufFuncNameList = unique(arrayfun(@(x)[className,'/',x.Name],...
            finalMethodVec,'UniformOutput',false));
            helpList=cellfun(@help,fullNameList,'UniformOutput',false);
            helpList=cellfun(@(x, y)fDeleteHelpStr(x, y),helpList,...
            bufFuncNameList, 'UniformOutput',false); 
            bufFuncInfo.className = classList(iClass);
            bufFuncInfo.funcName=funcNameList;
            bufFuncInfo.numbOfFunc = length(fullNameList);
            bufFuncInfo.inhFuncNameList =inheritedMethodList;
            bufFuncInfo.infoOfInhClass  = infoInhClass;
            possibleScript=regexp(fullNameList,scriptNamePattern,'once',...
            'match');
            bufFuncInfo.isScript=logical(cellfun(@(x,y) isequal(x,y),...
            fullNameList,possibleScript));
            bufFuncInfo.help=helpList;
            SFuncInfo=modgen.struct.unionstructsalongdim(1,SFuncInfo,...
            bufFuncInfo);
        end 
end
end




function SFuncInfo=extractHelpFromFunc(mPack)
   funcVec = mPack.FunctionList;
   funcNameList=arrayfun(@(x)x.Name,funcVec,'UniformOutput',false);
   funcVec = funcVec(~ignorMethodFlag);
   newFuncNameList=arrayfun(@(x)x.Name,funcVec,'UniformOutput',false);
   funcNameList = strcat(mPack.Name,'.',newFuncNameList);
   helpList=cellfun(@help,funcNameList,'UniformOutput',false);
   SFuncInfo.funcName=funcNameList;
   possibleScript=regexp(funcNameList,scriptNamePattern,'once','match');
   SFuncInfo.isScript=logical(cellfun(@(x,y) isequal(x,y),funcNameList,...
        possibleScript));
   SFuncInfo.help=helpList;
end



end

function [classList defClassList] = fMakeList(classNames)
nLength = length(classNames);
iQuantity = 1;
iDefQuantity = 1;
for iClass = 1:nLength
    if iscell(classNames{iClass})
        for jElem = 1:length(classNames{iClass})
          classList{iQuantity} = classNames{iClass}{jElem};
          defClassList{iDefQuantity} = classNames{iClass}{jElem};
          iQuantity = iQuantity + 1;
          iDefQuantity = iDefQuantity + 1;
        end
    end
    if ischar(classNames{iClass})
       classList{iQuantity} = classNames{iClass};
       iQuantity = iQuantity + 1;
    end
end
    
end


function result = fTransformData(funcInfo)
funcNameCell=funcInfo.funcName;
classNameCell = funcInfo.className;
numberOfFunctions = funcInfo.numbOfFunc;
defClassNameCell = funcInfo.defClassName;
inhFuncNameCell = funcInfo.inhFuncNameList;
infoOfInheritedFunctions = funcInfo.infoOfInhClass;
numberOfInheritedClasses = funcInfo.numbOfInhClasses;
isDefClass = ismember(classNameCell, defClassNameCell);
iSection = 0;
count = 0;
countFunctions = 0;
defFlag = 1;
iClass = 0;

for iElem = 1:length(classNameCell)
   if isDefClass(iElem) 
       count = count + 1;
       countFunctions = countFunctions + numberOfFunctions(iElem);
       if defFlag
           iSection = iSection + 1;
           iClass = iClass + 1;
           sectionNameCell{iSection} = classNameCell{iElem};
           bufDefClassNameCell{iClass} = classNameCell{iElem};
           defFlag = 0;
       end
   else 
      if (iElem ~= 1) & count
         nClass(iSection) = count;
         numberFunc(iSection) = countFunctions;
         count =0;
         countFunctions = 0;
      end
    defFlag = 1; 
    iSection = iSection + 1;
    sectionNameCell{iSection} = classNameCell{iElem};
    nClass(iSection) = 1;
    numberFunc(iSection) = numberOfFunctions(iElem);
    end
end
iIgnor = 1;
for iClass = 1:length(classNameCell)
    isConstructor =ismember(classNameCell{iClass}, sectionNameCell);
    if ~isConstructor
        ignorMethodList{iIgnor} = classNameCell{iClass};
        iIgnor = iIgnor + 1;
    end
end

for iMethod = 1:length(ignorMethodList)
    quantityDots =strfind(ignorMethodList{iMethod}, '.');
    str = ignorMethodList{iMethod};
    for iElem = 1:length(quantityDots)+1
      [startStr finishStr]= strtok(str, '.');
      str = finishStr;
    end
    ignorMethodList{iMethod} = startStr;
end

jBuf = 1;
for iClass = 1:length(bufDefClassNameCell)
    ind = find(strcmp(bufDefClassNameCell{iClass}, defClassNameCell));
    for jInd = 1:size(ind)
        finalDefClassNamecell{jBuf} = bufDefClassNameCell{iClass};
        jBuf = jBuf + 1;
    end
end

indClass = 1;
flag = 0;
for iClass = 1:size(numberOfInheritedClasses)
    quantity = numberOfInheritedClasses(iClass);
    if quantity > 1
        inhFuncbuf{iClass} = inhFuncNameCell{indClass};
        infoBuf(iClass) = infoOfInheritedFunctions(indClass);
        for jClass = indClass+1:indClass+quantity-1;
            inhFuncbuf{iClass} = union(inhFuncbuf{iClass},...
                inhFuncNameCell{jClass}); 
            infoBuf(iClass) = infoBuf(iClass) + ...
                infoOfInheritedFunctions(jClass);
        end
        flag = 1;
        indClass = jClass + 1;
    else
        if flag
            indClass = jClass + 1;
        else
            indClass = indClass + 1;
        end
        flag = 0;
        inhFuncbuf{iClass} = inhFuncNameCell{indClass};
        infoBuf(iClass) = infoOfInheritedFunctions(indClass);
    end

end

jNumb = 1;
finalFuncNameCell = unique(funcNameCell(1:numberFunc(jNumb)));
indFunc = numberFunc(jNumb) + 1;
finalNumberFunc(jNumb) = length(finalFuncNameCell);
for jNumb = 2:length(numberFunc)
    bufFuncNameCell = ...
        unique(funcNameCell(indFunc: numberFunc(jNumb)+ indFunc - 1));
    bufFuncNameCell = bufFuncNameCell(~ismember(bufFuncNameCell,...
               ignorMethodList));
    finalFuncNameCell = [finalFuncNameCell; bufFuncNameCell];
    finalNumberFunc(jNumb) = length(bufFuncNameCell);
    indFunc = indFunc + numberFunc(jNumb);
end


iHelp = 1;
helpCell = cell(length(finalFuncNameCell), 1);
indFunc = 1;
fullFuncName =  [sectionNameCell{1}, '.', finalFuncNameCell{1}];
for iSect = 1:length(sectionNameCell);
    className = sectionNameCell{iSect};
        for jFunc = indFunc:indFunc + finalNumberFunc(iSect) - 1
           fullFuncName  = [className, '.', finalFuncNameCell{jFunc}];
           bufFuncName = [className, '/', finalFuncNameCell{jFunc}];
           bufHelp = help(fullFuncName);
           bufHelp = fDeleteHelpStr(bufHelp, bufFuncName);
           helpCell{iHelp} = bufHelp;
           iHelp = iHelp + 1;
        end
        indFunc = indFunc + finalNumberFunc(iSect);
end
funcInfo.inhFuncNameList = inhFuncbuf';
funcInfo.infoOfInhClass = infoBuf';
funcInfo.defClassName = finalDefClassNamecell';
funcInfo.numbOfFunc = finalNumberFunc;
funcInfo.funcName = finalFuncNameCell;
funcInfo.help = helpCell;
result = funcInfo;
result.sectionName = sectionNameCell';
result.numbOfClass = nClass;
end

function result = fDeleteHelpStr(helpText, helpStr)
    indStartDel=strfind(helpText,sprintf('Help for %s', helpStr));
    helpText(indStartDel:end)=[];
    result = helpText;
end
