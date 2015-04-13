classdef Test1 < mlunitext.test_case
    
    properties
    end
    
    methods
        function self = Test1(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function testMatrixFunctionComparableConst(self)
            %
            m1 = [1 2; 3 0];
            m2 = [1 2; 3 0];
            actSolution = isequal(m1,m2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
            %
            m1 = [1 3; 9 1];
            m2 = [2 6; 3 1];
            actSolution = isequal(m1,m2);
            expSolution = 0;
            mlunitext.assert_equals(actSolution,expSolution);
            %
            m1 = ones(3);
            m2 = ones(2);
            actSolution = isequal(m1,m2);
            expSolution = 0;
            mlunitext.assert_equals(actSolution,expSolution);
        end
    end
    
end

