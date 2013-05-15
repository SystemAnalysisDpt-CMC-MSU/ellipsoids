classdef text_test_result < mlunitext.test_result
    % TEXT_TEST_RESULT class is inherited from test_result and prints
    %  formatted test results to a stream. The constructor creates an
    %  object while the parameter verbosity defines, how much output is written.
    %  Possible values are 0, 1 and 2.
    %
    %  Example:
    %    Output all results to the Matlab Command Window:
    %         result = text_test_result(1, 0)
    %
    %  See also MLUNITEXT.TEST_RESULT.
    %
    % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2012-2013$
    
    properties
        textOutFid = 0;
        verbosityLevel = 0;
        isDotDispMode = 0;
        isAllShown = 0;
    end
    %
    methods
        function self=text_test_result(varargin)
            % TEXT_TEST_RESULT creates an instance of TEXT_TEST_RESULT
            % class
            %
            % Case#1 (copy-constructor)
            %   Input:
            %       regular:
            %           inpObj: mlunitext.text_test_result[1,1] - an object to
            %               copy
            %
            %
            % Case#2 (regular-constructor)
            %   Input:
            %       regular:
            %           textOutFid: double[1,1] - integer fileId used by
            %               internal fprintf command, textOutFid=1 will
            %               cause all output to be printed to the console
            %           verbosityLevel: double[1,1] - integer verbosity
            %               level, can take one of the following three
            %               values: {0,1,2} where
            %                   0 - nothing is displayed in console
            %                   1 - only dots are displayed
            %                   2 - maximum amount of information is
            %                       displayed
            %
            %
            %
            import modgen.common.throwerror;
            import modgen.common.type.simple.checkgen;
            if nargin == 1
                if ~isa(varargin{1},class(self))
                    throwerror('wrongInput',...
                        'Invalid number or type of arguments');
                end
                %
                %% Copy constructor
                %
                self.textOutFid = varargin{1}.textOutFid;
                self.verbosityLevel = varargin{1}.verbosityLevel;
                self.isDotDispMode = varargin{1}.isDotDispMode;
                self.isAllShown = varargin{1}.isAllShown;
            elseif nargin == 2
                %% Regular constructor
                %
                textOutFid = varargin{1};
                verbosityLevel = varargin{2};
                %
                checkgen(textOutFid,...
                    @(x)isscalar(x)&&isa(x,'double')&&(x>0)&&(fix(x)==x));
                checkgen(verbosityLevel,...
                    @(x)isscalar(x)&&isa(x,'double')&&(x==0||x==1||x==2));
                
                self.textOutFid=textOutFid;
                self.verbosityLevel=verbosityLevel;
                %
                if (self.verbosityLevel == 1)
                    self.isDotDispMode = 1;
                    self.isAllShown = 0;
                elseif (self.verbosityLevel > 1)
                    self.isDotDispMode = 0;
                    self.isAllShown = 1;
                else
                    self.isDotDispMode = 0;
                    self.isAllShown = 0;
                end;
            else
                throwerror('wrongInput','Too many arguments');
            end
        end
        
        function add_error_by_message(self, test, error)
            % ADD_ERROR calls the inherited method from
            % test_result and writes out an 'E' (verbosityLevel == 1) or 'ERROR'
            % (verbosityLevel == 2) to the textOutFid.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunitext.test_case[1,1] - test to which the errors
            %           are added
            %       error: MException[1,1] - an error object to add to the
            %           test
            % Example:
            %    add_error is usually only called by the run method of
            %    test_case, see test_case.run:
            %         result = add_error(result, self, stacktrace);
            %
            %  See also MLUNITEXT.TEST_RESULT.ADD_ERROR, MLUNITEXT.TEST_CASE.RUN.
            
            add_error_by_message@mlunitext.test_result(self,...
                test, error);
            if (self.isDotDispMode)
                fprintf(self.textOutFid,'E');
            elseif (self.isAllShown)
                fprintf(self.textOutFid,'ERROR\n');
            end;
        end
        
        function add_failure_by_message(self, test, failure)
            % ADD_FAILURE calls the inherited method from
            % test_result and writes out an 'F' (verbosityLevel == 1) or
            % 'FAILURE' (verbosityLevel == 2) to the textOutFid.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunitext.test_case[1,1] - test to which the errors
            %           are added
            %       failure: MException[1,1] - a failure object to add to the
            %           test
            % Example:
            %    add_failure is usually only called by the run method of
            %    test_case, see test_case.run:
            %         result = add_failure(result, self, errmsg);
            %
            %  See also MLUNITEXT.TEST_RESULT.ADD_FAILURE,
            %           MLUNITEXT.TEST_CASE.RUN.
            
            add_failure_by_message@mlunitext.test_result(self,...
                test, failure);
            if (self.isDotDispMode)
                fprintf(self.textOutFid,'F');
            elseif (self.isAllShown)
                fprintf(self.textOutFid,'FAIL\n');
            end;
        end
        
        function add_success(self, test)
            % ADD_SUCCESS calls the inherited method from
            % test_result and writes out an '.' (verbosityLevel == 1) or 'OK'
            % (verbosityLevel == 2) to the textOutFid.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunitext.test_case[1,1] - test to which the
            %           successes are added
            % Example:
            %    add_success is usually only called by the run method
            %    of test_case, see test_case.run:
            %         result = add_success(result, self);
            %
            % See also MLUNITEXT.TEST_RESULT.ADD_SUCCESS,
            %           MLUNITEXT.TEST_CASE.RUN.
            add_success@mlunitext.test_result(self,test);
            self.checkIfScalar();
            if (self.isDotDispMode)
                fprintf(self.textOutFid,'.');
            elseif (self.isAllShown)
                fprintf(self.textOutFid,'OK\n');
            end;
        end
        %
        function print_error_list(self, prefix, errors)
            % PRINT_ERROR_LIST is a helper function for
            % text_test_result.print_errors. It iterates through
            % all errors in errors and writes them to
            %  the textOutFid. prefix is a string, which is written before
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
            %  See also MLUNITEXT.TEXT_TEST_RESULT.PRINT_ERRORS.
            for i = 1:size(errors, 1)
                mlunitext.logprintf('info',repmat('=',1,70));
                mlunitext.logprintf('info','%s: %s', ...
                    prefix, errors{i, 1});
                mlunitext.logprintf('info',repmat('-',1,70));
                mlunitext.logprintf('info','%s', errors{i, 2});
            end;
        end
        %
        function message=getErrorFailMessage(self)
            % GETERRORFAILMESSAGE generates a textual representation of
            % all errors and failures for a vector of test results
            %
            nRes=length(self);
            messageList=cell(1,nRes);
            for iRes=1:nRes
                messageList{iRes}=evalc('print_errors(self(iRes))');
            end
            message=[messageList{:}];
        end
        %
        function print_errors(self)
            % PRINT_ERRORS writes the description of all
            % errors and failures to the textOutFid.
            %
            % Example:
            %    print_errors is called for example from
            %    text_test_runner.run:
            %         print_errors(result);
            %
            %  See also MLUNITEXT.TEXT_TEST_RUNNER.RUN.
            self.checkIfScalar();
            if ((self.isDotDispMode) || (self.isAllShown))
                fprintf(self.textOutFid,'\n');
            end;
            print_error_list(self, 'ERROR', get_error_list(self));
            print_error_list(self, 'FAIL', get_failure_list(self));
        end
        
        function start_test(self, test)
            % START_TEST calls the inherited method from
            % test_result and writes out the name of the test to the textOutFid
            % (if verbosityLevel==2) or to the logger at DEBUG level
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunitext.test_case - test to start
            %
            %  Example:
            %    start_test is usually called by test_case.run to signal
            %    the start of the test execution to the test result:
            %         result = start_test(result, self);
            %
            %  See also MLUNITEXT.TEST_RESULT.START_TEST,
            %           MLUNITEXT.TEST_CASE.RUN.
            
            start_test@mlunitext.test_result(self, test);
            if (self.isAllShown)
                fprintf(self.textOutFid,[str(test), ' ... ']);
            else
                mlunitext.logprintf('debug',['=== START ', str(test)]);
            end;
        end
        
        function stop_test(self, test)
            % STOP_TEST calls the inherited method from
            % test_result and writes out the name of the test to the logger
            % at DEBUG level
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunitext.test_case - test to stop
            %
            % Example:
            %    stop_test is usually called by test_case.run to signal
            %    the end of the test execution to the test result:
            %         result = end_test(result, self);
            %
            % See also MLUNITEXT.TEST_RESULT.END_TEST,
            %           MLUNITEXT.TEST_CASE.RUN.
            stop_test@mlunitext.test_result(self, test);
            mlunitext.logprintf('debug',['===  END  ', str(test)]);
        end
    end
end
