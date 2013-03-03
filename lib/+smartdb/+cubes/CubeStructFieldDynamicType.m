classdef CubeStructFieldDynamicType<smartdb.cubes.ACubeStructFieldType
    properties (GetAccess=protected,Constant)
        UNKNOWN_TYPE_KIND_NAME='any';
    end    
    methods
        function self=CubeStructFieldDynamicType(varargin)
            self=self@smartdb.cubes.ACubeStructFieldType(varargin{:});
        end
    end
    methods (Access=protected)
        function self=checkValueOnActionAdd(self,newValueType)
            if self.cubeStructRef.getNElems()==0
                self.valueType=newValueType;
            elseif ~newValueType.isIncludedInto(self.valueType)
                self.throwErrorTypeChangeAttempt(newValueType);
            end
        end
        function self=checkValueOnActionReplace(self,newValueType)
            self.valueType=newValueType;
        end         
    end
    
end
