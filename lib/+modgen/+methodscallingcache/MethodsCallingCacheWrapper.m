classdef MethodsCallingCacheWrapper<modgen.common.obj.StaticPropStorage
    % METHODSCALLINGCACHEWRAPPER is class that wraps around object of
    % MethodsCallingCache class so that the latter saves info on calling
    % methods of certain classes so that it is possible later to simulate
    % their calling without the code outside those classes; wrapping is
    % necessary to make the mentioned object of MethodsCallingCache
    % singleton, all the methods of this class copy the methods of
    % MethodsCallingCache and simply pass arguments to the latter methods

    
    %% Public methods
    
    methods (Static)
        function setMethodsCallingCache(methodsCallingCacheObj)
            % SETMETHODSCALLINGCACHE sets object that is able to cache
            % calling of methods of specific classes
            %
            % Usage: setMethodsCallingCache(methodsCallingCacheObj)
            %
            % input:
            %   regular:
            %     methodsCallingCacheObj: MethodsCallingCache [1,1] -
            %         object of caching class
            %
            % Created by Ilya Roublev, Allied Testing LLC (2011/11/18)
            %
            
            if ~(isa(methodsCallingCacheObj,...
                    'modgen.methodscallingcache.MethodsCallingCache')&&...
                    numel(methodsCallingCacheObj)==1),
                modgen.common.throwerror('wrongInput',...
                    'input should be object of MethodsCallingCache class');
            end
            feval([mfilename('class'), '.setPropInternal'],...
                'methodsCallingCacheObj',methodsCallingCacheObj);
        end
        %
        function setAllowCacheWithCallFromMethodList(varargin)
            [methodsCallingCacheObj,isMethodsCallingCacheObj]=...
                feval([mfilename('class'), '.getPropInternal'],...
                'methodsCallingCacheObj',true);
            if ~isMethodsCallingCacheObj,
                return;
            end
            methodsCallingCacheObj.setAllowCacheWithCallFromMethodList(varargin{:});
        end
        %
        function varargout=getAllowCacheWithCallFromMethodList()
            varargout={cell(0,1)};
            [methodsCallingCacheObj,isMethodsCallingCacheObj]=...
                feval([mfilename('class'), '.getPropInternal'],...
                'methodsCallingCacheObj',true);
            if ~isMethodsCallingCacheObj,
                return;
            end
            varargout{1}=methodsCallingCacheObj.getAllowCacheWithCallFromMethodList();
        end
        %
        function setOnlyClassesCached(varargin)
            [methodsCallingCacheObj,isMethodsCallingCacheObj]=...
                feval([mfilename('class'), '.getPropInternal'],...
                'methodsCallingCacheObj',true);
            if ~isMethodsCallingCacheObj,
                return;
            end
            methodsCallingCacheObj.setOnlyClassesCached(varargin{:});
        end
        %
        function put(varargin)
            [methodsCallingCacheObj,isMethodsCallingCacheObj]=...
                feval([mfilename('class'), '.getPropInternal'],...
                'methodsCallingCacheObj',true);
            if ~isMethodsCallingCacheObj,
                return;
            end
            methodsCallingCacheObj.put(varargin{:});
        end
        %
        function isOk=isClassObject(varargin)
            [methodsCallingCacheObj,isMethodsCallingCacheObj]=...
                feval([mfilename('class'), '.getPropInternal'],...
                'methodsCallingCacheObj',true);
            if ~isMethodsCallingCacheObj,
                isOk=false;
                return;
            end
            isOk=methodsCallingCacheObj.isClassObject(varargin{:});
        end
        %
        function flush()
            % FLUSH clears info set by setBuildFunction within storage
            %
            % Usage: flush()
            %
            % Created by Ilya Roublev, Allied Testing LLC (2011/11/18)
            %
            
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
       end         
    end
    
    %% Protected auxiliary methods 
    
    methods (Access=protected,Static)
        function [propVal,isThere]=getPropInternal(propName,isPresenceChecked)
            % GETPROPINTERNAL gets corresponding property from storage
            %
            % Usage: [propVal,isThere]=...
            %            getPropInternal(propName,isPresenceChecked)
            %
            % input:
            %   regular:
            %     propName: char - property name
            %     isPresenceChecked: logical [1,1] - if true, then presence
            %         of given property is checked before its value is
            %         retrieved from the storage, otherwise value is
            %         retrieved without any check (that may lead to error
            %         if property is not yet logged into the storage)
            % output:
            %   regular:
            %     propVal: empty or matrix of some type - value of given
            %         property in the storage (if it is absent, empty is
            %         returned)
            %   optional:
            %     isThere: logical [1,1] - if true, then property is in the
            %         storage, otherwise false
            %
            % Created by Ilya Roublev, Allied Testing LLC (2010/03/12)
            %
            
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,isPresenceChecked);
        end
        %
        function setPropInternal(propName,propVal)
            % SETPROPINTERNAL sets value for corresponding property within
            % storage
            %
            % Usage: setPropInternal(propName,propVal)
            %
            % input:
            %   regular:
            %     propName: char - property name
            %     propVal: matrix of some type - value of given property to
            %         be set in the storage
            %
            % Created by Ilya Roublev, Allied Testing LLC (2010/03/12)
            %
            
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        %
    end
end