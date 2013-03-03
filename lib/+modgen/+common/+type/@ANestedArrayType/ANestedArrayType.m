classdef ANestedArrayType
    methods (Abstract)
        typeSeqString=toTypeSequenceString(self)
        isPositive=isContainedInCellType(self)
        isPositive=isCellTypeContained(self)
        classNameList=toClassName(STypeInfo)
    end
    methods (Abstract,Access=protected)
        STypeInfo=getValueTypeStruct(self)
    end
    methods (Abstract)
        isPositive=isIncludedInto(self,obj)
    end
    methods (Access=protected)
        function isPositive=isEqual(self,obj)
            isPositive=self.isIncludedInto(obj)&&obj.isIncludedInto(self);
        end
        %
        function throwCannotDetermineIfIncludedIntoException(self)
            error([upper(mfilename),':noCanDo'],...
                    ['cannot determine is the specified object',...
                     'is included into another object, sorry.']);
        end
    end
    methods
        function valueMat=createDefaultArray(self,sizeInpVec)
            valueMat=modgen.common.type.ANestedArrayType.createarraybytypeinfo(...
                self.getValueTypeStruct(),sizeInpVec);
        end        
        function depth=getDepth(self)
            depth=self.getValueTypeStruct().depth;
        end
        function typeName=getTypeName(self)
            typeName=self.getValueTypeStruct().type;
        end        
        function isPositive=isEmptyTypeSet(~)
            isPositive=false;
        end
        function isPositive=isCompleteTypeSet(~)
            isPositive=false;
        end
        %
        function display(self)
            fprintf('ANestedArrayType, type: %s, type sequence: %s\n',...
                class(self),self.toTypeSequenceString);
        end
        function isPositive=isequal(self,obj)
            isPositive=isEqual(self,obj);
        end
        function isPositive=eq(self,obj)
            isPositive=isEqual(self,obj);
        end
        function isPositive=ne(self,obj)
            isPositive=~isEqual(self,obj);
        end
    end
    methods (Static)
          valueMat=createarraybytypeinfo(STypeInfoInp,sizeInpVec,varargin)
    end
end