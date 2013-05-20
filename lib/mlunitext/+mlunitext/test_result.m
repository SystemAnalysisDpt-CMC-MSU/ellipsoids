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
    %
    properties (SetAccess=private)
        errors = {};
        failures = {};
        should_stop = 0;
    end
    properties (Access=private)
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
            if nargin<2
                reportType='minimal';
            end
            if strcmpi(reportType,'minimal')
                    [nErrors,nFails]=self.getErrorFailCount();
                    nTests=self.getNTestsRun();
                    runTime=self.getRunTimeTotal();
                    %
                    msgFormatStr='<< %s >> || TESTS: %d';
                    suffixStr=',  RUN TIME(sec.): %.5g';
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
                    msgFormatStr=[msgFormatStr,suffixStr];
                    reportStr=sprintf(msgFormatStr,prefixStr,...
                        nTests,addArgList{:},runTime);
            else
                    rel=self.getRunStatRel(reportType); %#ok<NASGU>
                    reportStr=evalc('rel.display');
            end
        end
        function resRel=getRunStatRel(self,reportType)
            import mlunitext.rels.F;
            import modgen.common.throwerror;
            if nargin<2
                reportType='tops';
            end
            SDataList=arrayfun(@getOneResultData,self,'UniformOutput',...
                false);
            SData=modgen.struct.unionstructsalongdim(1,SDataList{:});
            rel=mlunitext.rels.TopsReportRel(SData);
            switch lower(reportType)
                case 'tops',
                    resRel=rel;
                case 'topstestcase',
                    rel=smartdb.relations.DynamicRelation(rel);
                    rel.groupBy({F.TEST_CASE_NAME});
                    rel.applySetFunc(@sum,F.TEST_RUN_TIME,...
                        'inferIsNull',true,'UniformOutput',true);
                    SData=rel.getData('fieldNameList',...
                        {F.TEST_RUN_TIME,F.TEST_CASE_NAME});
                    resRel=mlunitext.rels.TopsTestCaseReportRel(SData);
                otherwise,
                    throwerror('wrongInput',...
                        'report type %s is not supported',reportType);
            end
            
            %
            function SData=getOneResultData(selfElem)
                valuesList=selfElem.runTimeMap.values;
                SData=modgen.struct.unionstructsalongdim(1,valuesList{:});
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
            fprintf([['\n%s\n+',repmat('-',1,nSlashes),'+'],...
                '\n| %s  |\n',...
                ['+',repmat('-',1,nSlashes),'+\n']],....
                message,reportStr);
        end
        function runTimeTotal=getRunTimeTotal(self)
            import mlunitext.rels.F;
            runTimeFieldName=F.TEST_RUN_TIME;
            runTimeTotal=sum(arrayfun(@getRunTimeTotalElem,self));
            function runTime=getRunTimeTotalElem(selfElem)
                runTimeVec=cellfun(@(x)x.(runTimeFieldName),...
                    selfElem.runTimeMap.values());
                runTime=sum(runTimeVec);
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
            import mlunitext.rels.F;
            self.checkIfScalar();
            testKey=test.str();
            curRunTime=toc(self.curTicId);
            self.runTimeMap(testKey)=struct(...
                F.TEST_RUN_TIME,curRunTime,...
                F.TEST_NAME,{{test.name}},...
                F.TEST_CASE_NAME,{{class(test)}},...
                F.TEST_MARKER,{{test.marker}});
        end
        function start_test(self, test)
            % START_TEST indicates that a test will be started.
            %
            % Example:
            %    start_test is usually called by test_case.run to signal
            %    the start of the test execution to the test result:
            %         result = start_test(result, self);
            %
            %  See also MLUNITEXT.TEST_CASE.RUN.
            import modgen.common.throwerror;
            self.checkIfScalar();
            testKey=test.str();
            if self.runTimeMap.isKey(testKey)
                throwerror('wrongInput',...
                    'attempt to run test %s twice',testKey);
            end
            self.curTicId=tic();
        end
        function mapObj=getRunTimeMap(self)
            self.checkIfScalar();
            mapObj=self.runTimeMap.getCopy();
        end
        function self=test_result(varargin)
            self.runTimeMap=modgen.containers.MapExtended(...
                'KeyType','char','ValueType','any');
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
        function errors = getNErrors(self)
            % GET_ERRORS returns the number of errors.
            %
            %  Example:
            %    get_error_list is called for example from
            %    text_test_result.run:
            %         getNErrors(self)
            %
            %  See also MLUNITEXT.TEXT_TEST_RESULT.RUN.
            errors = sum(arrayfun(@(x)size(x.errors, 1),self));
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
        function failures = getNFailures(self)
            % GET_ERRORS returns the number of failures.
            %
            % Example:
            %    get_error_list is called for example from
            %    text_test_result.run:
            %         getNErrors(self)
            %
            % See also MLUNITEXT.TEXT_TEST_RESULT.RUN.
            failures = sum(arrayfun(@(x)size(x.failures,1),self));
        end
        function tests_run = getNTestsRun(self)
            tests_run = sum(arrayfun(@(x)x.runTimeMap.Count,self));
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
                self.errors=vertcat(self.errors,curObj.get_error_list());
                self.failures=vertcat(self.failures,curObj.get_failure_list());
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
                errorCount=errorCount+self(iRes).getNErrors();
                failCount=failCount+self(iRes).getNFailures();
            end
        end
    end
end