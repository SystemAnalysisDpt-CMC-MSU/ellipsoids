classdef StaticPropStorage<handle
    methods (Static,Access=private)
        function [propVal,isThere]=setGetProp(isFlushed,...
                isPresenceChecked,branchName,propName,propVal)
            persistent branchStorage;
            if isempty(branchStorage)
                branchStorage=containers.Map;
            end
            if nargin>2
                if ~branchStorage.isKey(branchName) || isFlushed
                    branchStorage(branchName)=containers.Map();                    
                end
                if nargin>4
                    propStorage=branchStorage(branchName);
                    propStorage(propName)=propVal;
                end
            end
            if nargout>0
                try
                    propStorage=branchStorage(branchName);                    
                    if nargout>1&&isPresenceChecked
                        isThere=propStorage.isKey(propName);
                        if isThere
                            propVal=propStorage(propName);
                        else
                            propVal=[];
                        end
                    else
                        propVal=propStorage(propName);
                        isThere=true;
                    end
                catch meObj
                    if ~isempty(findstr(':NoKey',meObj.identifier))
                    	newMeObj=MException([upper(mfilename),':noProp'],...
                            'property %s is missing',propName);
                        newMeObj=addCause(newMeObj,meObj);
                        throw(newMeObj);
                    else
                        rethrow(meObj);
                    end
                end
            end
        end
    end
    
    methods (Static,Access=protected)
        function [propVal,isThere]=getPropInternal(branchName,propName,...
                isPresenceChecked)
            if nargin<3
                isPresenceChecked=false;
            end
            [propVal,isThere]=...
                modgen.common.obj.StaticPropStorage.setGetProp(...
                false,isPresenceChecked,branchName,propName);
        end
        function setPropInternal(branchName,propName,propVal)
            modgen.common.obj.StaticPropStorage.setGetProp(...
                false,false,branchName,propName,propVal);
        end
        function flushInternal(branchName)
            modgen.common.obj.StaticPropStorage.setGetProp(true,false,...
                branchName);
        end
    end
    
end
