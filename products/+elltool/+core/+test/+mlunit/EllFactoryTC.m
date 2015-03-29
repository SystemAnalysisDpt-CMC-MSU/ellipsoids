classdef EllFactoryTC < mlunitext.test_case
    properties (Access = private)
        ellFactoryObj
    end
    
    methods
        function self = EllFactoryTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up_param(self, ellFactoryObj)
            self.ellFactoryObj = ellFactoryObj;
        end
        
        function ellObj = createEll(self, varargin)
            ellObj = self.ellFactoryObj.create(varargin{:});
        end
    end
end
