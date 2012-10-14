classdef test_function_test_case < mlunitext.test_case
    % TEST_FUNCTION_TEST_CASE tests the class function_test_case.
    %
    %  Example:
    %         run(gui_test_runner, 'test_function_test_case');

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
    end

    methods
        function self = test_function_test_case(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end

        function self = test_fixture(self)
            % TEST_FUNCTION_TEST_CASE/TEST_FIXTURE tests the fixture of a
            % function_test_case with all test methods within on .m-file.
            %
            %  Example:
            %         run(gui_test_runner, 'test_function_test_case(''test_fixture'')');
            %
            %  See also MLUNIT_TEST.TEST_FUNCTION_TEST_CASE.

            import mlunitext.*;

            test = function_test_case(@() assert(1), @()0, @()0);
            result = run(test);
            assert_equals(1, get_tests_run(result));
        end
        %
        function self = test_run(self)
            %test_function_test_case/test_fixture tests the run method of
            %function_test_case.
            %
            %  Example:
            %         run(gui_test_runner, 'test_function_test_case(''test_run'')');
            %
            %  See also MLUNIT_TEST.TEST_FUNCTION_TEST_CASE.

            import mlunitext.*;

            test = function_test_case(@() assert(true));
            result = run(test);
            assert_equals(0, get_failures(result));
            assert_equals(0, get_errors(result));
            assert_equals(1, get_tests_run(result));
        end
    end
end