classdef test_result<handle
    % TEST_RESULT collects test results of executed tests. As
    %  in the other testing frameworks of the xUnit family the framework
    %  differs between failure and error. A failure is raised by an
    %  assertion, that means by the method assert, while an error is
    %  raised by the Matlab environment, for example through a syntax
    %  error.
    %
    %  Example:
    %   result = test_result;
    %
    %  See also MLUNIT.ASSERT,
    %           MLUNIT.ASSERT_EQUALS,
    %           MLUNIT.ASSERT_NOT_EQUALS,
    %           MLUNIT.TEXT_TEST_RESULT.
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    properties (SetAccess=private)
        tests_run = 0;
        errors = {};
        failures = {};
        should_stop = 0;
    end
    
    methods
        function self=test_result(varargin)
        end
        function self = add_error(self, testName, meObj)
            % ADD_ERROR_WITH_STACK adds an error to the test result
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunit.test_case[1,1] - test to which the errors
            %           are added
            %       meObj: MException[1,1] - an error object to add to the
            %           test
            %
            % Example:
            %   result = add_error_with_stack(result, self, lasterror);
            %
            % See also MLUNIT.TEST_RESULT.ADD_ERROR, MLUNIT.TEST_CASE.RUN.
            %
            [message,stacktrace]=modgen.exception.me.obj2str(meObj);
            stacktrace = sprintf('%s\n', stacktrace);
            errMsg=['Traceback (most recent call first): ', ...
                stacktrace, ...,
                'Error: ', ...
                message ', Identifier: ',meObj.identifier];
            self = self.add_error_by_message(testName,errMsg);
        end
        
        function self = add_error_by_message(self, testName, errorMsg)
            % ADD_ERROR adds an error to the test result based on the
            % error message
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunit.test_case[1,1] - test to which the errors
            %           are added
            %       errorMsg: char[1,] - an error message
            %
            % Example:
            %   add_error is usually only called by the run method of
            %   test_case, see test_case.run:
            %       result = add_error(result, self, stacktrace);
            %
            %  See also MLUNIT.TEST_CASE.RUN.
            %
            if ~ischar(errorMsg)
                modgen.common.throwerror('wrongInput',...
                    'errorMsg is expected to be a character array');
            end
            newlines = sprintf('\n\n');
            if isempty(strfind(errorMsg, newlines))
                errorMsg = sprintf('%s\n\n', errorMsg);
            end;
            last = size(self.errors, 1);
            self.errors{last + 1, 1} = testName.str();
            self.errors{last + 1, 2} = errorMsg;
        end
        
        function self = add_failure(self, testName, meObj)
            % ADD_FAILURE adds a failure for the test result
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunit.test_case[1,1] - test to which the errors
            %           are added
            %       meObj: MException[1,1] - a failure object to add to the
            %           test
            %
            %  Example:
            %   add_failure is usually only called by the run method of
            %   test_case, see test_case/run:
            %       result = add_failure(result, self, errmsg);
            %
            %  See also TEST_CASE/RUN.
            
            [message,stacktrace]=modgen.exception.me.obj2str(meObj);
            self.add_failure_by_message(testName,[message,stacktrace]);
        end
        %
        function self = add_failure_by_message(self, testName, failMsg)
            % ADD_FAILURE adds a failure to the test result based on the
            % failure message
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunit.test_case[1,1] - test to which the errors
            %           are added
            %       failMsg: char[1,] - failure message
            %
            %  Example:
            %   add_failure is usually only called by the run method of
            %   test_case, see test_case/run:
            %       result = add_failure(result, self, errmsg);
            %
            %  See also TEST_CASE/RUN.
            if ~ischar(failMsg)
                modgen.common.throwerror('wrongInput',...
                    'failMsg is expected to be a character array');
            end
            last = size(self.failures, 1);
            self.failures{last + 1, 1} = testName.str();
            self.failures{last + 1, 2} = failMsg;
        end        
        %
        function self = add_success(self, ~)
            % ADD_SUCCESS is an empty method for classes, which
            %   might do some action on a successful test.
            %
            % Example:
            %   ADD_SUCCESS is usually only called by the run method of
            %   test_case, see test_case.run:
            %       result = add_success(result, self);
            %
            %  See also MLUNIT.TEXT_TEST_RESULT.ADD_SUCCESS,
            %           MLUNIT.TEST_CASE.RUN.
        end
        
        function errors = get_error_list(self)
            % GET_ERROR_LIST returns a cell array of tests and
            %   errors.
            %
            %  Example:
            %    get_error_list is called for example from
            %    text_test_result.print_errors:
            %         get_error_list(self)
            %
            %  See also MLUNIT.TEXT_TEST_RESULT.PRINT_ERRORS.
            
            errors = self.errors;
        end
        
        function errors = get_errors(self)
            % GET_ERRORS returns the number of errors.
            %
            %  Example:
            %    get_error_list is called for example from
            %    text_test_result.run:
            %         get_errors(self)
            %
            %  See also MLUNIT.TEXT_TEST_RESULT.RUN.
            
            errors = size(self.errors, 1);
        end
        
        function failures = get_failure_list(self)
            % GET_FAILURE_LIST returns a cell array of tests
            %   and failures.
            %
            % Example:
            %   get_error_list is called for example from
            %   text_test_result.print_errors:
            %       get_failure_list(self)
            %
            %  See also MLUNIT.TEXT_TEST_RESULT.PRINT_ERRORS.
            
            failures = self.failures;
        end
        
        function failures = get_failures(self)
            % GET_ERRORS returns the number of failures.
            %
            % Example:
            %    get_error_list is called for example from
            %    text_test_result.run:
            %         get_errors(self)
            %
            % See also MLUNIT.TEXT_TEST_RESULT.RUN.
            
            failures = size(self.failures, 1);
        end
        
        function should_stop = get_should_stop(self)
            % GET_SHOULD_STOP returns whether the test should
            %   stop or not.
            %
            % Example:
            %    get_should_stop is called for example from test_suite.run:
            %         get_should_stop(result)
            %
            % See also MLUNIT.TEST_SUITE.RUN.
            
            should_stop = self.should_stop;
        end
        
        function tests_run = get_tests_run(self)
            % TESTS_RUN returns the number of tests executed.
            %
            % Example:
            %    get_tests_run is called for example from
            %    text_test_runner.run:
            %         tests_run = get_tests_run(result);
            %
            %  See also MLUNIT.TEXT_TEST_RUNNER.RUN.
            
            tests_run = self.tests_run;
        end
        function self = set_should_stop(self)
            % SET_SHOULD_STOP indicates that the execution of
            % tests should stop.
            %
            % Example:
            %   result = test_result;
            %   % Do something, e.g. iterate through a number of tests, ...
            %   result = set_should_stop(result);
            
            self.should_stop = 1;
        end
        
        function self = start_test(self, test) %#ok
            % START_TEST indicates that a test will be started.
            %
            % Example:
            %    start_test is usually called by test_case.run to signal
            %    the start of the test execution to the test result:
            %         result = start_test(result, self);
            %
            %  See also MLUNIT.TEST_CASE.RUN.
            
            self.tests_run = self.tests_run + 1;
        end
        
        function self = stop_test(self, test) %#ok
            % STOP_TEST indicates that a test has been finished.
            %
            % Example:
            %    stop_test is usually called by test_case.run to signal
            %    the end of the test execution to the test result:
            %         result = stop_test(result, self);
            %
            % See also MLUNIT.TEST_CASE.RUN.
        end
        
        function s = summary(self)
            % SUMMARY returns a string with a summary of the
            % test result.
            %
            % Example:
            %         test = ... % e.g. created through my_test('test_foo')
            %         [test, result] = run(test);
            %         summary(result)
            
            s = sprintf('%s run=%d errors=%d failures=%d', ...
                class(self), self.tests_run, get_errors(self), ...
                get_failures(self));
        end
        
        function success = was_successful(self)
            % WAS_SUCCESSFUL returns whether the test was
            % successful or not.
            %
            % Example:
            %    was_successful is called for example from
            %    text_test_result.run:
            %         was_successful(result)
            %
            %  See also MLUNIT.TEXT_TEST_RESULT.RUN.
            
            if (size(self.errors, 1) + size(self.failures, 1) == 0)
                success = 1;
            else
                success = 0;
            end;
        end
        
        function self = union_test_results(self,varargin)
            % UNION_TEST_RESULTS unions several objects of test_result
            % class into single object
            %
            % Usage: self = union_test_results(self,varargin)
            %
            % Input:
            %   regular:
            %     self: test_result [1,1] - object that is to contain union
            %        of all results
            %   optional:
            %     testRes2: test_result [1,1] - second object with test
            %        results
            %     ...
            %     testResN: test_result [1,1] - N-th object with test
            %        results
            % Output:
            %   regular:
            %     self: test_result [1,1] - object containing all test
            %         results
            %
            
            if nargin<2,
                return;
            end
            isnClassVec=~cellfun(@(x)isa(x,'mlunit.test_result'),varargin);
            if any(isnClassVec),
                indNonClassVec=find(isnClassVec);
                [classList,~,indClassVec]=unique(cellfun(@class,....
                    varargin(isnClassVec),'UniformOutput',false));
                nClasses=numel(classList);
                messageCVec=cell(1,nClasses);
                for iClass=1:nClasses,
                    isClassVec=indClassVec==iClass;
                    messageCVec{iClass}=sprintf('objects with indices %s are of class %s',...
                        cell2sepstr([],cellfun(@num2str,num2cell(reshape(...
                        indNonClassVec(isClassVec),1,[])),...
                        'UniformOutput',false),','),classList{iClass});
                end
                error([upper(mfilename),':wrongInput'],...
                    'All arguments must be objects of mlunit.test_result class:\n%s',...
                    cell2sepstr([],messageCVec,sprintf(',\n')));
            end
            nObjs=nargin-1;
            for iObj=1:nObjs,
                curObj=varargin{iObj};
                self.tests_run=self.tests_run+curObj.get_tests_run();
                self.errors=vertcat(self.errors,curObj.get_error_list());
                self.failures=vertcat(self.failures,curObj.get_failure_list());
                self.should_stop=self.should_stop|curObj.get_should_stop();
            end
        end
        function [errorCount,failCount]=getErrorFailCount(self)
            nRes=length(self);
            errorCount=0;
            failCount=0;
            for iRes=1:nRes
                errorCount=errorCount+self(iRes).get_errors();
                failCount=failCount+self(iRes).get_failures();
            end
        end
        %
        function message=getErrorFailMessage(self)
            nRes=length(self);
            messageList=cell(1,nRes);
            for iRes=1:nRes
                messageList{iRes}=feval('print_errors',self(iRes));
            end
            message=[messageList{:}];
        end        
        %
        function display(self)
            message=evalc('display@handle(self)');
            message=strrep(message,'self = ','');
            [errorCount,failCount]=self.getErrorFailCount();
            %
            fprintf([...
                '\n%s\n+--------------------------------------------+',...
                '\n|         (FAILURES: %d, ERRORS %d)            |',...
                '\n+--------------------------------------------+\n'],....
                message,failCount,errorCount);
        end
    end
end