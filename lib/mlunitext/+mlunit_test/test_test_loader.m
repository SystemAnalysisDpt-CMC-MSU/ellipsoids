classdef test_test_loader < mlunitext.test_case
    % TEST_TEST_LOADER tests the class test_loader.
    %
    %  Example:
    %         run(gui_test_runner, 'test_test_loader');
    %
    %  See also MLUNIT.TEST_LOADER.

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
    end

    methods
        function self = test_test_loader(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end

        function self = test_get_test_case_names(self)
            % TEST_GET_TEST_CASE_NAMES tests the method
            %   test_loader.get_test_case_names.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_loader(''test_get_test_case_names'');');
            %
            %  See also MLUNIT.TEST_LOADER.GET_TEST_CASE_NAMES.

            import mlunitext.*;

            t = test_loader;
            n = get_test_case_names(t, 'mlunit_test.mock_test');
            assert(size(n, 1) > 0);
            assert_equals(size(n, 1), sum(strncmp(n, 'test', 4)));

            n = get_test_case_names(t, 'mlunit_test.mock_test_failed_set_up');
            % Inheritance is supported by class reflect with mlUnit 1.5.2
            assert_equals(3, sum(strncmp(n, 'test', 4)));
        end

        function self = test_load_tests_from_test_case(self)
            % TEST_LOAD_TESTS_FROM_TEST_CASE tests the 
            %   method test_loader.load_tests_from_test_case.
            %
            %  Example:
            %         run(gui_test_runner, 
            %             'test_test_loader(''test_load_tests_from_test_case'');');
            %
            %  See also MLUNIT.TEST_LOADER.LOAD_TESTS_FROM_TEST_CASE.

            import mlunitext.*;

            t = test_loader;
            suite = load_tests_from_test_case(t, 'mlunit_test.mock_test');
            result = test_result;
            result = run(suite, result);
            assert_equals(3, get_tests_run(result));
            assert_equals(1, get_errors(result));
        end
    end
end
