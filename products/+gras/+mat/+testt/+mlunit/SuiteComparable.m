classdef SuiteComparable < mlunitext.test_case
    
    properties
    end
    
    methods
        function self = SuiteComparable(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function testMatrixFunctionComparableConstMatrix(self)
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
        
        function testMatrixFunctionComparableConstArray(self)
            %
            a1 = [1 3 4 6 20 183];
            a2 = [1 3 4 6 20 183];
            actSolution = isequal(a1,a2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
            
            %
            s1 = ['s' 'a'];
            s2 = ['s' 'a'];
            actSolution = isequal(a1,a2);
            expSolution = 1;
            mlunitext.assert_equals(actSolution,expSolution);
        end
    end
    
end

