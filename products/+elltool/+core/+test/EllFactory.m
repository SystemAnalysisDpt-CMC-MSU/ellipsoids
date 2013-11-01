classdef EllFactory
    properties (Access=private)
        ellType
    end

    methods 
        function self = EllFactory(ellType)
            self.ellType = ellType;
        end
        function ellObj=create(varargin)
            switch ellType
                case 'ellipsoid',
                    ellObj = ellipsoid(varargin{:});
                case 'GenEllipsoid',
                    ellObj = elltool.core.GenEllipsoid(varargin{:});
            otherwise,
                    modgen.common.throwerror('wrongInput','unsupported ellipsoid type');
            end
        end
    end
end