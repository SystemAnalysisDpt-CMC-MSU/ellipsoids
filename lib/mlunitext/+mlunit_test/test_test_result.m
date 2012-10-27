classdef test_test_result < mlunitext.test_case
    % TEST_TEST_RESULT tests the class test_result.
    %
    % Example:
    %  run(gui_test_runner, 'test_test_result');
    %
    %  See also MLUNIT.TEST_RESULT.
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    properties (Access=private)
        result = 0;
    end
    
    methods
        function self = test_test_result(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = set_up(self)
            % SET_UP sets up the fixture for
            %    test_test_result.
            %
            %  Example:
            %         run(gui_test_runner, 'test_test_result');
            
            import mlunitext.*;
            
            self.result = test_result;
        end
        
        function self = test_add_error_with_stack(self)
            % TEST_RESULT_LIST tests the method
            % test_result.add_error_with_stack.
            %
            % Example:
            %         run(gui_test_runner,
            %             'test_test_result(''test_add_error_with_stack'');');
            %
            %  See also MLUNIT.TEST_RESULT.ADD_ERROR_WITH_STACK.
            
            import mlunitext.*;
            
            test = mlunit_test.mock_test('test_broken_method');
            result = run(test, self.result);
            error_list = get_error_list(result);
            error_lines = strread(char(error_list(2)), '%s', 'delimiter', '\n');
            assert_equals('Traceback (most recent call first): ', ...
                char(error_lines(1)));
            assert_equals(false, isempty(findstr('mock_test.m at line 94', ...
                char(error_lines(2)))));
            assert_equals(false, isempty(findstr('test_case.m at line 141', ...
                char(error_lines(3)))));
            assert_equals('Error:  , Identifier: ', char(error_lines(end)));
        end
        
        function self = test_get_errors_failures(self)
            % TEST_GET_ERRORS_FAILURES tests the methods
            % test_result.get_errors and test_result.get_failures.
            %
            % Example:
            %   run(gui_test_runner,
            %             'test_test_result(''test_get_errors_failures'');');
            %
            % See also MLUNIT.TEST_RESULT.GET_ERRORS,
            %   MLUNIT.TEST_RESULT.GET_FAILURES.
            
            self.result = start_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            self.result = add_error_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo error');
            self.result = add_failure_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo failure');
            self.result = stop_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            assert(1 == get_errors(self.result));
            assert(1 == get_failures(self.result));
        end
        
        function self = test_get_tests_run(self)
            % TEST_GET_TESTS_RUN tests the method
            %   test_result.get_tests_run.
            %
            % Example:
            %   run(gui_test_runner,
            %       'test_test_result(''test_get_tests_run'');');
            %
            %  See also MLUNIT.TEST_RESULT.GET_TESTS_RUN.
            
            self.result = start_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            self.result = add_success(self.result, ...
                mlunit_test.mock_test('test_method'));
            self.result = stop_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            assert(1 == get_tests_run(self.result));
        end
        
        function self = test_result(self)
            % TEST_RESULT tests the results of test_result.
            %
            % Example:
            %   run(gui_test_runner,
            %             'test_test_result(''test_result'');');
            %
            % See also MLUNIT.TEST_RESULT.
            %
            import mlunit.*;
            %
            self.result = start_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            self.result = add_success(self.result, ...
                mlunit_test.mock_test('test_method'));
            assert_equals(1, was_successful(self.result));
            assert_equals('mlunitext.test_result run=1 errors=0 failures=0', ...
                summary(self.result));
            check(0,0);
            self.result = add_error_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo error');
            assert_equals('mlunitext.test_result run=1 errors=1 failures=0', ...
                summary(self.result));
            check(1,0);
            self.result = add_failure_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo failure');
            assert_equals('mlunitext.test_result run=1 errors=1 failures=1', ...
                summary(self.result));
            check(1,1);
            self.result = stop_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            self.result = set_should_stop(self.result);
            assert_equals(1, get_should_stop(self.result));
            function check(nExpErrors,nExpFailures)
                [nErrors,nFailures]=self.result.getErrorFailCount();
                assert(nErrors==nExpErrors);
                assert(nFailures==nExpFailures);
            end
        end
    end
end