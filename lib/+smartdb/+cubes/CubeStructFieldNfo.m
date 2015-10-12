classdef CubeStructFieldNfo<modgen.common.obj.HandleObjectCloner
    %CUBESTRUCTFIELDNFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access=protected)
        fieldMetaData
    end
    
    methods (Access=protected)
        function setFieldMetaDataCheck(~,value)
            if ~isa(value,'smartdb.cubes.CubeStructFieldInfo')
                modgen.common.throwerror('wrongInput',['fieldMetaData field ',...
                    'should be of smartdb.cubes.CubeStructFieldInfo type']);
            end
        end
        function [isPositive,varargout]=...
                isEqualScalarInternal(self,obj,varargin)
            varargout=cell(1,max(nargout-1,0));
            [isPositive,varargout{:}]=self.fieldMetaData.isEqual(...
                obj.fieldMetaData,'propEqScalarList',varargin);
        end        
    end
    methods 
        function set.fieldMetaData(self,value)
            self.setFieldMetaDataCheck(value);
            self.fieldMetaData=value;            
        end
        function self=CubeStructFieldNfo(varargin)
            if nargin>0
                if (nargin==1)&&isa(varargin{1},...
                        'smartdb.cubes.CubeStructFieldInfo')
                    self.fieldMetaData=varargin{1};
                elseif (nargin>=1)&&smartdb.cubes.CubeStructFieldNfo.isMe(varargin{1})
                    self.fieldMetaData=smartdb.cubes.CubeStructFieldInfo(...
                        varargin{1}.fieldMetaData,varargin{2:end});
                else
                    self.fieldMetaData=smartdb.cubes.CubeStructFieldInfo(...
                        varargin{:});
                end
            end
        end
        function filterByInd(self,indVec)
            self.fieldMetaData=self.fieldMetaData(indVec);
        end
        function outObj=getFilterByInd(self,indVec,newRef)
            isClone=nargin==3;
            mdObj=self.fieldMetaData(indVec);
            if isClone
                mdObj=mdObj.clone(newRef);
            end
            outObj=self.createInstance(mdObj);
        end
        function outObj=getFilterByName(self,fieldNameList,newRef)
            isClone=nargin==3;            
            mdObj=self.fieldMetaData.filterByName(fieldNameList);
            if isClone
                mdObj=mdObj.clone(newRef);
            end
            outObj=self.createInstance(mdObj);
        end
        function fieldDescrList=getDescriptionList(self)
            fieldDescrList=self.fieldMetaData.getDescriptionList();
        end
        function fieldNameList=getNameList(self)
            fieldNameList=self.fieldMetaData.getNameList;
        end
        function nFields=getNFields(self)
            nFields=numel(self.fieldMetaData);
        end
        function removeFieldsByInd(self,indVec)
            self.fieldMetaData(indVec)=[];
        end
        function catWith(self,otherObj,newRef)
            isClone=nargin==3;
            %
            if isClone
                self.fieldMetaData=[self.fieldMetaData,otherObj.fieldMetaData.clone(newRef)];
            else
                self.fieldMetaData=[self.fieldMetaData,otherObj.fieldMetaData];
            end
        end
        %
        function catWithToFront(self,otherObj,newRef)
            isClone=nargin==3;
            %
            if isClone
                self.fieldMetaData=[otherObj.fieldMetaData.clone(newRef),...
                    self.fieldMetaData];
            else
                self.fieldMetaData=[otherObj.fieldMetaData,...
                    self.fieldMetaData];
            end
        end        
        %
        function catWithByName(self,otherObj,leftFieldNameList,rigthFieldNameList,newRef)
            isClone=nargin==5;
            if isClone
                self.fieldMetaData=[...
                    self.fieldMetaData.filterByName(leftFieldNameList),...
                    otherObj.fieldMetaData.filterByName(rigthFieldNameList).clone(newRef)];
            else
                self.fieldMetaData=[...
                    self.fieldMetaData.filterByName(leftFieldNameList),...
                    otherObj.fieldMetaData.filterByName(rigthFieldNameList)];
            end
        end
        %
        function copyFrom(self,otherObj,fieldNameList)
            if nargin<3
                self.fieldMetaData.copyFrom(otherObj.fieldMetaData);
            else
                self.fieldMetaData.filterByName(fieldNameList).copyFrom(otherObj.fieldMetaData);
            end
        end
        %
        function isNullVec=getIsNullDefault(self,valueVec)
            isNullVec=self.fieldMetaData.getIsNullDefault(self,valueVec);
        end
        function display(self)
            display(self.fieldMetaData);
        end
        
        function setType(self,value,iField)
            if nargin==3
                self.fieldMetaData(iField).type=value;
            else
                self.fieldMetaData.type=value;
            end
        end
        function setCubeStructRef(self,value)
            self.fieldMetaData.cubeStructRef=value;
        end
        function cubeStructRef=getCubeStructRefList(self)
            cubeStructRef=self.fieldMetaData.getCubeStructRefList();
        end
        function name=getName(self,iField)
            if nargin==2
                name=self.fieldMetaData(iField).getName();
            else
                name=self.fieldMetaData.getName();
            end
        end        
        function fieldType=getType(self,iField)
            if nargin==2
                fieldType=self.fieldMetaData(iField).getType();
            else
                fieldType=self.fieldMetaData.getType();
            end
        end
        function type=getDefaultTypeByCubeStructRef(self,cubeStructRef,varargin)
            type=getDefaultTypeByCubeStructRef(self.fieldMetaData,...
                cubeStructRef,varargin{:});
        end
        function description=getDescription(self,iField)
            if nargin==2
                description=self.fieldMetaData(iField).getDescription();
            else
                description=self.fieldMetaData.getDescription();
            end
        end
        function fieldType=getTypeList(self)
            fieldType=self.fieldMetaData.getTypeList();
        end
        function isCellVec=getIsValueCell(self)
            isCellVec=self.fieldMetaData.getIsValueCell();
        end
        function typeSpec=getTypeSpec(self)
            typeSpec=self.fieldMetaData.getTypeSpec();
        end
        function typeSpecList=getTypeSpecList(self)
            typeSpecList=getTypeSpecList(self.fieldMetaData);
        end
        %
        function setNameList(self,fieldNameList,indFieldVec)
            if nargin<3
                self.fieldMetaData.setNameList(fieldNameList);
            else
                self.fieldMetaData(indFieldVec).setNameList(fieldNameList);
            end
        end
        %
        function setDescrList(self,descrList,indFieldVec)
            if nargin<3
                self.fieldMetaData.setDescrList(descrList);
            else
                self.fieldMetaData(indFieldVec).setDescrList(descrList);
            end
        end
        %
        function setTypeList(self,typeList)
            self.fieldMetaData.setTypeList(typeList);
        end        
        function setTypeBySpec(self,typeSpec)
            self.fieldMetaData.setTypeBySpec(typeSpec);
        end
        function setDefaultType(self)
            self.fieldMetaData.setDefaultType();
        end
        function setTypeFromValue(self,value)
            setTypeFromValue(self.fieldMetaData,value);
        end
        function varargout=generateDefaultFieldValue(self,iField,varargin)
            varargout=cell(1,nargout);
            [varargout{:}]=generateDefaultFieldValue(...
                self.fieldMetaData(iField),varargin{:});
        end
        function checkFieldValue(self,fieldNameInd,varargin)
            if ischar(fieldNameInd)
                checkFieldValue(self.fieldMetaData.filterByName(fieldNameInd),...
                    fieldNameInd,varargin{:});
            elseif isnumeric(fieldNameInd)
                checkFieldValue(self.fieldMetaData,...
                    fieldNameInd,varargin{:});
            else
                modgen.common.throwerror('wrongInput',...
                    'fieldNameInd should be either a field name of a field number');
            end
        end
        function [reg,isSpecified]=reconstructFieldValues(self,iField,...
            reg,isSpecified,isNullInferred)
            [reg,isSpecified]=reconstructFieldValues(...
                self.fieldMetaData(iField),...
                reg,isSpecified,isNullInferred);
        end
    end
    methods (Static)
        function isPositive=isMe(inpObj)
            curClassName=mfilename('class');
            isPositive=isa(inpObj,curClassName);
        end        
        function obj=defaultArray(cubeStructRef,sizeVec)
            fieldMetaData=smartdb.cubes.CubeStructFieldInfo.defaultArray(...
                cubeStructRef,sizeVec);
            obj=smartdb.cubes.CubeStructFieldNfo(fieldMetaData);
        end
        function obj=customArray(cubeStructRef,nameList,descriptionList,typeSpecList)
            fieldMetaData=smartdb.cubes.CubeStructFieldInfo.customArray(...
                cubeStructRef,nameList,descriptionList,typeSpecList);
            obj=smartdb.cubes.CubeStructFieldNfo(fieldMetaData);
        end
    end
end

