classdef function_test_case < mlunit.function_test_case
    % The class FUNCTION_TEST_CASE is a wrapper for single-function tests.
    %
    %  Example:
    %   test = function_test_case(@() assert(0 == sin(0)));
    %
    %  See also MLUNIT.TEST_CASE.
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    methods
        function self=function_test_case(varargin)
            self=self@mlunit.function_test_case(varargin{:});
        end
    end
    
end