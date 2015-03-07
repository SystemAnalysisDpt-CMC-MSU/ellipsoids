classdef EllFactory
    properties (Access=private)
        ellType
    end

    methods 
        function self = EllFactory(ellType)
            self.ellType = ellType;
        end
        
        function ellObj=create(self, varargin)         
            if (strcmp(self.ellType, 'ellipsoid'))
                ellObj = ellipsoid(varargin{:});
            elseif (strcmp(self.ellType, 'GenEllipsoid'))
                ellObj = elltool.core.GenEllipsoid(varargin{:});
            else 
                modgen.common.throwerror('wrongInput','unsupported ellipsoid type');
            end
        end
    end
end