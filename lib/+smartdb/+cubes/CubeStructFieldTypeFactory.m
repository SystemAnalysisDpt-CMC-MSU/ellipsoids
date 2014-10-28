classdef CubeStructFieldTypeFactory
    methods (Access=private,Static)
        function className=getClassName(cubeStructRef)
            if smartdb.cubes.CubeStructConfigurator.isOfStaticType(...
                    cubeStructRef)
                className='smartdb.cubes.CubeStructFieldStaticType';
            elseif smartdb.cubes.CubeStructConfigurator.isOfAutoType(...
                    cubeStructRef)
                className='smartdb.cubes.CubeStructFieldStaticAutoType';
            else
                className='smartdb.cubes.CubeStructFieldDynamicType';
            end                
        end
    end
    methods (Static,Access=private)
        function cubeStructRefList=processCubeStructRefList(sizeVec,cubeStructRefList)
            if ~iscell(cubeStructRefList)
                cubeStructRefList={cubeStructRefList};
                cubeStructRefList=cubeStructRefList(ones(sizeVec));
            end
        end
        function objArray=uninitializedArray(cubeStructRef,sizeVec)
            if ~isempty(cubeStructRef)&&(prod(sizeVec)~=0)
                cubeStructRefList=smartdb.cubes.CubeStructFieldTypeFactory.processCubeStructRefList(...
                    sizeVec,cubeStructRef);
            else
                cubeStructRefList=cubeStructRef.empty(sizeVec);
            end
            objArray=smartdb.cubes.CubeStructFieldTypeFactory.fromCubeStructRefList(cubeStructRefList);
        end
    end
    methods (Static)
        function objArray=defaultArray(cubeStructRef,sizeVec)
            objArray=smartdb.cubes.CubeStructFieldTypeFactory.uninitializedArray(cubeStructRef,sizeVec);
            objArray=objArray.setDefault();
        end
        %
        function obj=fromClassName(cubeStructRef,className)
            obj=smartdb.cubes.CubeStructFieldTypeFactory.fromClassNameArray(cubeStructRef,{className});
        end
        %
        function objArray=fromClassNameArray(cubeStructRef,classNameArray)
            import modgen.common.throwerror;
            if numel(cubeStructRef)>1
                throwerror('wrongInput',...
                    'method is not supported for a vectorial value of cubeStructRef');
            end
            sizeVec=size(classNameArray);
            objArray=smartdb.cubes.CubeStructFieldTypeFactory.uninitializedArray(cubeStructRef,sizeVec);
            objArray=objArray.setValueTypeBySpec(classNameArray);
        end
    end    
    methods (Static)
        function resObj=clone(cubeStructRef,obj)
            resObj=feval(...
                smartdb.cubes.CubeStructFieldTypeFactory.getClassName(cubeStructRef),...
                obj,cubeStructRef);
        end
%         function resObj=fromClassName(cubeStructRef,varargin)
%             resObj=feval(...
%                 [smartdb.cubes.CubeStructFieldTypeFactory.getClassName(cubeStructRef),...
%                 '.fromClassName'],cubeStructRef,...
%                 varargin{:});
%         end
%         function resObj=fromClassNameArray(cubeStructRef,varargin)
%             resObj=feval(...
%                 [smartdb.cubes.CubeStructFieldTypeFactory.getClassName(cubeStructRef),...
%                 '.fromClassNameArray'],cubeStructRef,...
%                 varargin{:});
%         end        
%         function resObj=defaultArray(cubeStructRef,varargin)
%             resObj=feval(...
%                 [smartdb.cubes.CubeStructFieldTypeFactory.getClassName(cubeStructRef),...
%                 '.defaultArray'],cubeStructRef,...
%                 varargin{:});
%         end
        function resObj=fromCubeStructRefList(cubeStructRefList)
            if iscell(cubeStructRefList)
                if numel(cubeStructRefList)<1
                    error([upper(mfilename),':wrongInput'],...
                        'cannot infer CubeStruct class');
                end
                
                className=smartdb.cubes.CubeStructFieldTypeFactory.getClassName(cubeStructRefList{1});
            else
                className=smartdb.cubes.CubeStructFieldTypeFactory.getClassName(cubeStructRefList);
            end
            resObj=feval(className,cubeStructRefList);
        end
    end
end
