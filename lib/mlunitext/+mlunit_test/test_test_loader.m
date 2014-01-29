classdef test_test_loader < mlunitext.test_case
    % TEST_TEST_LOADER tests the class test_loader.
    %
    %  Example:
    %         run(gui_test_runner, 'test_test_loader');
    %
    %  See also MLUNITEXT.TEST_LOADER.

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
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
            %  See also MLUNITEXT.TEST_LOADER.GET_TEST_CASE_NAMES.

            import mlunitext.*;

            testLoaderObj = test_loader;
            testMethodNameList = get_test_case_names(testLoaderObj,...
                'mlunit_test.mock_test');
            assert(modgen.common.iscol(testMethodNameList));
            %
            assert(size(testMethodNameList, 1) > 0);
            assert_equals(size(testMethodNameList, 1),...
                sum(strncmp(testMethodNameList, 'test', 4)));

            testMethodNameList = get_test_case_names(testLoaderObj,...
                'mlunit_test.mock_test_failed_set_up');
            assert_equals(3, sum(strncmp(testMethodNameList, 'test', 4)));
            %
        end
        %
        function self = test_load_tests_from_test_case(self)
            % TEST_LOAD_TESTS_FROM_TEST_CASE tests the 
            %   method test_loader.load_tests_from_test_case.
            %
            %  Example:
            %         run(gui_test_runner, 
            %             'test_test_loader(''test_load_tests_from_test_case'');');
            %
            %  See also MLUNITEXT.TEST_LOADER.LOAD_TESTS_FROM_TEST_CASE.

            import mlunitext.*;

            testLoader = test_loader;
            suite = load_tests_from_test_case(testLoader, 'mlunit_test.mock_test');
            assert(modgen.common.isrow(suite.tests));            
            result = test_result;
            result = run(suite, result);
            assert_equals(3, getNTestsRun(result));
            assert_equals(1, getNErrors(result));
            %
            testLoader=mlunitext.test_loader;
            suite = load_tests_from_test_case(testLoader,...
                'mlunit_test.mock_test');
            assert(modgen.common.isrow(suite.tests));
            %
        end
    end
end