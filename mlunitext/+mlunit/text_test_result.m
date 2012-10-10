classdef text_test_result < mlunit.test_result
% TEXT_TEST_RESULT class is inherited from test_result and prints
%  formatted test results to a stream. The constructor creates an 
%  object while the parameter verbosity defines, how much output is written. 
%  Possible values are 0, 1 and 2. 
%
%  Example:
%    Output all results to the Matlab Command Window:
%         result = text_test_result(1, 0)
%
%  See also MLUNIT.TEST_RESULT.

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
        stream = 0;
        verbosity = 0;
        dots = 0;
        show_all = 0;
    end

    methods
        function self = text_test_result(varargin)
            import modgen.common.throwerror;
            if nargin == 1
                if ~isa(varargin{1},class(self))
                    throwerror('wrongInput',...
                        'Invalid number or type of arguments');
                end
                %
                %% Copy constructor
                %
                self.stream = varargin{1}.stream;
                self.verbosity = varargin{1}.verbosity;
                self.dots = varargin{1}.dots;
                self.show_all = varargin{1}.show_all;
            elseif nargin == 2
                %% Regular constructor
                %
                self.stream = varargin{1};
                self.verbosity = varargin{2};
                if (self.verbosity == 1)
                    self.dots = 1;
                    self.show_all = 0;
                elseif (self.verbosity > 1)
                    self.dots = 0;
                    self.show_all = 1;
                else
                    self.dots = 0;
                    self.show_all = 0;
                end;
            else
                throwerror('wrongInput','Too many arguments');
            end
        end

        function self = add_error(self, test, error)
            % ADD_ERROR calls the inherited method from 
            % test_result and writes out an 'E' (verbosity == 1) or 'ERROR' 
            % (verbosity == 2) to the stream.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunit.test_case[1,1] - test to which the errors
            %           are added
            %       error: MException[1,1] - an error object to add to the
            %           test            
            % Example:
            %    add_error is usually only called by the run method of 
            %    test_case, see test_case.run:
            %         result = add_error(result, self, stacktrace);
            %
            %  See also MLUNIT.TEST_RESULT.ADD_ERROR, MLUNIT.TEST_CASE.RUN.

            self = add_error@mlunit.test_result(self, test, error);
            if (self.dots)
                fprintf(self.stream,'E');
            elseif (self.show_all)
                fprintf(self.stream,'ERROR\n');
            end;
        end

        function self = add_failure(self, test, failure)
            % ADD_FAILURE calls the inherited method from 
            % test_result and writes out an 'F' (verbosity == 1) or 
            % 'FAILURE' (verbosity == 2) to the stream.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunit.test_case[1,1] - test to which the errors
            %           are added
            %       failure: MException[1,1] - a failure object to add to the
            %           test            
            % Example:
            %    add_failure is usually only called by the run method of 
            %    test_case, see test_case.run:
            %         result = add_failure(result, self, errmsg);
            %
            %  See also MLUNIT.TEST_RESULT.ADD_FAILURE, 
            %           MLUNIT.TEST_CASE.RUN.

            self = add_failure@mlunit.test_result(self, test, failure);
            if (self.dots)
                fprintf(self.stream,'F');
            elseif (self.show_all)
                fprintf(self.stream,'FAIL\n');
            end;
        end

        function self = add_success(self, test)
            % ADD_SUCCESS calls the inherited method from 
            % test_result and writes out an '.' (verbosity == 1) or 'OK' 
            % (verbosity == 2) to the stream.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunit.test_case[1,1] - test to which the
            %           successes are added
            % Example:
            %    add_success is usually only called by the run method 
            %    of test_case, see test_case.run:
            %         result = add_success(result, self);
            %
            % See also MLUNIT.TEST_RESULT.ADD_SUCCESS, 
            %           MLUNIT.TEST_CASE.RUN.

            self = add_success@mlunit.test_result(self, test);
            if (self.dots)
                fprintf(self.stream,'.');
            elseif (self.show_all)
                fprintf(self.stream,'OK\n');
            end;
        end
        %
        function print_error_list(self, prefix, errors)
            % PRINT_ERROR_LIST is a helper function for
            % text_test_result.print_errors. It iterates through 
            % all errors in errors and writes them to 
            %  the stream. prefix is a string, which is written before 
            %  each error or failure, to differ between them.
            %
            %  Input:
            %   regular:
            %       self:
            %       prefix: char[1,] - prefix used for displaying the
            %           errors
            %       errors: cell[1,] of char[1,] - list of error messages
            %
            %  Example:
            %    print_error_list is called twice in 
            %    text_test_result.print_errors, e.g. for the list of 
            %    failures:
            %         print_error_list(self, 'FAILURE', get_failure_list(self));
            %
            %  See also MLUNIT.TEXT_TEST_RESULT.PRINT_ERRORS.
            
            for i = 1:size(errors, 1)
                mlunit.logprintf('info',repmat('=',1,70));
                mlunit.logprintf('info','%s: %s', ...
                    prefix, errors{i, 1});
                mlunit.logprintf('info',repmat('-',1,70));
                mlunit.logprintf('info','%s', errors{i, 2});
            end;
        end

        function print_errors(self)
            % PRINT_ERRORS writes the description of all 
            % errors and failures to the stream.
            %
            % Example:
            %    print_errors is called for example from 
            %    text_test_runner.run:
            %         print_errors(result);
            %
            %  See also MLUNIT.TEXT_TEST_RUNNER.RUN.

            if ((self.dots) || (self.show_all))
                fprintf(self.stream,'\n');
            end;
            print_error_list(self, 'ERROR', get_error_list(self));
            print_error_list(self, 'FAIL', get_failure_list(self));
        end

        function self = start_test(self, test)
            % START_TEST calls the inherited method from 
            % test_result and writes out the name of the test to the stream
            % (if verbosity==2) or to the logger at DEBUG level
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunit.test_case - test to start
            %
            %  Example:
            %    start_test is usually called by test_case.run to signal 
            %    the start of the test execution to the test result:
            %         result = start_test(result, self);
            %
            %  See also MLUNIT.TEST_RESULT.START_TEST, 
            %           MLUNIT.TEST_CASE.RUN.

            self = start_test@mlunit.test_result(self, test);
            if (self.show_all)
                fprintf(self.stream,[str(test), ' ... ']);
            else
                mlunit.logprintf('debug',['=== START ', str(test)]);
            end;
        end

        function self = stop_test(self, test)
            % STOP_TEST calls the inherited method from 
            % test_result and writes out the name of the test to the logger
            % at DEBUG level
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunit.test_case - test to stop
            %
            % Example:
            %    stop_test is usually called by test_case.run to signal 
            %    the end of the test execution to the test result:
            %         result = end_test(result, self);
            %
            % See also MLUNIT.TEST_RESULT.END_TEST, 
            %           MLUNIT.TEST_CASE.RUN.

            self = stop_test@mlunit.test_result(self, test);
            mlunit.logprintf('debug',['===  END  ', str(test)]);
        end
    end
end