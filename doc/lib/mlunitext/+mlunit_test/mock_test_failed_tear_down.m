classdef mock_test_failed_tear_down < mlunit_test.mock_test
    % MOCK_TEST_FAILED_SET_UP is a mock test_case with a broken tear_down
    %   used for the tests in test_test_case.
    %
    %  Example:
    %         run(gui_test_runner,
    %             'mock_test_failed_tear_down(''test_method'')');

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
    end

    methods
        function self = mock_test_failed_tear_down(varargin)
            self = self@mlunit_test.mock_test(varargin{:});
        end

        function self = tear_down(self) %#ok
            %   TEAR_DOWN is a mock tear_down 
            %       method, that is broken as it only class error(' ').
            %
            %  Example:
            %         test = mock_test_failed_tear_down('test_method');
            %         try
            %             test = run(test, default_test_result(self));
            %         catch
            %             assert(0);
            %         end;
            %         assert(strcmp('set_up test_method ', get_log(test)));
            %
            %  See also TEST_TEST_CASE/TEST_FAILED_TEAR_DOWN.

            error(' ');

        end
    end
end
