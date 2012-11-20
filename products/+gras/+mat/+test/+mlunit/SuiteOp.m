classdef SuiteOp < mlunitext.test_case
    methods
        function self = SuiteOp(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testUnaryOpFunc(self)
        end
        %
        function testBinaryOpFunc(self)
        end
    end
end