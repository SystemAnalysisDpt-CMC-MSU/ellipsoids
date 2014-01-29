classdef CubeStructFieldStaticType<smartdb.cubes.ACubeStructFieldType
    properties (GetAccess=protected,Constant)
        UNKNOWN_TYPE_KIND_NAME='no';
    end
    methods
        function self=CubeStructFieldStaticType(varargin)
            self=self@smartdb.cubes.ACubeStructFieldType(varargin{:});
        end
        %
    end
    methods (Access=protected)
        function self=checkValueOnActionAdd(self,newValueType)
            if ~newValueType.isIncludedInto(self.valueType)
                self.throwErrorTypeChangeAttempt(newValueType);
            end
        end
        function self=checkValueOnActionReplace(self,newValueType)
            if ~newValueType.isIncludedInto(self.valueType)
                self.throwErrorTypeChangeAttempt(newValueType);
            end
        end        
    end
end
