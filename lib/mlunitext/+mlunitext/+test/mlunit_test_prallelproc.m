classdef mlunit_test_prallelproc < mlunitext.test_case
    properties
        testSuiteProps
    end
    %
    methods
        function self = mlunit_test_prallelproc(varargin)
            [reg,prop]=modgen.common.parseparams(varargin,...
                {'hExecFunc','confRepoMgr','hConfFunc',...
                'nParallelProcesses','parallelConfiguration'});
            self = self@mlunitext.test_case(reg{:});
            [~,self.testSuiteProps] = modgen.common.parseparams(prop,...
                {'hExecFunc','confRepoMgr','hConfFunc','parallelConfiguration'});
        end
        %
        function test_runSinglePar(self)
            test=mlunitext.test.mock_test('test_error_one');
            suite=mlunitext.test_suite({test});
            self.aux_test_run_tests(suite);
        end
        %
        function test_runMultiPar(self)
            loader = mlunitext.test_loader;
            suite = loader.load_tests_from_test_case('mlunitext.test.mock_test');
            self.aux_test_run_tests(suite);
        end
        function aux_test_run_tests(self,suite)
            runner = mlunitext.text_test_runner(1, 1); %#ok<NASGU>
            %
            suiteSingleThread = mlunitext.test_suite(horzcat(suite.tests),...
                self.testSuiteProps{:}); %#ok<NASGU>
            [~,resultsSingle]=evalc('runner.run(suiteSingleThread);');
            %
            check();            
            check('parallelMode','blockBased');
            check('parallelMode','queueBased');
            %
            mlunitext.assert_equals(true,...
                isFieldEqual(resultsSingle,resultsDouble,'errors'));
            %
            mlunitext.assert_equals(true,...
                isFieldEqual(resultsSingle,resultsDouble,'failures'));
            %
            function isPositive=isFieldEqual(resultsSingle,resultsDouble,fieldName)
                isSingleEmpty=isempty(resultsSingle.(fieldName));
                isDoubleEmpty=isempty(resultsDouble.(fieldName));
                if isSingleEmpty&&isDoubleEmpty
                    isPositive=true;
                else
                    methodsSingleCVec = resultsSingle.(fieldName)(:,1);
                    methodsDoubleCVec = resultsDouble.(fieldName)(:,1);
                    isPositive=all(strcmp(...
                    sort(methodsSingleCVec),sort(methodsDoubleCVec)));
                end
            end
            function check(varargin)
                suiteDoubleThread = mlunitext.test_suite(horzcat(suite.tests),...
                    self.testSuiteProps{:},'nParallelProcesses',2,varargin{:}); 
                [~,resultsDouble]=evalc('runner.run(suiteDoubleThread);');
                %
                mlunitext.assert_equals(resultsSingle.getNTestsRun(),...
                    resultsDouble.getNTestsRun());
            end
        end
    end
end