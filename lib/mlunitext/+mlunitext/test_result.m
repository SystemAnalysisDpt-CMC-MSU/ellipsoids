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
    %  See also MLUNITEXT.ASSERT,
    %           MLUNITEXT.ASSERT_EQUALS,
    %           MLUNITEXT.ASSERT_NOT_EQUALS,
    %           MLUNITEXT.TEXT_TEST_RESULT.
    %
    % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2012-2013$
    
    properties (SetAccess=private)
        tests_run = 0;
        errors = {};
        failures = {};
        should_stop = 0;
        runTimeMap
        curTicId
    end
    %
    methods (Access=protected)
        function checkIfScalar(self)
            import modgen.common.throwerror;
            if ~isscalar(self)
                throwerror('wrongInput:notScalarObj',...
                    'object is expected to be a scalar');
            end
        end
    end
    methods
        function isOk=isPassed(self)
            [nErrors,nFails]=self.getErrorFailCount();
            isOk=(nErrors==0)&&(nFails==0);
        end
        function reportStr=getReport(self,reportType)
            import modgen.common.throwerror;
            if nargin<2
                reportType='minimal';
            end
            switch lower(reportType)
                case 'minimal',
                    [nErrors,nFails]=self.getErrorFailCount();
                    nTests=self.get_tests_run();
                    runTime=self.getRunTimeTotal();
                    %
                    msgFormatStr=['<< %s >> || TESTS: %d,  ',...
                        'RUN TIME(sec.): %.5g'];
                    %
                    if (nErrors==0)&&(nFails)==0
                        prefixStr='PASSED';
                        addArgList={};
                    else
                        prefixStr='FAILED';
                        msgFormatStr=[msgFormatStr,...
                            ',  FAILURES: %d,  ERRORS: %d'];
                        addArgList={nFails,nErrors};
                    end
                    reportStr=sprintf(msgFormatStr,prefixStr,...
                        nTests,runTime,addArgList{:});
                case 'tops',
                    rel=self.getRunStatRel(); %#ok<NASGU>
                    reportStr=evalc('rel.display');
                otherwise,
                    throwerror('wrongInput',...
                        'report type %s is not supported');
            end
        end
        function rel=getRunStatRel(self)
            SDataList=arrayfun(@getOneResultData,self,'UniformOutput',false);
            SData=modgen.struct.unionstructsalongdim(1,SDataList{:});
            rel=smartdb.relations.DynamicRelation(SData,...
                'fieldNameList',{'runTime','testName'},...
                'fieldDescrList',...
                {'run time in seconds','full test name'});
            rel.sortBy('runTime','direction','desc');
            function SData=getOneResultData(selfElem)
                SData.runTime=selfElem.runTimeMap.values.';
                SData.testName=selfElem.runTimeMap.keys.';
            end
        end
        %
        function display(self)
            % DISPLAY prints the information about errors and failures from
            % a vector of test results into console
            %
            message=evalc('display@handle(self)');
            %
            reportStr=self.getReport();
            nSlashes=length(reportStr)+3;
            fprintf([...
                ['\n%s\n+',repmat('-',1,nSlashes),'+'],...
                '\n| %s  |\n',...
                ['+',repmat('-',1,nSlashes),'+\n']],....
                message,reportStr);
        end
        function runTimeTotal=getRunTimeTotal(self)
            runTimeTotal=sum(arrayfun(@getRunTimeTotalElem,self));
            function runTime=getRunTimeTotalElem(selfElem)
                runTimeList=selfElem.runTimeMap.values();
                runTime=sum([runTimeList{:}]);
            end
        end
        function add_success(self, ~)
            % ADD_SUCCESS is an empty method for classes, which
            %   might do some action on a successful test.
            self.checkIfScalar();
        end
        function stop_test(self, test)
            % STOP_TEST indicates that a test has been finished.
            %
            % Example:
            %    stop_test is usually called by test_case.run to signal
            %    the end of the test execution to the test result:
            %         result = stop_test(result, self);
            %
            self.checkIfScalar();
            testKey=test.str();
            curRunTime=toc(self.curTicId);
            self.runTimeMap(testKey)=curRunTime;
        end
        function start_test(self, test) %#ok
            % START_TEST indicates that a test will be started.
            %
            % Example:
            %    start_test is usually called by test_case.run to signal
            %    the start of the test execution to the test result:
            %         result = start_test(result, self);
            %
            %  See also MLUNITEXT.TEST_CASE.RUN.
            self.checkIfScalar();
            self.curTicId=tic();
            self.tests_run = self.tests_run + 1;
        end
        function mapObj=getRunTimeMap(self)
            self.checkIfScalar();
            mapObj=self.runTimeMap.getCopy();
        end
        function self=test_result(varargin)
            self.runTimeMap=modgen.containers.MapExtended(...
                'KeyType','char','ValueType','double');
        end
        function add_error(self, testName, meObj)
            % ADD_ERROR_WITH_STACK adds an error to the test result
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunitext.test_case[1,1] - test to which the errors
            %           are added
            %       meObj: MException[1,1] - an error object to add to the
            %           test
            %
            % Example:
            %   result = add_error_with_stack(result, self, lasterror);
            %
            % See also MLUNITEXT.TEST_RESULT.ADD_ERROR, MLUNITEXT.TEST_CASE.RUN.
            %
            self.checkIfScalar();
            errMsg=modgen.exception.me.obj2hypstr(meObj);
            self.add_error_by_message(testName,errMsg);
        end
        
        function add_error_by_message(self, testName, errorMsg)
            % ADD_ERROR adds an error to the test result based on the
            % error message
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunitext.test_case[1,1] - test to which the errors
            %           are added
            %       errorMsg: char[1,] - an error message
            %
            % Example:
            %   add_error is usually only called by the run method of
            %   test_case, see test_case.run:
            %       result = add_error(result, self, stacktrace);
            %
            %  See also MLUNITEXT.TEST_CASE.RUN.
            %
            self.checkIfScalar();
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
        
        function add_failure(self, testName, meObj)
            % ADD_FAILURE adds a failure for the test result
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunitext.test_case[1,1] - test to which the errors
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
            self.checkIfScalar();
            [message,stacktrace]=modgen.exception.me.obj2str(meObj);
            self.add_failure_by_message(testName,[message,stacktrace]);
        end
        %
        function add_failure_by_message(self, testName, failMsg)
            % ADD_FAILURE adds a failure to the test result based on the
            % failure message
            %
            % Input:
            %   regular:
            %       self:
            %       testName: mlunitext.test_case[1,1] - test to which the errors
            %           are added
            %       failMsg: char[1,] - failure message
            %
            %  Example:
            %   add_failure is usually only called by the run method of
            %   test_case, see test_case/run:
            %       result = add_failure(result, self, errmsg);
            %
            %  See also TEST_CASE/RUN.
            self.checkIfScalar();
            if ~ischar(failMsg)
                modgen.common.throwerror('wrongInput',...
                    'failMsg is expected to be a character array');
            end
            last = size(self.failures, 1);
            self.failures{last + 1, 1} = testName.str();
            self.failures{last + 1, 2} = failMsg;
        end
        %
        function errors = get_error_list(self)
            % GET_ERROR_LIST returns a cell array of tests and
            %   errors.
            %
            %  Example:
            %    get_error_list is called for example from
            %    text_test_result.print_errors:
            %         get_error_list(self)
            %
            %  See also MLUNITEXT.TEXT_TEST_RESULT.PRINT_ERRORS.
            self.checkIfScalar();
            errors = self.errors;
        end
        %
        function errors = get_errors(self)
            % GET_ERRORS returns the number of errors.
            %
            %  Example:
            %    get_error_list is called for example from
            %    text_test_result.run:
            %         get_errors(self)
            %
            %  See also MLUNITEXT.TEXT_TEST_RESULT.RUN.
            self.checkIfScalar();
            errors = size(self.errors, 1);
        end
        %
        function failures = get_failure_list(self)
            % GET_FAILURE_LIST returns a cell array of tests
            %   and failures.
            %
            % Example:
            %   get_error_list is called for example from
            %   text_test_result.print_errors:
            %       get_failure_list(self)
            %
            %  See also MLUNITEXT.TEXT_TEST_RESULT.PRINT_ERRORS.
            self.checkIfScalar();
            failures = self.failures;
        end
        %
        function failures = get_failures(self)
            % GET_ERRORS returns the number of failures.
            %
            % Example:
            %    get_error_list is called for example from
            %    text_test_result.run:
            %         get_errors(self)
            %
            % See also MLUNITEXT.TEXT_TEST_RESULT.RUN.
            self.checkIfScalar();
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
            % See also MLUNITEXT.TEST_SUITE.RUN.
            self.checkIfScalar();
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
            %  See also MLUNITEXT.TEXT_TEST_RUNNER.RUN.
            tests_run = sum(arrayfun(@(x)x.tests_run,self));
        end
        function set_should_stop(self)
            % SET_SHOULD_STOP indicates that the execution of
            % tests should stop.
            %
            % Example:
            %   result = test_result;
            %   % Do something, e.g. iterate through a number of tests, ...
            %   result = set_should_stop(result);
            self.checkIfScalar();
            self.should_stop = 1;
        end
        %
        function s = summary(self)
            % SUMMARY returns a string with a summary of the
            % test result.
            %
            % Example:
            %         test = ... % e.g. created through my_test('test_foo')
            %         [test, result] = run(test);
            %         summary(result)
            self.checkIfScalar();
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
            %  See also MLUNITEXT.TEXT_TEST_RESULT.RUN.
            self.checkIfScalar();
            if (size(self.errors, 1) + size(self.failures, 1) == 0)
                success = 1;
            else
                success = 0;
            end;
        end
        
        function union_test_results(self,varargin)
            % UNION_TEST_RESULTS unions several objects of test_result
            % class into single object
            %
            % Usage: union_test_results(self,varargin)
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
            import modgen.common.throwerror;
            self.checkIfScalar();
            if nargin<2,
                return;
            end
            isnClassVec=~cellfun(@(x)isa(x,'mlunitext.test_result'),...
                varargin);
            if any(isnClassVec),
                indNonClassVec=find(isnClassVec);
                [classList,~,indClassVec]=unique(cellfun(@class,....
                    varargin(isnClassVec),'UniformOutput',false));
                nClasses=numel(classList);
                messageCVec=cell(1,nClasses);
                for iClass=1:nClasses,
                    isClassVec=indClassVec==iClass;
                    messageCVec{iClass}=sprintf(...
                        'objects with indices %s are of class %s',...
                        cell2sepstr([],cellfun(@num2str,num2cell(reshape(...
                        indNonClassVec(isClassVec),1,[])),...
                        'UniformOutput',false),','),classList{iClass});
                end
                throwerror('wrongInput',...
                    ['All arguments must be objects of ',...
                    'mlunitext.test_result class:\n%s'],...
                    cell2sepstr([],messageCVec,sprintf(',\n')));
            end
            nObjs=nargin-1;
            for iObj=1:nObjs,
                curObj=varargin{iObj};
                self.tests_run=self.tests_run+curObj.get_tests_run();
                self.errors=vertcat(self.errors,curObj.get_error_list());
                self.failures=vertcat(self.failures,curObj.get_failure_list());
                self.should_stop=self.should_stop|curObj.get_should_stop();
                self.runTimeMap=self.runTimeMap.getUnionWith(...
                    curObj.runTimeMap);
            end
        end
        function [errorCount,failCount]=getErrorFailCount(self)
            % GETERRORFAILCOUNT returns a number of errors and failures for
            % a vector of test results
            %
            nRes=length(self);
            errorCount=0;
            failCount=0;
            for iRes=1:nRes
                errorCount=errorCount+self(iRes).get_errors();
                failCount=failCount+self(iRes).get_failures();
            end
        end
    end
end
