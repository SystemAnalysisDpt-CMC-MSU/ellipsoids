classdef ACubeStructFieldType
    %NESTEDSIZEDARRAYTYPE Summary of this class goes here
    %   Detailed explanation goes here
    properties (Constant, GetAccess=private,Hidden)
        CUBE_STRUCT_TYPE_NAME='smartdb.cubes.CubeStruct';
    end
    properties (Access=protected)
        valueType
        cubeStructRef
    end
    properties (Abstract,GetAccess=protected,Constant)
        UNKNOWN_TYPE_KIND_NAME
    end
    methods (Abstract,Access=protected)
        self=checkValueOnActionAdd(self,newValueType,varargin)
        self=checkValueOnActionReplace(self,newValueType,varargin)
    end
    methods (Access=protected)
        function throwErrorTypeChangeAttempt(self,obj)
            import modgen.common.throwerror;
            throwerror('wrongInput',...
                ['an attempt to change the field type: ',...
                'checked value''s type is %s while the current field type is %s'],...
                obj.toTypeSequenceString,self.valueType.toTypeSequenceString());
        end
        function valueType=getValueTypeFromValue(~,value)
            valueType=modgen.common.type.NestedArrayTypeFactory.fromValue(...
                value);
        end
        function SRes=saveObjInternal(self)
            SRes=cellfun(@(x)struct(x.valueType),num2cell(self),...
                'UniformOutput',false);
            SRes=[SRes{:}];
        end
        function objArray=ACubeStructFieldType(varargin)
            if nargin==0
                return;
            elseif nargin==0&&isnumeric(varargin{1})&&isempty(varargin{1})
                objArray=objArray([]);
            elseif nargin==1&&~iscell(varargin{1})
                objArray.cubeStructRef=varargin{1};
            elseif nargin==1&&iscellstr(varargin{1})
                objArray.valueType=...
                    modgen.common.type.NestedArrayTypeFactory.fromClassName(varargin{1});
            elseif nargin==1&&iscell(varargin{1})
                sizeVec=size(varargin{1});
                nElem=numel(varargin{1});
                objArray(nElem)=objArray;
                for iElem=1:nElem
                    objArray(iElem).cubeStructRef=varargin{1}{iElem};
                end
                objArray=reshape(objArray,sizeVec);
            elseif nargin>=1&&isa(varargin{1},'smartdb.cubes.ACubeStructFieldType')
                nElem=numel(varargin{1});
                sizeVec=size(varargin{1});
                objArray(nElem)=objArray;
                if nargin==2
                    cubeStructRefList=varargin{2};
                    if ~iscell(cubeStructRefList)
                        cubeStructRefList={cubeStructRefList};
                    end
                else
                    cubeStructRefList=varargin{1}.getCubeStructRefList();
                end
                valueTypeList=varargin{1}.getValueTypeList;
                [objArray.cubeStructRef]=deal(cubeStructRefList{:});
                [objArray.valueType]=deal(valueTypeList{:});
                objArray=reshape(objArray,sizeVec);
            else
                error([upper(mfilename),':wrongInput'],...
                    'unsupported way to construct objects');
            end
        end
        function valueTypeList=getValueTypeList(self)
            valueTypeList={self.valueType};
            
        end
    end
    methods
        function self=checkValue(self,isConsistencyChecked,actionType,isSpecified,valueCVec)
            % CHECKVALUE checks and a value of CubeStruct field and updates
            % (if neccessary) its type
            %
            % Input:
            %   regular:
            %       self:
            %       isConsistencyChecked: logical [1,1]/[1,2] - the
            %           first element defines if a consistency between the value
            %           elements (data, isNull and isValueNull) is checked;
            %           the second element (if specified) defines if
            %           value's type is checked. If isConsistencyChecked
            %           is scalar, it is automatically replicated to form a
            %           two-element vector
            %
            %       actionType: char[1,] - can have the following values
            %           'add' - the value is checked under assumption that
            %               it is added to already existing set of values
            %
            %           'replace' - the value is checked under assumption
            %              that it is intended to replace some existing values
            %
            %           'replaceNull' - the value is checked under
            %              assumption that it is intended to replace a null
            %              value
            %
            %       isSpecified: logical[1,3] - defines which value
            %          elements are specified
            %
            %       valueCVec: cell[1,3] - contain value elementes (data,
            %           isNull and isValueNull correspondingly)
            %
            % Output:
            %   self:
            %
            %
            % $Author: Peter Gagarinov  <pgagarinov@gmail.com> $	$Date: 2012-08-17 $ 
            % $Copyright: Moscow State University,
            %            Faculty of Computational Mathematics and Computer Science,
            %            System Analysis Department 2012 $
            %
            %
            import modgen.common.throwerror;
            if numel(self)>1
                throwerror('wrongInput',...
                    'method is not supported for object arrays');
            end
            nConsCheckElems=numel(isConsistencyChecked);
            if nConsCheckElems==1
                isTypeConsistencyChecked=isConsistencyChecked;
            elseif nConsCheckElems==2
                isTypeConsistencyChecked=isConsistencyChecked(2);
                isConsistencyChecked=isConsistencyChecked(1);
            else
                throwerror('wrongInput',...
                    'isConsistencyChecked can only have 1 or 2 elements');
            end
            %
            if isConsistencyChecked
                if ~smartdb.cubes.ACubeStructFieldType.checkvaluematchisnull(...
                        self.cubeStructRef.getMinDimensionality(),...
                        isSpecified,valueCVec{:})
                    throwerror('wrongInput',...
                        ['value, isNull and isValueNull indicators ',...
                        'are not consistent between each other']);
                end
            end
            if isTypeConsistencyChecked
                newValueType=self.getValueTypeFromValue(valueCVec{1});
                %
                if ~self.valueType.isIncludedInto(newValueType)
                    if strcmpi(actionType,'replaceNull')
                        self.throwErrorTypeChangeAttempt(newValueType);
                    else
                        switch lower(actionType)
                            case 'add',
                                newSelf=self.checkValueOnActionAdd(newValueType);
                            case 'replace',
                                newSelf=self.checkValueOnActionReplace(newValueType);
                            otherwise,
                                throwerror('wrongInput',...
                                    'unknown action type: %s',actionType);
                        end
                        self=newSelf;
                    end
                end
            end
        end
        function cubeStructRefList=getCubeStructRefList(self)
            cubeStructRefList={self.cubeStructRef};
        end
        function isEq=isequal(varargin)
            import modgen.common.throwerror;
            isnWrong=nargin>1;
            if isnWrong,
                isnWrong=~ischar(varargin{2});
            end
            if ~isnWrong,
                throwerror('wrongInput',...
                    'At least two objects must be given');
            end
            reg=modgen.common.parseparams(varargin,[],[],0);
            %
            nObj=length(reg);
            for iObj=1:nObj-1,
                obj1=varargin{iObj};
                obj2=varargin{iObj+1};
                isEq=eq(obj1,obj2);
                if ~isEq,
                    return;
                end
            end
            isEq=true;
        end
        function isPositive=eq(self,obj)
            isPositive=isEqual(self,obj);
        end
        function isPositive=ne(self,obj)
            isPositive=~isEqual(self,obj);
        end
        function isPositive=isEqual(self,obj)
            % ISEQUAL compares a given object with a specified one
            if ~isa(obj,'smartdb.cubes.ACubeStructFieldType')
                isPositive=false;
            else
                isPositiveArray=cellfun(@(x,y)isequal(x,y),self.getValueTypeList(),...
                    obj.getValueTypeList());
                isPositive=all(isPositiveArray(:));
            end
            
        end
        function self=setFromValue(self,value)
            self.valueType=modgen.common.type.NestedArrayTypeFactory.fromValue(value);
        end
        function SRes=toStruct(self)
            warning([upper(mfilename),':wrongInput'],...
                'toStruct method is for a temporary use only, it will be removed in the future versions');
            SRes=self.saveObjInternal();
        end
        function display(self)
            fprintf('ACubeStructFieldType, type: %s, valueType: %s\n',...
                class(self),evalc('display(self.valueType);'));
        end
        function [valueArray,isNullArray,isValueNullArray]=createDefaultValueArray(...
                self,sizeVec,varargin)
            %CREATEDEFAULTVALUEARRAY generates an array of default CubeStruct field
            %values
            %
            % Input:
            %   regular:
            %       self:
            %       sizeVec: double[1,] - size of valueArray
            %
            %   optional:
            %       sizeIsValueNullVec: double[1,] - size of isNullArray
            %
            %   properties:
            %       columnData: logical[1,1] - if true, sizeVec is
            %          interpreted as a size of column rather than a size of
            %          just some array. Column data mode allows to generate
            %           sizeIsValueNullVec based on sizeVec automatically
            %
            % Output:
            %   valueArray: []
            %   isNullArray []
            %   isValueNullArray logical[]
            %
            %
            import modgen.common.throwerror;
            [reg,prop]=modgen.common.parseparams(varargin,{'columnData'},[0 1]);
            if ~isempty(prop)
                isColumnData=prop{2};
            else
                isColumnData=true;
            end
            %
            if isempty(reg)
                if isColumnData
                    if nargin<2
                        sizeVec=self.cubeStructRef.getMinDimensionSize();
                    end
                    minDimensionality=self.cubeStructRef.getMinDimensionality;
                    sizeIsValueNullVec=sizeVec(1:minDimensionality);
                elseif nargin<2
                    throwerror('wrongInput',...
                        ['sizeVec is an obligatory parameter ',...
                        'when isColumnData=false']);
                else
                    sizeIsValueNullVec=sizeVec;
                end
            else
                sizeIsValueNullVec=reg{1};
            end
            %
            valueArray=self.valueType.createDefaultArray(sizeVec);
            isNullArray=self.generateIsNull(valueArray,true);
            if ~isempty(sizeIsValueNullVec)
                isValueNullArray=true([sizeIsValueNullVec,1]);
            else
                isValueNullArray=logical.empty(0,0);
            end
        end
        function isNullArray=generateIsNull(self,valueArray,isNull)
            % GENERATEISNULL produces an array of isNull elements
            % filled with a specified value based on a specified value array
            %
            % Input:
            %   self:
            %   valueArray: any type[n_1,...,n_k] value array
            %   isNull logical[1,1] - value used to fill the target isNull
            %      array
            %
            % Output:
            %   isNullArray: cell/logical[n_1,...,n_k]
            %
            %
            if nargin<3
                isNull=false;
            end
            if ~iscell(valueArray)
                if isNull
                    isNullArray=true(size(valueArray));
                else
                    isNullArray=false(size(valueArray));
                end
            else
                isNullArray=self.generateisnull(self.valueType.getTypeName,...
                    self.valueType.getDepth,...
                    valueArray,isNull);
            end
        end
        function isCellVec=getIsCell(self)
            valueTypeList=self.getValueTypeList();
            isCellVec=cellfun(@(x)x.isContainedInCellType(),valueTypeList);
        end
        function classNameList=toClassName(self)
            import modgen.common.throwerror;
            if length(self)>1
                throwerror('wrongInput',...
                    'the given method is not supported for object arrays');
            end
            classNameList=self.valueType.toClassName();
        end
        function self=set.valueType(self,value)
            import modgen.common.throwerror;
            expTypeName='modgen.common.type.ANestedArrayType';
            if ~isa(value,expTypeName)
                throwerror('wrongType',...
                    'valueType property should be of %s type',expTypeName);
            end
            self.valueType=value;
        end
        function self=set.cubeStructRef(self,value)
            import modgen.common.throwerror;
            if ~isa(value,smartdb.cubes.ACubeStructFieldType.CUBE_STRUCT_TYPE_NAME)
                throwerror('wrongInput',...
                    'cubeStructRef property is expected to have CubeStruct type');
            end
            self.cubeStructRef=value;
        end
        function self=setValueTypeBySpec(self,value)
            import modgen.common.throwerror;
            if isempty(self)
                throwerror('wrongInput',...
                    'method is not supported for empty arrays');
            end
            typeSpecList=modgen.common.obj.processpropvalue(size(self),value,@iscellstr);
            valueTypeList=modgen.common.type.NestedArrayTypeFactory.fromClassNameArray(...
                typeSpecList,self(1).UNKNOWN_TYPE_KIND_NAME);
            [self.valueType]=deal(valueTypeList{:});
        end
        function valueArray=getValueTypeSpecArray(self)
            valueArray=reshape(cellfun(@(x)x.toClassName,...
                {self.valueType},'UniformOutput',false),...
                size(self));
        end
        function self=setDefault(self)
            self=self.setValueTypeBySpec({});
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
                cubeStructRefList=smartdb.cubes.ACubeStructFieldType.processCubeStructRefList(...
                    sizeVec,cubeStructRef);
            else
                cubeStructRefList=cubeStructRef.empty(sizeVec);
            end
            objArray=smartdb.cubes.CubeStructFieldTypeFactory.fromCubeStructRefList(cubeStructRefList);
        end
    end
    methods (Static)
        function objArray=defaultArray(cubeStructRef,sizeVec)
            objArray=smartdb.cubes.ACubeStructFieldType.uninitializedArray(cubeStructRef,sizeVec);
            objArray=objArray.setDefault();
        end
        %
        function obj=fromClassName(cubeStructRef,className)
            obj=smartdb.cubes.ACubeStructFieldType.fromClassNameArray(cubeStructRef,{className});
        end
        %
        function objArray=fromClassNameArray(cubeStructRef,classNameArray)
            import modgen.common.throwerror;
            if numel(cubeStructRef)>1
                throwerror('wrongInput',...
                    'method is not supported for a vectorial value of cubeStructRef');
            end
            sizeVec=size(classNameArray);
            objArray=smartdb.cubes.ACubeStructFieldType.uninitializedArray(cubeStructRef,sizeVec);
            objArray=objArray.setValueTypeBySpec(classNameArray);
        end
        valueMat=createarraybytypesizeinfo(STypeSizeInfoInp,varargin)
        STypeSizeInfo=generatetypesizeinfostruct(value)
        [isOk,STypeInfo]=istypesizeinfouniform(STypeSizeInfo)
        [isOk,SValueTypeInfo]=checkvaluematchisnull(minDimensionality,isSpecified,value,isNull,isValueNull)
        isOk=checkvaluematchisnull_aux(value,valueIsNull)
        isNullMat=generateisnull(typeName,depth,valueMat,isNull)
        isValueNullMat=isnull2isvaluenull(isNullMat,minDim)
    end
end