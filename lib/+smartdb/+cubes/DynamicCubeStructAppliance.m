classdef DynamicCubeStructAppliance<smartdb.cubes.FixedDimDynCubeStructAppliance
    % STATICCUBESTRUCTAPPLIANCE adds basic capabilities to CubeStruct
    methods
        function permuteDim(self,varargin)
            self.permuteDimInternal(varargin{:});
        end
        %
        function changeMinDim(self,varargin)
            self.changeMinDimInternal(varargin{:});
        end
        %
        function reshapeData(self,varargin)
            self.reshapeDataInternal(varargin{:});
        end
    end
end
