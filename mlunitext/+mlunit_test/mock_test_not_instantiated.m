classdef mock_test_not_instantiated < mlunit_test.mock_test
    % MOCK_TEST_NOT_INSTANTIATED is a mock test_case which is not 
    %   instantiated during the testing.
    %
    %  Example: See TEST_REFLECT.TEST_GET_METHOD.

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    methods
        function self = mock_test_not_instantiated(varargin)
            self = self@mlunit_test.mock_test(varargin{:});
        end
    end
end