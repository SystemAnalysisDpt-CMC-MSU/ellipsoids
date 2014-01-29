classdef SuiteBasic < mlunitext.test_case
    properties 
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function self = set_up_param(self,varargin)

        end
        %
        function self=test_smth(self)

        end
    end
end