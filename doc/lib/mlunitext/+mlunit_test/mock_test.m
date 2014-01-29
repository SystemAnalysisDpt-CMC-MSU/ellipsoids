classdef mock_test < mlunitext.test_case
    % MOCK_TEST is a mock test_case used for the tests in test_test_case.
    %
    % Example:
    % 	run(gui_test_runner, 'mock_test(''test_method'')');
    %
    % See also TEST_TEST_CASE.
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    properties
        log = '';
    end
    
    methods
        function self = mock_test(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function tear_down(self)
            % TEAR_DOWN is a mock tear_down, that adds to the
            % member variable log the string 'tear_down '.
            %
            % Example:
            %   test = mock_test('test_method');
            %   test = run(test, self.result);
            %   assert(strcmp(get_log(test),
            %       'set_up test_method tear_down '));
            %
            %  See also MOCK_TEST, TEST_TEST_CASE.
            
            self.log = [self.log, 'tear_down '];
        end
        
        function test_method(self)
            % TEST_METHOD is a mock test method, that adds to the
            %  member variable log the string 'test_method '.
            %
            %  Example:
            %   test = mock_test('test_method');
            %   test = run(test, self.result);
            %   assert(strcmp(get_log(test),
            %       'set_up test_method tear_down '));
            %
            %  See also MOCK_TEST, TEST_TEST_CASE.
            
            self.log = [self.log, 'test_method '];
        end
        
        function log = get_log(self)
            % GET_LOG returns the member variable log.
            %
            %  Example:
            %         log = get_log(self);
            %
            %  See also TEST_TEST_CASE/TEST_FAILED_RESULT,
            %           TEST_TEST_CASE/TEST_FAILED_SET_UP,
            %           TEST_TEST_CASE/TEST_FAILED_TEAR_DOWN,
            %           TEST_TEST_CASE/TEST_TEMPLATE_METHOD.
            
            log = self.log;
        end
        
        function set_up(self)
            % SET_UP is a mock set_up, that sets the member
            % variable log to 'set_up '.
            %
            %  Example:
            %         test = mock_test('test_method');
            %         test = run(test, self.result);
            %         assert(strcmp(get_log(test),
            %                'set_up test_method tear_down '));
            %
            %  See also MOCK_TEST, TEST_TEST_CASE.
            
            self.log = 'set_up ';
        end
        
        function test_broken_method(self) %#ok
            % TEST_BROKEN_METHOD is a mock test method, that is
            % broken as it only class error(' ').
            %
            %  Example:
            %         test = mock_test('test_broken_method');
            %         [test, self.result] = run(test, self.result);
            %         assert_equals('test_result run=1 errors=1 failures=0',
            %                       getReport(self.result));
            %         assert(strcmp('set_up tear_down ', get_log(test)));
            %
            %  See also MOCK_TEST, TEST_TEST_CASE.
            
            error(' ');
        end
        
        function test_method_no_return(self)
            % MOCK_TEST_TEST_METHOD_NO_RETURN is a mock test method that does
            % not return self. This became possible since test_method became a
            % handle class.
            
            self.log = [self.log, 'test_method_no_return '];
        end
    end
end
