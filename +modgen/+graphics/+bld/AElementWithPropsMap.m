classdef AElementWithPropsMap<handle
    % This class is an analogue of containers.Map class save, first,
    % that keys are objects of classes inherited from AElemenentWithProps,
    % and, second, that all the map is filled in constructor, so that no
    % modification of this map is permitted
    
    properties (Access=protected)
        classMap=containers.Map('UniformValues',false);
    end
    
    properties (Access=private)
        valueType=[];
    end
    
    methods (Abstract,Access=protected,Static)
        [isValueVec,valueVec]=getValueVec(sizeVec,varargin)
    end
    
    methods
        function self=AElementWithPropsMap(keyCVec,varargin)
            [keyCVec,classNameCVec,indClassVec]=self.checkKeyCVec(keyCVec);
            [isValueVec,valueVec]=self.getValueVec(size(keyCVec),varargin{:});
            if isValueVec,
                self.valueType=class(valueVec);
                if ~iscell(valueVec),
                    valueVec=num2cell(valueVec,2);
                end
            end
            nClasses=numel(classNameCVec);
            curClassMap=containers.Map('UniformValues',false);
            for iClass=1:nClasses,
                isClassVec=indClassVec==iClass;
                if isValueVec,
                    curClassMap(classNameCVec{iClass})=[...
                        reshape(keyCVec(isClassVec),[],1)...
                        reshape(valueVec(isClassVec),[],1)];
                else
                    curClassMap(classNameCVec{iClass})=...
                        reshape(keyCVec(isClassVec),[],1);
                end
            end
            self.classMap=curClassMap;
        end
        
        function isVec=isKey(self,keyCVec)
            [keyCVec,classNameCVec,indClassVec]=self.checkKeyCVec(keyCVec);
            nClasses=numel(classNameCVec);
            isVec=false(size(keyCVec));
            for iClass=1:nClasses,
                isClassVec=indClassVec==iClass;
                isVec(isClassVec)=self.getInternal(...
                    classNameCVec{iClass},keyCVec(isClassVec));
            end
        end
        
        function res=isempty(self)
            res=self.classMap.isempty();
        end
        
        function keyCVec=keys(self)
            if self.isempty(),
                keyCVec=cell(0,1);
            else
                mapCMat=values(self.classMap);
                mapCMat=vertcat(mapCMat{:});
                keyCVec=mapCMat(:,1);
            end
        end
        
%         function len=length(self)
%             if self.isempty(),
%                 len=0;
%             else
%                 len=sum(cellfun('size',self.classMap.values,1));
%             end
%         end
%         
%         function varargout=size(self)
%             nDims=nargout;
%             if nDims>1,
%                 varargout{1}=self.length();
%                 varargout(2:nDims)={1};
%             else
%                 varargout={[self.length() 1]};
%             end
%         end
        
        function keyCVec=getKeysForType(self,className)
            keyCVec=self.keys();
            if ~isempty(keyCVec),
                keyCVec=keyCVec(self.isKeysOfType(keyCVec,className));
            end
        end
        
        function value=getValue(self,keyObj)
            [isOk,value]=self.getInternal(class(keyObj),{keyObj});
            if ~isOk,
                modgen.common.throwerror('wrongInput',...
                    'Given object is not in the map as a key');
            end
        end
        
%         function varargout=subsref(self,StSubs)
%             [isKeyGiven,keyObj]=self.checkStSubs(StSubs);
%             if isKeyGiven,
%                 varargout=cell(1,1);
%                 [isOk,varargout{1}]=self.getInternal(class(keyObj),{keyObj});
%                 if ~isOk,
%                     modgen.common.throwerror('wrongInput',...
%                         'Given object is not in the map as a key');
%                 end
%             else
%                 varargout=cell(1,nargout);
%                 [varargout{:}] = builtin('subsref',self,StSubs);
%             end
%         end
        
        function valueVec=values(self)
            if self.isempty(),
                if strcmp(self.valueType,'cell'),
                    valueVec=cell(0,1);
                else
                    valueVec=modgen.common.type.createarray(...
                        self.valueType,[0 1]);
                end
            else
                mapCMat=values(self.classMap);
                mapCMat=vertcat(mapCMat{:});
                valueVec=mapCMat(:,2);
                if ~strcmp(self.valueType,'cell'),
                    valueVec=vertcat(valueVec{:});
                end
            end
        end
        
        function [keyCVec,valueVec]=getMapPairsRestrictedOnKeys(self,keyCVec)
            isKeys=nargin>1;
            if isKeys,
                [keyCVec,classNameCVec,indClassVec]=self.checkKeyCVec(keyCVec);
            else
                keyCVec=self.keys();
            end
            if self.isempty(),
                keyCVec=cell(1,0);
                valueVec=self.values();
            else
                if ~isKeys,
                    [keyCVec,classNameCVec,indClassVec]=self.checkKeyCVec(keyCVec);
                end
                keyCVec=keyCVec(:);
                nClasses=numel(classNameCVec);
                isVecCVec=cell(nClasses,1);
                valueVecCVec=cell(nClasses,1);
                for iClass=1:nClasses,
                    isClassVec=indClassVec==iClass;
                    [isVecCVec{iClass},valueVecCVec{iClass}]=...
                        self.getInternal(classNameCVec{iClass},...
                        keyCVec(isClassVec));
                end
                isVec=vertcat(isVecCVec{:});
                valueVec=vertcat(valueVecCVec{:});
                keyCVec=keyCVec(isVec);
                valueVec=valueVec(isVec);
            end
        end
    end
    
    methods (Access=protected,Sealed)
        function varargout=getInternal(self,className,keyCVec)
            varargout=cell(1,nargout);
            isValueVec=nargout>1;
            if isValueVec&&isempty(self.valueType),
                modgen.common.throwerror('wrongObjState',...
                    'There is no values given for class %s',class(self));
            end
            sizeVec=size(keyCVec);
            isVec=false(sizeVec);
            if isValueVec,
                if strcmp(self.valueType,'cell'),
                    valueVec=cell(sizeVec);
                else
                    valueVec=modgen.common.type.createarray(...
                        self.valueType,sizeVec);
                end
            end
            if self.classMap.isKey(className),
                mapCMat=self.classMap(className);
                if isValueVec,
                    [isVec(:),indVec]=ismemberobjinternal(keyCVec(:),...
                        mapCMat(:,1));
                    if iscell(valueVec),
                        valueVec(isVec)=mapCMat(indVec(isVec),2);
                    else
                        valueVec(isVec)=vertcat(mapCMat{indVec(isVec),2});
                    end
                    varargout{2}=valueVec;
                else
                    isVec(:)=ismemberobjinternal(keyCVec(:),mapCMat(:,1));
                end
            end
            varargout{1}=isVec;
        end
    end
    
    methods (Static,Sealed)
        function isTypeVec=isKeysOfType(keyCVec,className)
            isTypeVec=cellfun(@(x)isa(x,className),keyCVec);
        end
        
    end
    
    methods (Access=protected,Static,Sealed)
        function [keyCVec,classNameCVec,indClassVec]=checkKeyCVec(keyCVec)
            if ~iscell(keyCVec),
                keyCVec={keyCVec};
            end
            modgen.common.checkvar(keyCVec,...
                'isvector(x)&&~isempty(x)');
            modgen.common.checkvar(keyCVec,['all('...
                'cellfun(''prodofsize'',x)==1&'...
                'cellfun(@(y)isa(y,'...
                '''modgen.graphics.bld.AElementWithProps''),x))']);
            if nargout>1,
                [classNameCVec,~,indClassVec]=unique(cellfun(@class,keyCVec,...
                    'UniformOutput',false));
            end
        end
        
        function [isKeyGiven,keyObj]=checkStSubs(StSubs)
            keyObj=[];
            modgen.common.checkvar(StSubs,'isstruct(x)');
            modgen.common.checkvar(StSubs,[...
                'numel(fieldnames(x))==2&&'...
                'isfield(x,''type'')&&isfield(x,''subs'')']);
            isKeyGiven=numel(StSubs)==1&&...
                strcmp(StSubs.type,'()')&&...
                iscell(StSubs.subs)&&numel(StSubs.subs)==1;
            if isKeyGiven,
                keyObj=StSubs.subs{:};
            end
        end
    end
end