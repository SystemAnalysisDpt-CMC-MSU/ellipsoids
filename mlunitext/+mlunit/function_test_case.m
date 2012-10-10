classdef function_test_case < mlunit.test_case
    %The class function_test_case is a wrapper for single-function tests.
    %
    %  Example:
    %   test = function_test_case(@() assert(0 == sin(0)));
    %
    %  See also MLUNIT.TEST_CASE.
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    properties
        set_up_function
        tear_down_function
        test_function
    end
    
    methods
        function self = function_test_case(test_function, ...
                set_up_function, tear_down_function)
            if (nargin == 0)
                test_function = @() 0;
            end;
            if (nargin <= 1)
                set_up_function = @() 0;
                tear_down_function = @() 0;
            elseif (nargin == 2)
                tear_down_function = @() 0;
            end;
            
            self.test_function = test_function;
            self.set_up_function = set_up_function;
            self.tear_down_function = tear_down_function;
        end
        
        function self = run_test(self)
            %function_test_case.run_test calls the test_function by the
            %function handle.
            %
            %  Example:
            %         test = function_test_case(@() assert(0 == sin(0)));
            %         [test, result] = run(test); % Usually run_test (as
            %                                     % every test method) is
            %                                     % not called directly,
            %                                     % but through the method
            %                                     % test_case.run.
            %         summary(result)
            %
            %  See also MLUNIT.TEST_CASE.
            
            self.test_function();
        end
        
        function self = set_up(self)
            %function_test_case.set_up calls the set_up_function every
            %time before a test is executed. Its purpose is to set up the
            %fixture.
            %
            %  Example:
            %    set_up is not called directly, but by the method
            %    test_case.run.
            %
            %  See also MLUNIT.TEST_CASE, MLUNIT.TEST_CASE.RUN.
            
            if (strcmp(class(self.set_up_function), 'function_handle'))
                self.set_up_function();
            end;
        end
        
        function s = str(self)
            %function_test_case.str return a string with the method and
            %class name of the test.
            %
            %  Example:
            %    Suppose the following test method is defined in a file,
            %           function test_method
            %               assert(0 == sin(0));
            %           end
            %    and a function_test_case is created at the command line,
            %           >> test = function_test_case(@test_method);
            %    then str results in the following output:
            %           >> test.str
            %           test_method(function_test_case)
            
            s = [func2str(self.test_function), '(', class(self), ')'];
        end
        
        function self = tear_down(self)
            %function_test_case.tear_down calls the tear_down_function,
            %every time after a test is executed. Its purpose is to clean
            %up the fixture.
            %
            %  Example:
            %    tear_down is not called directly, but by the method
            %    test_case.run.
            %
            %  See also MLUNIT.TEST_CASE, MLUNIT.TEST_CASE.RUN.
            
            if (strcmp(class(self.tear_down_function), 'function_handle'))
                self.tear_down_function();
            end;
        end
    end
end