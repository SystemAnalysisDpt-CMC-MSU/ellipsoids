classdef mlunit_test_text_test_result < mlunitext.test_case
    methods (Access=private)
        function [runner,suite]=getSimpleRunnerSuite(~,markerStr)
            runner = mlunitext.text_test_runner(1,1);
            loader = mlunitext.test_loader;
            tests = loader.map('mlunitext.test.mock_test',...
                {'test_pass_one','test_fail_one','test_error_one'}, false);
            suite = mlunitext.test_suite(tests);
            if nargin>1
                suite.set_marker(markerStr);
            end
        end
        function result=getSimpleTestResult(self,varargin)
            [runner,suite]=self.getSimpleRunnerSuite(varargin{:}); %#ok<NASGU,ASGLU>
            result=[];
            evalc('result=runner.run(suite);');
        end
    end
    methods
        function testReport(self)
            %
            result=self.getSimpleTestResult();
            result2=self.getSimpleTestResult('alpha');
            resVec=[result,result2]; %#ok<NASGU>
            check('')
            check('minimal')
            check('tops')
            function check(repType)
                PREFIX='reportStr=resVec.getReport';
                reportStr=''; %#ok<NASGU>
                if isempty(repType)
                    str=[PREFIX,'()'];
                else
                    str=[PREFIX,'(''',repType,''')'];
                end
                evalc(str);
            end
            %
        end
        function self = mlunit_test_text_test_result(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        function testUnion(self)
            result1Vec=self.getSimpleTestResult();
            result2Vec=self.getSimpleTestResult('alpha');
            result1Vec.union_test_results(result2Vec);
            nTests=result1Vec.get_tests_run();
            nMapEntries=result1Vec.getRunTimeMap().Count;
            mlunitext.assert_equals(nTests,nMapEntries);
        end
        %
        function test_dots(self)
            [runner,suite]=self.getSimpleRunnerSuite(); %#ok<ASGLU,NASGU>
            stdOut=evalc('runner.run(suite);');
            linesCVec = strsplit(stdOut);
            isFound = false;
            for line = linesCVec
                if isequal(line{1},'.FE')
                    isFound = true;
                    break;
                end
            end
            mlunitext.assert_equals(true,isFound,...
                'Expected standard output not found');
        end
        %
        function testPrintErrorList(self)
            runner = mlunitext.text_test_runner(1,1);
            loader = mlunitext.test_loader;
            tests = loader.map('mlunitext.test.mock_test',...
                {'test_pass_one','test_fail_one','test_error_one'}, false);
            suite = mlunitext.test_suite(tests);
            testRes=[];
            evalc('testRes=runner.run(suite);');
            evalc('testRes.print_errors');
            testVec=[testRes,testRes];
            evalc('testVec.getErrorFailMessage();');
            evalc('testVec.getErrorFailCount();');
            evalc('testVec.get_tests_run;');
            check('print_errors','get_error_list','get_failure_list',...
                'union_test_results',...
                @(x)stop_test(x,tests{1}),@(x)start_test(x,tests{1}),...
                'set_should_stop',...
                'get_should_stop',...
                'get_failures',...
                'get_errors',...
                @(x)add_success(x,tests{1}),...
                @(x)add_failure(x,tests{1},MException('alpha:beta','gamma')),...
                @(x)add_failure_by_message(x,tests{1},'alpha'),...
                @(x)add_error_by_message(x,tests{1},'alpha'),...
                @(x)add_error(x,tests{1},...
                MException('alpha:beta','gamma')),...
                'add_error');
            function check(varargin)
                import modgen.common.throwerror;
                nMethods=length(varargin);
                for iMethod=1:nMethods
                    methodName=varargin{iMethod};
                    try
                        if ischar(methodName)
                            toCall=['testVec.',methodName];
                        else
                            toCall=@()methodName(testVec);
                        end
                        self.runAndCheckError(toCall,...
                            'wrongInput:notScalarObj');
                    catch meObj
                        if ~ischar(methodName)
                            methodName=func2str(methodName);
                        end
                        newMeObj=throwerror('testFail',...
                            'test failure for method %s',methodName);
                        newMeObj=addCause(newMeObj,meObj);
                        throw(newMeObj);
                    end
                end
            end
        end
    end
end
