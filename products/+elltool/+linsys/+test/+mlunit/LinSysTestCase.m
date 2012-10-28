classdef LinSysTestCase < mlunit.test_case
    %
    methods
        function self = LinSysTestCase(varargin)
            self = self@mlunit.test_case(varargin{:});
        end
        %
        function self = testDimension(self)
                        
            % test empty system
            A = [];
            B = [];
            U = [];
            
            systemFirst = linsys(A,B,U);                        
            [N, I, O, D] = dimension(systemFirst);
            
            obtained = [N I O D];
            expectedFirst = [0 0 0 0];
         
            mlunit.assert_equals( all(expectedFirst == obtained), true );
                              
            % test simple system without disturbance
            A = eye(2);
            B = eye(2,3);
            U = ell_unitball(3);
            
            systemSecond = linsys(A,B,U);                        
            [N, I, O, D] = dimension(systemSecond);
            
            obtained = [N I O D];
            expectedSecond = [2 3 2 0];
            
            mlunit.assert_equals( all(expectedSecond == obtained), true );   
            
            % test complex system with disturbance and noise            
            A = eye(5);
            B = eye(5,10);
            U = ell_unitball(10);
            G = eye(5,11);
            V = ell_unitball(11);
            C = zeros(3,5);
            W = ell_unitball(3);
            
            systemThird = linsys(A,B,U,G,V,C,W);                        
            [N, I, O, D] = dimension(systemThird);
            
            obtained = [N I O D];
            expectedThird = [5 10 3 11];
            
            mlunit.assert_equals( all(expectedThird == obtained), true );   
            
            
            % test array of systems            
            systemArray = [systemFirst; systemSecond; systemThird];
            
            [N, I, O, D] = dimension( systemArray );
            
            obtained = [N I O D];
            expected = [expectedFirst; expectedSecond; expectedThird];
            result = (expected == obtained);
            
            mlunit.assert_equals( all(result(:)), true );
            
        end
    end
end