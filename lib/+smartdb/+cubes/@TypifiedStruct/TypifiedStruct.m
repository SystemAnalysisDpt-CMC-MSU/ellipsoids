classdef TypifiedStruct<smartdb.cubes.CubeStruct&smartdb.cubes.DynamicCubeStructAppliance
    methods (Access=protected,Hidden)
        function initialize(self,varargin)
            self.parseAndAssignFieldProps(varargin{:});
        end
    end
    methods
        function self=TypifiedStruct(varargin)
            self=self@smartdb.cubes.CubeStruct(varargin{:},'minDimensionality',0);
        end
    end
end
