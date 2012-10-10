classdef test_sin < mlunit.test_case

    methods
        function self = test_sin(varargin)
            self = self@mlunit.test_case(varargin{:});
        end
        
        function self = test_null(self)
            mlunit.assert_equals(0, sin(0));
        end

        function self = test_sin_cos(self)
            mlunit.assert_equals(cos(0), sin(pi/2));
        end
        function self=test_failed(self)
            mlunit.assert_equals(1,0);
        end
    end
end
