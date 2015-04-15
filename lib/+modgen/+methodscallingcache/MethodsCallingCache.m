classdef MethodsCallingCache<handle
    % METHODSCALLINGCACHE is class that saves info on calling methods of
    % certain classes so that it is possible later to simulate their
    % calling without the code outside those classes

    properties (Access=private,Hidden)
        classNameList
        superClassNameList
        allowCacheWithCallFromMethodList
        stackRelDepth
        classObjCacheCVec
        methodCallCacheVec
        onlyClassesCached
    end
    
    methods
        function self=MethodsCallingCache(varargin)
            [~,~,includeNameList,excludeNameList,...
                self.allowCacheWithCallFromMethodList,...
                self.stackRelDepth]=...
                modgen.common.parseparext(varargin,{...
                'includePackageOrClassNameList',...
                'excludePackageOrClassNameList',...
                'allowCacheWithCallFromMethodList',...
                'stackRelDepth';...
                cell(1,0),cell(1,0),cell(1,0),0;...
                'iscellofstring(x)','iscellofstring(x)',...
                'iscellofstring(x)',...
                'isscalar(x)&&isnumeric(x)&&isreal(x)'},...
                0,'propRetMode','separate');
            self.stackRelDepth=double(self.stackRelDepth);
            modgen.common.checkvar(self.stackRelDepth,...
                'isfinite(x)&&floor(x)==x&&x>=0','stackRelDepth');
            self.classNameList=reshape(setdiff(...
                getclassnamelist(includeNameList),...
                getclassnamelist(excludeNameList)),[],1);
            nClasses=numel(self.classNameList);
            classNameCVec=cell(nClasses,1);
            for iClass=1:nClasses,
                classNameCVec{iClass}=superclasses(self.classNameList{iClass});
            end
            self.superClassNameList=unique(vertcat(self.classNameList,...
                classNameCVec{:}));
            self.init();
            
            function curClassNameList=getclassnamelist(packageOrClassNameList)
                nElems=numel(packageOrClassNameList);
                curClassNameList=cell(nElems,1);
                for iElem=1:nElems,
                    curClassNameList{iElem}=getsubclassnamelist(...
                        packageOrClassNameList{iElem});
                end
                curClassNameList=vertcat(curClassNameList{:});
                
                function curClassNameList=getsubclassnamelist(packageOrClassName)
                    curClassNameList=cell(0,1);
                    if isa(packageOrClassName,'meta.package'),
                        metaPackageObj=packageOrClassName;
                    else
                        metaPackageObj=meta.package.fromName(packageOrClassName);
                    end
                    if isempty(metaPackageObj),
                        if isa(packageOrClassName,'meta.class'),
                            metaClassNameObj=packageOrClassName;
                        else
                            metaClassNameObj=meta.class.fromName(packageOrClassName);
                        end
                        if ~isempty(metaClassNameObj),
                            curClassNameList={metaClassNameObj.Name};
                        end
                    else
                        nPackages=numel(metaPackageObj.PackageList);
                        curClassNameCVec=cell(nPackages,1);
                        for iPackage=1:nPackages,
                            curClassNameCVec{iPackage}=...
                                getsubclassnamelist(...
                                metaPackageObj.PackageList(iPackage));
                        end
                        curClassNameCVec{nPackages+1}=...
                            arrayfun(@(x)x.Name,metaPackageObj.ClassList,...
                            'UniformOutput',false);
                        curClassNameList=vertcat(curClassNameCVec{:});
                    end
                end
            end
        end
        
        function init(self,initMethodCallCacheVec)
            methodCacheFieldNameList={...
                'className','methodName','isStatic','inpArgList','nOutArgs'};
            if nargin<2,
                inpCVec=[methodCacheFieldNameList(:) ...
                    repmat({cell(0,1)},numel(methodCacheFieldNameList),1)].';
                initMethodCallCacheVec=struct(inpCVec{:});
            else
                isnWrong=isstruct(initMethodCallCacheVec)&&...
                    numel(initMethodCallCacheVec)==...
                    length(initMethodCallCacheVec);
                if isnWrong,
                    initMethodCallCacheVec=initMethodCallCacheVec(:);
                    fieldNameList=fieldnames(initMethodCallCacheVec);
                    isnWrong=numel(fieldNameList)==...
                        numel(methodCacheFieldNameList)&&...
                        all(ismember(fieldNameList,methodCacheFieldNameList));
                end
                if ~isnWrong,
                    modgen.common.throwerror('wrongInput',...
                        'initMethodCallCacheVec has wrong format');
                end
            end
            self.classObjCacheCVec=cell(0,1);
            self.methodCallCacheVec=initMethodCallCacheVec;
            self.onlyClassesCached=false;
        end
        
        function resVec=getMethodCallCache(self)
            resVec=self.methodCallCacheVec;
        end
        
        function isOk=isClassObject(self,inpObj)
            isOk=isobject(inpObj);
            if isOk,
                isOk=any(strcmp(class(inpObj),self.classNameList));
            end
        end
        
        function setAllowCacheWithCallFromMethodList(self,methodList)
            self.allowCacheWithCallFromMethodList=methodList;
        end
        
        function methodList=getAllowCacheWithCallFromMethodList(self)
            methodList=self.allowCacheWithCallFromMethodList;
        end
        
        function setOnlyClassesCached(self,isCached)
            self.onlyClassesCached=isCached;
        end
        
        function put(self,inpArgList,outArgList)
            StFunc=dbstack('-completenames');
            if numel(StFunc)<=2+self.stackRelDepth,
                return;
            end
            [methodName,className]=modgen.common.parsestackelem(StFunc(2+self.stackRelDepth));
            if any(methodName=='\'|methodName=='/'),
                return;
            end
            metaObj=meta.class.fromName(className);
            indMethod=find(strcmp(methodName,...
                {metaObj.MethodList.Name}),1,'first');
            isStatic=metaObj.MethodList(indMethod).Static;
            if ~isStatic,
                if strcmp(fliplr(strtok(fliplr(className),'.')),...
                        methodName),
                    methodName=className;
                else
                    className=class(inpArgList{1});
                end
            end
            if ~any(strcmp(className,self.classNameList)),...
                return;
            end
            for indStack=3+self.stackRelDepth:numel(StFunc),
                [callMethodName,callClassName]=modgen.common.parsestackelem(StFunc(indStack));
                if any(strcmp(callMethodName,...
                        self.allowCacheWithCallFromMethodList)),
                    continue;
                end
                if any(strcmp(callClassName,self.superClassNameList)),
                    return;
                end
            end
            inpArgList=self.processArgList(inpArgList,true);
            if nargin>=3,
                self.processArgList(outArgList);
                nOutArgs=numel(outArgList);
            else
                nOutArgs=0;
            end
            if self.onlyClassesCached,
                methodName='getField';
            end
            self.methodCallCacheVec=vertcat(...
                self.methodCallCacheVec,struct(...
                'className',{className},...
                'methodName',{methodName},...
                'isStatic',{isStatic},...
                'inpArgList',{inpArgList},...
                'nOutArgs',{nOutArgs}));
        end
        
        function play(self)
            self.classObjCacheCVec=cell(0,1);
            nMethods=numel(self.methodCallCacheVec);
            for iMethod=1:nMethods,
                methodCallCache=self.methodCallCacheVec(iMethod);
                if methodCallCache.isStatic,
                    methodName=[methodCallCache.className '.'...
                        methodCallCache.methodName];
                else
                    methodName=methodCallCache.methodName;
                end
                inpCVec=self.processArgList(...
                    methodCallCache.inpArgList,false);
                if methodCallCache.nOutArgs>0,
                    outCVec=cell(1,methodCallCache.nOutArgs);
                    [outCVec{:}]=feval(methodName,inpCVec{:});
                    self.processArgList(outCVec);
                else
                    feval(methodName,inpCVec{:});
                end
            end
        end
    end
    
    methods (Access=protected,Sealed)
        function argList=processArgList(self,argList,isReal2Substitute)
            if nargin<3,
                isReal2Substitute=true;
            end
            isMakeSubstitution=nargout>0;
            nArgs=numel(argList);
            for iArg=1:nArgs,
                curVal=argList{iArg};
                isObjVecToPut=false;
                if isCachedClass(curVal),
                    if isMakeSubstitution,
                        curVal=makeSubstitution(curVal);
                    else
                        isObjVecToPut=true;
                        objMat=curVal;
                    end
                elseif iscell(curVal),
                    if all(cellfun('isclass',curVal,'cell')),
                        nElems=numel(curVal);
                        curCVec=curVal;
                        objCVec=cell(nElems,1);
                        for iElem=1:nElems,
                            curVal=curCVec{iElem};
                            isClassVec=isCachedClassCell(curVal);
                            if any(isClassVec),
                                if isMakeSubstitution,
                                    curVal(isClassVec)=cellfun(@makeSubstitution,...
                                        curVal(isClassVec),'UniformOutput',false);
                                else
                                    isObjVecToPut=true;
                                    objCVec{iElem}=reshape(curVal(isClassVec),[],1);
                                end
                            end
                            curCVec{iElem}=curVal;
                        end
                        if isMakeSubstitution,
                            curVal=curCVec;
                        end
                        if isObjVecToPut,
                            objMat=vertcat(objCVec{:});
                        end
                    else
                        isClassVec=isCachedClassCell(curVal);
                        if any(isClassVec),
                            if isMakeSubstitution,
                                curVal(isClassVec)=cellfun(@makeSubstitution,...
                                    curVal(isClassVec),'UniformOutput',false);
                            else
                                isObjVecToPut=true;
                                objMat=curVal(isClassVec);
                            end
                        end
                    end
                elseif isstruct(curVal)&&numel(curVal)==1,
                    fieldNameCVec=fieldnames(curVal);
                    fieldValCVec=struct2cell(curVal);
                    nFields=numel(fieldNameCVec);
                    objMat=cell(nFields,1);
                    isChanged=false;
                    for iField=1:nFields,
                        fieldVal=fieldValCVec{iField};
                        if isCachedClass(fieldVal),
                            if isMakeSubstitution,
                                isChanged=true;
                                fieldValCVec{iField}=makeSubstitution(...
                                    fieldVal);
                            else
                                isObjVecToPut=true;
                                objMat{iField}={fieldVal};
                            end
                        elseif iscell(fieldVal),
                            if all(cellfun('isclass',fieldVal,'cell')),
                                nElems=numel(fieldVal);
                                curCVec=fieldVal;
                                objCVec=cell(nElems,1);
                                for iElem=1:nElems,
                                    fieldVal=curCVec{iElem};
                                    isClassVec=isCachedClassCell(curVal);
                                    if any(isClassVec),
                                        if isMakeSubstitution,
                                            fieldVal(isClassVec)=cellfun(@makeSubstitution,...
                                                fieldVal(isClassVec),'UniformOutput',false);
                                        else
                                            isObjVecToPut=true;
                                            objCVec{iElem}=reshape(fieldVal(isClassVec),[],1);
                                        end
                                    end
                                    curCVec{iElem}=fieldVal;
                                end
                                if isMakeSubstitution,
                                    fieldValCVec{iField}=curCVec;
                                end
                                if isObjVecToPut,
                                    objMat{iField}=vertcat(objCVec{:});
                                end
                            else
                                isClassVec=isCachedClassCell(fieldVal);
                                if any(isClassVec),
                                    if isMakeSubstitution,
                                        isChanged=true;
                                        fieldVal(isClassVec)=cellfun(...
                                            @makeSubstitution,...
                                            fieldVal(isClassVec),...
                                            'UniformOutput',false);
                                        fieldValCVec{iField}=fieldVal;
                                    else
                                        isObjVecToPut=true;
                                        objMat{iField}=reshape(...
                                            fieldVal(isClassVec),[],1);
                                    end
                                end
                            end
                        end
                    end
                    if isChanged,
                        inpCVec=[fieldNameCVec(:) num2cell(fieldValCVec(:))].';
                        curVal=struct(inpCVec{:});
                    end
                    if isObjVecToPut,
                        objMat=vertcat(objMat{:});
                    end
                end
                if isMakeSubstitution,
                    argList{iArg}=curVal;
                end
                if isObjVecToPut,
                    self.cacheClassObjMat(objMat);
                end
            end
            
            function resVal=makeSubstitution(curVal)
                if isReal2Substitute,
                    resVal=modgen.methodscallingcache.ClassSubstitute(...
                        self.getCacheIndMat(curVal));
                else
                    if numel(curVal)~=1,
                        modgen.common.throwerror('wrongObjState',[...
                            'Cache is wrong, object of ClassSubstitute '...
                            'must be scalar even for object array']);
                    end
                    resVal=curVal.idMat;
                    if numel(self.classObjCacheCVec)<max(resVal(:)),
                        modgen.common.throwerror('wrongObjState',[...
                            'Cache is wrong, not all objects '...
                            'corresponding to object of ClassSubstitute '...
                            'are already calculated']);
                    end
                    resVal=reshape(self.classObjCacheCVec(resVal),[],1);
                    if numel(resVal)>1,
                        if numel(unique(cellfun(@class,resVal,'UniformOutput',false)))>1,
                            modgen.common.throwerror('wrongObjState',[...
                                'Cache is wrong, all objects '...
                                'corresponding to object of ClassSubstitute '...
                                'must be of the same class']);
                        end
                    end
                    resVal=reshape(vertcat(resVal{:}),size(curVal.idMat));
                end
            end
            
            function isOk=isCachedClass(valMat)
                isOk=isobject(valMat);
                if isOk,
                    if isReal2Substitute,
                        isOk=any(strcmp(class(valMat),self.classNameList));
                    else
                        isOk=isa(valMat,'modgen.methodscallingcache.ClassSubstitute');
                    end
                end
            end
            
            function isOkVec=isCachedClassCell(valCMat)
                if isReal2Substitute,
                    isOkVec=cellfun(@(x)any(strcmp(class(x),self.classNameList)),...
                        valCMat(:));
                else
                    isOkVec=cellfun('isclass',valCMat(:),...
                        'modgen.methodscallingcache.ClassSubstitute');
                end
            end
        end
        
        function indMat=getCacheIndMat(self,objMat)
            nElems=numel(objMat);
            indMat=zeros(size(objMat));
            nCacheElems=numel(self.classObjCacheCVec);
            for iElem=1:nElems,
                indMat(iElem)=getCacheInd(objMat(iElem),nCacheElems);
            end
            if any(indMat(:)==0),
                modgen.common.throwerror('wrongObjState',[...
                    'Some objects are not cached, it is necessary '...
                    'to add calls of put method into constructors']);
            end
            
            function ind=getCacheInd(obj,nCacheElems)
                ind=0;
                for iCacheElem=nCacheElems:-1:1,
                    if isequaln(obj,self.classObjCacheCVec{iCacheElem}),
                        ind=iCacheElem;
                        break;
                    end
                end
            end
        end
        
        function cacheClassObjMat(self,objMat)
            objMat=objMat(:);
            if iscell(objMat),
                objMat(cellfun('isempty',objMat))=[];
                if isempty(objMat),
                    return;
                end
                isnScalarVec=cellfun('prodofsize',objMat)>1;
                if any(isnScalarVec),
                    objMat(isnScalarVec)=cellfun(@(x)num2cell(x(:)),...
                        objMat(isnScalarVec),'UniformOutput',false);
                    if ~all(isnScalarVec),
                        objMat(~isnScalarVec)=cellfun(@(x){x},...
                            objMat(~isnScalarVec),'UniformOutput',false);
                    end
                    objMat=vertcat(objMat{:});
                end
            else
                objMat=num2cell(objMat);
            end
            self.classObjCacheCVec=vertcat(...
                self.classObjCacheCVec,objMat);
        end
    end
    
    methods (Static)
        function [classObjList,indCallVec,methodCallCacheVec]=extractClassObjectsFromCache(methodCallCacheVec)
            classObjList=cell(0,1);
            nClasses=0;
            indCallVec=nan(0,1);
            isMakeSubstitution=nargout>2;
            methodCacheFieldNameList={...
                'className','methodName','isStatic','inpArgList','nOutArgs'};
            isnWrong=isstruct(methodCallCacheVec)&&...
                numel(methodCallCacheVec)==...
                length(methodCallCacheVec);
            if isnWrong,
                methodCallCacheVec=methodCallCacheVec(:);
                fieldNameList=fieldnames(methodCallCacheVec);
                isnWrong=numel(fieldNameList)==...
                    numel(methodCacheFieldNameList)&&...
                    all(ismember(fieldNameList,methodCacheFieldNameList));
            end
            if ~isnWrong,
                modgen.common.throwerror('wrongInput',...
                    'methodCallCacheVec has wrong format');
            end
            nMethods=numel(methodCallCacheVec);
            for iMethod=1:nMethods,
                inpArgList=methodCallCacheVec(iMethod).inpArgList;
                nArgs=numel(inpArgList);
                for iArg=1:nArgs,
                    curVal=inpArgList{iArg};
                    if isnSubsObject(curVal),
                        curInd=getObjectInd(curVal,iMethod);
                        if isMakeSubstitution,
                            curVal=makeSubstitution(curInd);
                        end
                    elseif iscell(curVal),
                        isClassVec=cellfun(@isnSubsObject,curVal);
                        if any(isClassVec),
                            curIndCVec=cellfun(@(x)getObjectInd(x,iMethod),...
                                curVal(isClassVec),'UniformOutput',false);
                            if isMakeSubstitution,
                                curVal(isClassVec)=cellfun(...
                                    @makeSubstitution,...
                                    curIndCVec,'UniformOutput',false);
                            end
                        end
                    elseif isstruct(curVal)&&numel(curVal)==1,
                        fieldNameCVec=fieldnames(curVal);
                        fieldValCVec=struct2cell(curVal);
                        nFields=numel(fieldNameCVec);
                        isChanged=false;
                        for iField=1:nFields,
                            fieldVal=fieldValCVec{iField};
                            if isnSubsObject(fieldVal),
                                curInd=getObjectInd(fieldVal,iMethod);
                                if isMakeSubstitution,
                                    isChanged=true;
                                    fieldValCVec{iField}=...
                                        makeSubstitution(curInd);
                                end
                            elseif iscell(fieldVal),
                                isClassVec=cellfun(@isnSubsObject,fieldVal);
                                if any(isClassVec),
                                    curIndCVec=cellfun(@(x)getObjectInd(x,iMethod),...
                                        fieldVal(isClassVec),'UniformOutput',false);
                                    if isMakeSubstitution,
                                        isChanged=true;
                                        fieldVal(isClassVec)=cellfun(...
                                            @makeSubstitution,...
                                            curIndCVec,...
                                            'UniformOutput',false);
                                        fieldValCVec{iField}=fieldVal;
                                    end
                                end
                            end
                        end
                        if isChanged,
                            inpCVec=[fieldNameCVec(:) num2cell(fieldValCVec(:))].';
                            curVal=struct(inpCVec{:});
                        end
                    end
                    if isMakeSubstitution,
                        inpArgList{iArg}=curVal;
                    end
                end
                if isMakeSubstitution,
                    methodCallCacheVec(iMethod).inpArgList=inpArgList;
                end
            end
            
            function ind=getObjectInd(objMat,indCall)
                classObjList=vertcat(classObjList,{objMat});
                indCallVec=vertcat(indCallVec,indCall);
                nClasses=nClasses+1;
                ind=nClasses;
            end
            
            function isOk=isnSubsObject(objMat)
                isOk=isobject(objMat)&&...
                    ~isa(objMat,'modgen.methodscallingcache.ClassSubstitute');
            end
            
            function obj=makeSubstitution(ind)
                if isobject(ind),
                    obj=ind;
                else
                    obj=modgen.methodscallingcache.ClassSubstitute(-ind);
                end
            end
        end
    end
end