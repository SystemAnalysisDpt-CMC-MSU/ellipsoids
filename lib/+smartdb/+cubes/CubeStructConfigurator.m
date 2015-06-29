classdef CubeStructConfigurator<modgen.common.obj.StaticPropStorage
    methods (Static)
        function isPositive=isOfStaticType(obj)
            isPositive=isa(obj,...
                'smartdb.relations.ATypifiedStaticRelation');
        end
        function isPositive=isOfAutoType(obj)
            isPositive=isa(obj,'smartdb.cubes.TypifiedStruct')||...
                isa(obj,'smartdb.relations.DynTypifiedRelation');
        end
        function setIsDebugMode(isDebugMode)
            smartdb.cubes.CubeStructConfigurator.setProp(...
                'isDebugMode',isDebugMode);
        end
        function isDebugMode=getIsDebugMode()
            [isDebugMode,isThere]=...
                smartdb.cubes.CubeStructConfigurator.getProp(...
                'isDebugMode',true);
            if ~isThere
                isDebugMode=false;
            end
        end
    end
    methods (Static,Access=private)
        function [propVal,isThere]=getProp(propName,varargin)
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,varargin{:});
        end
        function setProp(propName,propVal)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        function flush()
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
        end        
    end    
end
