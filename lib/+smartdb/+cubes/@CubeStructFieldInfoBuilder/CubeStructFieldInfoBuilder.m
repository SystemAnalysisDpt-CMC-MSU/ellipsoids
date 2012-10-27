classdef CubeStructFieldInfoBuilder<modgen.common.obj.StaticPropStorage
    %CUBESTRUCTFIELDINFOBUILDER Summary of this class goes here
    %   Detailed explanation goes here
    %
    methods (Static,Access=private)
        function checkMetaProp(propName,propValList)
            import modgen.common.throwerror;
            if size(propValList,1)~=1||numel(propValList)~=length(propValList)
                throwerror('wrongInput',...
                    '%s is expected to be a row vector',propName);
            end
        end
    end
    methods (Static)
        function resArray=build()
            import modgen.common.throwerror;
            [cubeStructRef,isCubeStructRefSpec]=...
                smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                'cubeStructRef',true);
            %
            [nameList,isNameListSpec]=smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                'nameList',true);
            %
            [descrList,isDescrListSpec]=smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                'descrList',true);
            %
            [typeSpecList,isTypeSpecList]=smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                'typeSpecList',true);
            %
            [metaDataVec,isMetaDataSpec]=smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                'metaDataVec',true);
            %
            if isCubeStructRefSpec&&isNameListSpec
                if isMetaDataSpec&&...
                        ~isempty(intersect(nameList,...
                        metaDataVec.getNameList))
                    %
                        throwerror('wrongInput',...
                            ['when nameList specified along with metaData',...
                            ' it should not contain the names from metaData']);
                end
                inpArgList={'nameList',nameList};
                if isDescrListSpec
                    inpArgList=[inpArgList,{'descriptionList',descrList}];
                end
                if isTypeSpecList
                    inpArgList=[inpArgList,{'typeSpecList',typeSpecList}];
                end
                resArray=smartdb.cubes.CubeStructFieldInfo(...
                    cubeStructRef,inpArgList{:});
                if isMetaDataSpec
                    isNameListFirst=...
                        smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                        'isNameListFirst',false);
                    if isNameListFirst
                        resArray=[resArray,metaDataVec.clone(cubeStructRef)];
                    else
                        resArray=[metaDataVec.clone(cubeStructRef),resArray];
                    end
                end
                %
            elseif isCubeStructRefSpec&&~isNameListSpec&&...
                    ~isDescrListSpec&&~isTypeSpecList&&isMetaDataSpec
                %
                resArray=metaDataVec.clone(cubeStructRef);
                %
            elseif isCubeStructRefSpec&&~isNameListSpec&&...
                    ~isDescrListSpec&&~isTypeSpecList&&~isMetaDataSpec
                resArray=...
                    smartdb.cubes.CubeStructFieldInfo.defaultArray(...
                    cubeStructRef,[1 0]);
            else
                error([upper(mfilename),':badWayToBuild'],...
                    'unsupported way to build CubeStructFieldInfo array');
            end
        end
        %
        function setNameList(nameList)
            import modgen.common.throwerror;
            smartdb.cubes.CubeStructFieldInfoBuilder.setVecPropInternal(...
                'nameList',nameList);
            %
            [~,isThere]=...
                smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                'isNameListFirst',true);
            %
            if ~isThere
                smartdb.cubes.CubeStructFieldInfoBuilder.setPropInternal(...
                    'isNameListFirst',true);
            end
        end
        %
        function setDescrList(descrList)
           import modgen.common.throwerror;
           smartdb.cubes.CubeStructFieldInfoBuilder.setVecPropInternal(...
                'descrList',descrList);
        end
        %
        function setMetaDataVec(descrList)
            smartdb.cubes.CubeStructFieldInfoBuilder.setVecPropInternal(...
                'metaDataVec',descrList);
            [~,isThere]=...
                smartdb.cubes.CubeStructFieldInfoBuilder.getPropInternal(...
                'isNameListFirst',true);
            if ~isThere
                smartdb.cubes.CubeStructFieldInfoBuilder.setPropInternal(...
                    'isNameListFirst',false);
            end
        end        
        %
        function setTypeSpecList(typeSpecList)
            smartdb.cubes.CubeStructFieldInfoBuilder.setVecPropInternal(...
                'typeSpecList',typeSpecList);
        end
        %
        function setCubeStructRef(cubeStructRef)
            if numel(cubeStructRef)~=1
                error([upper(mfilename),':wrongInput'],...
                    'scalar CubeStruct object is expected');
            end
            smartdb.cubes.CubeStructFieldInfoBuilder.setPropInternal(...
                'cubeStructRef',cubeStructRef);
        end
        function flush()
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.flushInternal(branchName);
        end         
    end
    methods (Access=private,Static)
        function setVecPropInternal(propName,propVal)
            smartdb.cubes.CubeStructFieldInfoBuilder.checkMetaProp(...
                propName,propVal);              
            smartdb.cubes.CubeStructFieldInfoBuilder.setPropInternal(...
                propName,propVal);            
        end
    end
    methods (Access=protected,Static)
        function [propVal,isThere]=getPropInternal(propName,isPresenceChecked)
            branchName=mfilename('class');
            [propVal,isThere]=modgen.common.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,isPresenceChecked);
        end
        %
        function setPropInternal(propName,propVal)
            branchName=mfilename('class');
            modgen.common.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        %
    end
    
end
