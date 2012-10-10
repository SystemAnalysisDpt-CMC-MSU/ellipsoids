classdef test_result<mlunit.test_result
    % TEST_RESULT collects test results of executed tests. As
    %  in the other testing frameworks of the xUnit family the framework
    %  differs between failure and error. A failure is raised by an
    %  assertion, that means by the method assert, while an error is
    %  raised by the Matlab environment, for example through a syntax
    %  error.
    %
    %  Example:
    %   result = test_result;
    %
    %  See also MLUNIT.ASSERT,
    %           MLUNIT.ASSERT_EQUALS,
    %           MLUNIT.ASSERT_NOT_EQUALS,
    %           MLUNIT.TEXT_TEST_RESULT.
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    methods
        function self=test_result(varargin)
            self=self@mlunit.test_result(varargin{:});
        end
    end
end