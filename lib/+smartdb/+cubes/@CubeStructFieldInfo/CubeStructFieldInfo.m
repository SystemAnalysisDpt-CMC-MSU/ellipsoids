classdef CubeStructFieldInfo<modgen.common.obj.HandleObjectCloner
    % CUBESTRUCTFIELDINFO is a container for an information about CubeStruct
    % sfield
    %
    %
    % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-06-25 $ 
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department 2012 $
    %
    %
    properties (Constant,GetAccess=private,Hidden)
        TYPE_FIELD_TYPE_NAME='smartdb.cubes.ACubeStructFieldType';
        CUBE_STRUCT_TYPE_NAME='smartdb.cubes.CubeStruct';
    end
    properties (Access=protected,Hidden)
        %
        name=''
        description=''
        type
        cubeStructRef
        %
    end
    methods
        function isNullVec=getIsNullDefault(self,valueVec)
            % GETISNULLDEFAULT generates a default is-null indicator value
            % for a field
            %
            % Input:
            %   regular:
            %     valueVec: array [] - array of some type containing field values
            %        across all the field cells
            %
            % Output:
            %   regular:
            %     isNullVec logical/cell [] array of is-null
            %        indicators corresponding to valueVec
            %
            %
            isNullVec=self.type.generateIsNull(valueVec);
            %
        end        
        function display(self)
            SRes=self.saveObjInternal();
            modgen.struct.strucdisp(SRes(:));
        end
        function copyFrom(self,obj)
            nElem=numel(self);
            if nElem==numel(obj)
                if ~isempty(obj)
                    typeList=obj.getTypeList();
                    [self.type]=deal(typeList{:});
                    for iElem=1:nElem
                        self(iElem).type=...
                            smartdb.cubes.CubeStructFieldTypeFactory.clone(...
                            self(iElem).cubeStructRef,obj(iElem).getType);
                    end
                    
                    nameList=obj.getNameList();
                    [self.name]=deal(nameList{:});
                    %
                    descriptionList=obj.getDescriptionList();
                    [self.description]=deal(descriptionList{:});
                end
            else
                error([upper(mfilename),':wrongInput'],...
                    'numer of elements in the source and target object arrays should be the same');
            end
        end
        function set.type(self,value)
            if ~isa(value,self.TYPE_FIELD_TYPE_NAME)
                error([upper(mfilename),':wrongInput'],...
                    'type field is expected to be of type %s',...
                    self.TYPE_FIELD_TYPE_NAME);
            end
            self.type=value;
        end
        function set.cubeStructRef(self,value)
            if ~isa(value,smartdb.cubes.CubeStructFieldInfo.CUBE_STRUCT_TYPE_NAME)
                error([upper(mfilename),':wrongInput'],...
                    'cubeStructRef property is expected to be of CubeStruct type');
            end
            self.cubeStructRef=value;
        end
    end
    %
    methods (Static, Access=protected)
        function cubeStructRefList=processCubeStructRefList(sizeVec,cubeStructRefList)
            if ~iscell(cubeStructRefList)
                cubeStructRefList={cubeStructRefList};
                cubeStructRefList=cubeStructRefList(ones(sizeVec));
            end
        end
        function inpArgList=processCustomArrayArgList(varargin)
            if nargin<2
                modgen.common.throwerror('wrongInput',...
                    'nameList parameter is obligatory');
            end
            %
            inpArgList={varargin{1},'nameList',varargin{2}};
            if nargin>=3
                inpArgList=[inpArgList,{'descriptionList',varargin{3}}];
            end
            %
            if nargin>=4
                inpArgList=[inpArgList,{'typeSpecList',varargin{4}}];
            end
        end
    end
    methods (Static)
        resArray=customArray(cubeStructRef,nameList,descriptionList,typeSpecList)
        resArray=defaultArray(cubeStructRefList,sizeVec)
        %
    end
    methods (Access=private)
        function [self,obj]=adjustSizesForEq(self,obj)
            if ~isequal(size(self),size(obj)),
                if numel(self)==1,
                    self=repmat(self,size(obj));
                elseif numel(obj)==1,
                    obj=repmat(obj,size(self));
                else
                    error('MATLAB:dimagree',...
                        'Matrix dimensions must agree.');
                end
            end
        end
        function assignValues(self,valueList,fTypeCheckFunc,fieldName)
            % ASSIGN value is a thin wrapper for processValue which allows
            % a vectorial value assignment
            %
            valueList=modgen.common.obj.processpropvalue(size(self),valueList,fTypeCheckFunc);
            if ~isempty(self)
                [self.(fieldName)]=deal(valueList{:});
            end
            %
        end
    end
    methods (Access=protected)
        SObjectData=saveObjInternal(self)
        % SAVEOBJINTERNAL saves a current object state to a structure,
        %    please note that this function is only used for implementing
        %    isEqual method
        %
        
        resArray=buildArrayByProp(self,cubeStructRefList,varargin)
        % BUILDARRAYBYPROP is a helper method for filling an object arrays
        % with the specified properties        
        [isEq,reportStr,signOfDiff]=isEqualScalarInternal(self,otherObj,...
            varargin)
    end
    methods (Static)
        function isPositive=isMe(inpObj)
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end
    end
    methods
        function self=CubeStructFieldInfo(varargin)
            % CUBESTRUCTFIELDINFO is a constructor for the class of the
            % same name
            %
            % Input:
            %
            %   Case0 (default construtor): no input parameters
            %
            %   Case1 (copy constructor):
            %       obj: CubeStructFieldInfo[] - object array which served
            %           as a prototype for a constructed object array of the
            %           same size
            %
            %   Case2 (property-based constructor):
            %       see a documentation for buildArrayByProp method for a list
            %          of allowed properties
            %
            %
            % Output:
            %   self: CubeStructFieldInfo[] - constructed object array
            %
            %
            
            import modgen.common.throwerror;
            metaClassObj=metaclass(self);
            className=metaClassObj.Name;
            %
            [reg,prop]=modgen.common.parseparams(varargin);
            nReg=length(reg);
            %
            if nReg==0
                if isempty(prop)
                    return;
                else
                    throwerror('wrongInput',...
                        'no regular arguments assumes no properties');
                end
                %
            end            
            %            
            isMeOnInput=false;
            isEmptyToCreate=false;
            isCubeStructRefListOnInput=false;
            if nReg==1&&isnumeric(reg{1})&&isempty(reg{1})
                isEmptyToCreate=true;
            elseif nReg>=1&&(iscell(reg{1})||isa(reg{1},...
                    'smartdb.cubes.CubeStruct'))
                isCubeStructRefListOnInput=true;
            elseif nReg>=1&&feval([className '.isMe'],reg{1});
                isMeOnInput=true;
            end
            %
            if isEmptyToCreate
                self=feval([className '.empty'],size(reg{1}));
            else
                if isMeOnInput
                    sizeVec=size(reg{1});
                    if nReg==2
                        cubeStructRefList=reg{2};
                    else
                        cubeStructRefList=reg{1}.getCubeStructRefList();
                    end
                    self=feval([className '.defaultArray'],...
                        cubeStructRefList,sizeVec);
                    %
                    self.copyFrom(reg{1});
                elseif isCubeStructRefListOnInput
                    cubeStructRefList=reg{1};
                    self=self.buildArrayByProp(...
                        cubeStructRefList,prop{:});
                else
                    throwerror('wrongInput',...
                        'unsupported way to construct an object');
                end
            end
            %
        end
        function cubeStructRef=getCubeStructRefList(self)
            cubeStructRef=reshape({self.cubeStructRef},size(self));
        end
        function fieldMetaDataVec=filterByName(self,fieldNameList)
            import modgen.common.throwerror;
            fieldMetaDataVec=self;
            if ischar(fieldNameList)
                fieldNameList={fieldNameList};
            end
            fullFieldNameList=fieldMetaDataVec.getNameList();
            [~,indLoc]=ismember(fieldNameList,fullFieldNameList);
            if any(indLoc==0)
                throwerror('wrongInput',...
                    'cannot find meta-data for all names');
            end
            if ~isempty(indLoc)
                fieldMetaDataVec=fieldMetaDataVec(indLoc);
            else
                fieldMetaDataVec=fieldMetaDataVec.empty(1,0);
            end
        end
        %
        function name=getName(self)
            import modgen.common.throwerror;
            if length(self)>1
                throwerror('wrongInput',...
                    'this methods is not supported for arrays');
            end
            %
            name=self.name;
        end
        %
        function nameList=getNameList(self)
            %
            nameList=reshape({self.name},size(self));
        end
        %
        function descrList=getDescriptionList(self)
            descrList=reshape({self.description},...
                size(self));
        end
        %
        function description=getDescription(self)
            description=self.description;
        end
        %
        function fieldType=getType(self)
            import modgen.common.throwerror;
            if numel(self)~=1
                throwerror('wrongInput',...
                    'this method only works for scalar objects');
            end
            fieldType=self.type;
        end
        function type=getDefaultTypeByCubeStructRef(~,cubeStructRef,varargin)
            type=smartdb.cubes.CubeStructFieldTypeFactory.defaultArray(...
                cubeStructRef,varargin{:});
        end
        function fieldType=getTypeList(self)
            if ~isempty(self)
                fieldType={self.type};
                fieldType=reshape(fieldType,size(self));
            else
                fieldType=cell.empty(size(self));
            end
        end
        %
        function isCellVec=getIsValueCell(self)
            typeList=self.getTypeList;
            isCellVec=cellfun(@(x)x.getIsCell(),typeList);
        end
        function typeSpec=getTypeSpec(self)
            import modgen.common.throwerror;
            if numel(self)~=1
                throwerror('badUsage',...
                    'the given method is only implemented for scalar objects');
            end
            typeSpec=self.type.toClassName();
        end
        %
        function typeSpecList=getTypeSpecList(self)
            typeSpecList=cellfun(@(x)x.toClassName,...
                self.getTypeList,'UniformOutput',false);
        end
        %
        function setNameList(self,fieldName)
            self.assignValues(fieldName,@ischar,'name');
        end
        %
        function setDescrList(self,description)
            self.assignValues(description,@ischar,'description');
        end
        %
        function setTypeList(self,typeList)
            self.assignValues(typeList,@(x)isa(x,...
                smartdb.cubes.CubeStructFieldInfo.TYPE_FIELD_TYPE_NAME),'type');
        end
        function setTypeBySpec(self,typeSpec)
            %
            if iscellstr(typeSpec)
                typeSpec={typeSpec};
            end
            %
            typeSpecList=modgen.common.obj.processpropvalue(size(self),...
                typeSpec,@iscellstr);
            nElem=numel(self);
            for iElem=1:nElem
                typeObj=smartdb.cubes.CubeStructFieldTypeFactory.fromClassName(...
                    self(iElem).cubeStructRef,...
                    typeSpecList{iElem});
                self(iElem).type=typeObj;
            end
            %
        end
        %
        function setDefaultType(self)
            nElem=numel(self);
            for iElem=1:nElem
                self(iElem).type=self(iElem).type.setDefault();
            end
        end
        %
        function setTypeFromValue(self,value)
            import modgen.common.throwerror;
            if numel(self)>1
                throwerror('wrongInput',...
                    'this method is not supported for object arrays');
            end
            self.type=self.type.setFromValue(value);
        end
        function varargout=generateDefaultFieldValue(self,varargin)
            import modgen.common.throwerror;
            if numel(self)>1
                throwerror('wrongInput',...
                    'method is not supported for object arrays');
            end
            if nargout>0
                varargout=cell(1,nargout);
                [varargout{:}]=self.type.createDefaultValueArray(varargin{:});
            else
                self.type.createDefaultValueArray(varargin{:})
            end
        end
        function checkFieldValue(self,fieldNameInd,varargin)
            import modgen.common.throwerror;
            if ischar(fieldNameInd)
                mdObj=self.filterByName(fieldNameInd);            
            elseif isnumeric(fieldNameInd)
                mdObj=self(fieldNameInd);
            else
                throwerror('wrongInput',...
                    'fieldNameInd can be either a field name of a field number');
            end
            if numel(mdObj)~=1
                throwerror('wrongInput',...
                    'this method is implemented for scalar objects');
            end
            %
            try
                mdObj.type=mdObj.type.checkValue(varargin{:});
            catch meObj
                if ~isempty(strfind(meObj.identifier,':wrongInput'))
                    newMeObj=MException([upper(mfilename),':wrongInput'],...
                        'type check failed for field %s',mdObj.name);
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                else
                    rethrow(meObj);
                end
            end
        end
    end
end