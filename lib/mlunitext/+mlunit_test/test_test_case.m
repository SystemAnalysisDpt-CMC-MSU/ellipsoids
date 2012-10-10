classdef test_test_case < mlunitext.test_case
    %test_test_case tests the class test_case.
    %
    %  Example:
    %         run(gui_test_runner, 'test_test_case');

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties (Access=private)
        result = []
    end

    methods
        function self = test_test_case(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function set_up(self)
            % SET_UP sets up the fixture for test_test_case.
            %
            %  Example:
            %         run(gui_test_runner, 'test_test_case');

            import mlunitext.*;

            self.result = test_result;
        end
        %
        function test_count_test_cases(self)
            % TEST_COUNT_TEST_CASES tests the method
            %  test_case.count_test_cases, whose return value has to be one.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_count_test_cases'');');
            %
            %  See also MLUNIT.TEST_CASE.COUNT_TEST_CASES.

            assert(1 == count_test_cases(self));
        end
        %
        function test_create(self)
            % TEST_CREATE tests the constructor of test_case.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_creates'');');
            %
            %  See also MLUNIT.TEST_CASE.

            import mlunitext.*;

            error = 0;
            try
                test_case('foo', 'mock_test');
                error = 1;
            catch
            end;
            assert_equals(0, error);

            error = 0;
            try
                test_case('', 'mock_test');
            catch
            end;
            assert_equals(0, error);
        end
        %
        function test_default_result(self)
            % TEST_DEFAULT_RESULT tests the method
            %   test_case.default_test_result.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_default_result'');');
            %
            %  See also MLUNIT.TEST_CASE.DEFAULT_TEST_RESULT.

            t = mlunit_test.mock_test('test_method');
            assert(isa(default_test_result(t), 'mlunit.test_result'));
        end
        %
        function test_failed_result(self)
            % TEST_FAILED_RESULT tests the behaviour of
            %   test_case.run, if the test method fails.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_failed_result'');');
            %
            %  See also MLUNIT.TEST_CASE.RUN.

            import mlunitext.*;

            test = mlunit_test.mock_test('test_broken_method');
            self.result = run(test, self.result);
            assert_equals('mlunitext.test_result run=1 errors=1 failures=0', ...
                summary(self.result));
            assert(strcmp('set_up tear_down ', get_log(test)));
        end
        %
        function test_failed_set_up(self)
            % TEST_FAILED_SET_UP tests the behaviour of
            %   test_case.run, if the set_up method fails.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_failed_set_up'');');
            %
            %  See also MLUNIT.TEST_CASE.RUN.

            test = mlunit_test.mock_test_failed_set_up('test_method');
            try
                run(test, default_test_result(self));
            catch
                assert(0);
            end;
            assert(strcmp('', get_log(test)));
        end
        %
        function test_failed_tear_down(self)
            % TEST_FAILED_TEAR_DOWN tests the behaviour of
            %   test_case.run, if the tear_down method fails.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_failed_tear_down'');');
            %
            %  See also MLUNIT.TEST_CASE.RUN.

            test = mlunit_test.mock_test_failed_tear_down('test_method');
            try
                run(test, default_test_result(self));
            catch
                assert(0);
            end;
            assert(strcmp('set_up test_method ', get_log(test)));
        end
        %
        function test_result(self)
            % TEST_RESULT tests the method test_case.run and
            %   the test_result.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_result'');');
            %
            %  See also MLUNIT.TEST_CASE.RUN, MLUNIT.TEST_RESULT.

            test = mlunit_test.mock_test('test_method');
            self.result = run(test, self.result);
            assert(strcmp('mlunitext.test_result run=1 errors=0 failures=0', ...
                summary(self.result)));
        end
        %
        function test_run(self)
            % TEST_RESULT tests the method test_case.run and
            %   the method test_result.get_tests_run.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_case(''test_run'');');
            %
            %  See also MLUNIT.TEST_CASE.RUN,
            %           MLUNIT.TEST_RESULT.GET_TESTS_RUN.

            import mlunitext.*;

            test = mlunit_test.mock_test('test_method');
            result = run(test);
            assert_equals(1, get_tests_run(result));
        end
        %
        function test_template_method(self)
            % TEST_RESULT tests the method test_case.run.
            %
            %  Example:
            %         run(gui_test_runner, 
            %             'test_test_case(''test_template_method'');');
            %
            %  See also MLUNIT.TEST_CASE.RUN.

            test = mlunit_test.mock_test('test_method');
            run(test, self.result);
            assert(strcmp(get_log(test), 'set_up test_method tear_down '));
        end
    end
end