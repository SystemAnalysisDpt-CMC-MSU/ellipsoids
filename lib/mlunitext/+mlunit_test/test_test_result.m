classdef test_test_result < mlunitext.test_case&mlunit_test.AuxChecker
    % TEST_TEST_RESULT tests the class test_result.
    %
    % Example:
    %  run(gui_test_runner, 'test_test_result');
    %
    %  See also MLUNITEXT.TEST_RESULT.
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
            %  See also MLUNITEXT.TEST_RESULT.ADD_ERROR_WITH_STACK.
            
            import mlunitext.*;
            
            test = mlunit_test.mock_test('test_broken_method');
            result = run(test, self.result);
            error_list = get_error_list(result);
            error_lines = strread(char(error_list(2)), '%s', 'delimiter', '\n');
            assert_equals('Traceback (most recent call first): ', ...
                char(error_lines(1)));
            assert_equals(false, isempty(findstr('mock_test.m at line 94', ...
                char(error_lines(2)))));
            assert_equals(false, isempty(findstr('test_case.m at line 268', ...
                char(error_lines(3)))));
            assert_equals('Error:  , Identifier: ', char(error_lines(end)));
        end
        
        function self = test_get_errors_failures(self)
            % TEST_GET_ERRORS_FAILURES tests the methods
            % test_result.getNErrors and test_result.getNFailures.
            %
            % Example:
            %   run(gui_test_runner,
            %             'test_test_result(''test_get_errors_failures'');');
            %
            % See also MLUNITEXT.TEST_RESULT.GET_ERRORS,
            %   MLUNITEXT.TEST_RESULT.GET_FAILURES.
            
            start_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            add_error_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo error');
            add_failure_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo failure');
            stop_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            assert(1 == getNErrors(self.result));
            assert(1 == getNFailures(self.result));
        end
        
        function self = test_get_tests_run(self)
            % TEST_GET_TESTS_RUN tests the method
            %   test_result.getNTestsRun.
            %
            % Example:
            %   run(gui_test_runner,
            %       'test_test_result(''test_get_tests_run'');');
            %
            %  See also MLUNITEXT.TEST_RESULT.GET_TESTS_RUN.
            %
            start_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            add_success(self.result, ...
                mlunit_test.mock_test('test_method'));
            stop_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            assert(1 == getNTestsRun(self.result));
        end
        
        function self = test_result(self)
            % TEST_RESULT tests the results of test_result.
            %
            % Example:
            %   run(gui_test_runner,
            %             'test_test_result(''test_result'');');
            %
            % See also MLUNITEXT.TEST_RESULT.
            %
            import mlunitext.*;
            %
            testObj=mlunit_test.mock_test('test_method');
            start_test(self.result,testObj);
            add_success(self.result,testObj);
            self.result.stop_test(testObj);
            assert_equals(1, isPassed(self.result));
            check(0,0);
            add_error_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo error');
            check(1,0);
            add_failure_by_message(self.result, ...
                mlunit_test.mock_test('test_method'), 'foo failure');
            check(1,1);
            stop_test(self.result, ...
                mlunit_test.mock_test('test_method'));
            function check(varargin)
                self.checkResultReport(self.result,1,varargin{:});
            end
        end
    end
end