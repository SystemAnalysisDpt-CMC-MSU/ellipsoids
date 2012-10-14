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
        fSetUp
        fTearDown
        fTest
    end
    %
    methods
        function self = function_test_case(fTest, ...
                fSetUp, fTearDown)
            import modgen.common.type.simple.checkgen;
            if (nargin == 0)
                fTest = @()0;
            else
                checkgen(fTest,'isfunction(x)');
                if nargin ==1
                    fSetUp = @()0;
                    fTearDown = @()0;
                else
                    checkgen(fSetUp,'isfunction(x)');
                    if nargin == 2
                        fTearDown = @()0;
                    else
                        checkgen(fTearDown,'isfunction(x)');
                    end
                end
            end
            %
            self.fTest = fTest;
            self.fSetUp = fSetUp;
            self.fTearDown = fTearDown;
        end
        
        function self = run_test(self)
            %function_test_case.run_test calls the fTest by the
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
            %
            self.fTest();
        end
        
        function self = set_up(self)
            %function_test_case.set_up calls the fSetUp every
            %time before a test is executed. Its purpose is to set up the
            %fixture.
            %
            %  Example:
            %    set_up is not called directly, but by the method
            %    test_case.run.
            %
            %  See also MLUNIT.TEST_CASE, MLUNIT.TEST_CASE.RUN.
            %
            if isa(self.fSetUp, 'function_handle')
                self.fSetUp();
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
            
            s = [func2str(self.fTest), '(', class(self), ')'];
        end
        
        function self = tear_down(self)
            %function_test_case.tear_down calls the fTearDown,
            %every time after a test is executed. Its purpose is to clean
            %up the fixture.
            %
            %  Example:
            %    tear_down is not called directly, but by the method
            %    test_case.run.
            %
            %  See also MLUNIT.TEST_CASE, MLUNIT.TEST_CASE.RUN.
            
            if isa(self.fTearDown, 'function_handle')
                self.fTearDown();
            end;
        end
    end
end