classdef text_test_runner
    % TEXT_TEST_RUNNER class runs a test_case or test_suite and
    %  writes the results to a textOutFid in textual form (using
    %  text_test_result).
    %
    %  Example:
    %      runner = text_test_runner(1, 1);
    %      run(runner, mlunitext_all_tests);
    %
    %  See also MLUNITEXT.TEXT_TEST_RESULT.
    %
    % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2012-2013$
    %
    properties
        textOutFid
        verbosityLevel
    end
    %
    methods
        function self = text_test_runner(textOutFid, verbosityLevel)
            import modgen.common.type.simple.checkgen;
            if (nargin == 0)
                textOutFid = 1;
                verbosityLevel = 0;
            else
                checkgen(textOutFid,...
                    @(x)isscalar(x)&&isa(x,'double')&&(x>0)&&(fix(x)==x));
                checkgen(verbosityLevel,...
                    @(x)isscalar(x)&&isa(x,'double')&&(x==0||x==1||x==2));
                
                self.textOutFid=textOutFid;
                self.verbosityLevel=verbosityLevel;
            end
            %
            self.textOutFid = textOutFid;
            self.verbosityLevel = verbosityLevel;
        end
        %
        function result=run(self, test, varargin)
            % RUN executes the test and writes the results
            % to a textOutFid in textual form (using text_test_result).
            %
            % Input:
            %   regular:
            %       self:
            %       test: any of
            %           mlunitext.test_suite[1,1] - test suite to run
            %           mlunitext.test_case[1,1] - test case to run
            %           char[1,] - name of test case to run
            %   properties:
            %     isConsolidateMarkedResults: logical [1,1] - When set,
            %         this flag signals to the getXmlReports method of
            %         test_result to consolidate test results with
            %         different markers in the same report, rather than
            %         producing a separate report for each unique mark
            %         (default behavior). See getXmlReports.
            %
            % Output:
            %   result: mlunitext.test_result[1,1] - result of the test run
            %
            %  Example:
            %      runner = text_test_runner(1, 1);
            %      run(runner, mlunitext_all_tests);
            %
            %  See also MLUNITEXT.TEXT_TEST_RUNNER, MLUNITEXT.TEXT_TEST_RESULT.
            
            import mlunitext.*;
            import modgen.common.throwerror;
            
            [~,~,isConsolidateMarkedResults]=modgen.common.parseparext(...
                varargin,{'isConsolidateMarkedResults';false;'islogical(x)'},0);
            if ischar(test)
                % This will throw an exception (:noSuchClass) if there is
                % no such class
                test = load_tests_from_test_case(test_loader, test);
            end
            %
            result = text_test_result(self.textOutFid,self.verbosityLevel,...
                'isConsolidateMarkedResults',isConsolidateMarkedResults);
            tStart = clock;
            run(test, result);
            tElapsed = etime(clock, tStart);
            print_errors(result);
            mlunitext.logprintf('info','----------------------------------------------------------------------\n');
            tests_run = result.getNTestsRun();
            %
            if isa(test,'mlunitext.test_case')
                testCaseNameList={class(test)};
                testNameList={test.name};
                markerList={test.marker};
            elseif isa(test,'mlunitext.test_suite')
                testCaseNameList=cellfun(@class,test.tests,...
                    'UniformOutput',false);
                testNameList=cellfun(@(x)x.name,test.tests,...
                    'UniformOutput',false);
                markerList=cellfun(@(x)x.marker,test.tests,...
                    'UniformOutput',false);
            else
                throwerror('wrongInput','Oops, we shouldn''t be here');
            end
            %
            isnEmptyVec=~cellfun('isempty',markerList);
            %
            testCaseNameList=strcat(...
                testCaseNameList,'/',testNameList);
            if any(isnEmptyVec)
                testCaseNameList(isnEmptyVec)=...
                    strcat(testCaseNameList(isnEmptyVec),...
                '[',markerList(isnEmptyVec),']');
            end
            %
            testCaseName=modgen.string.catwithsep(testCaseNameList,...
                sprintf('\n\t'));
            %
            mlunitext.logprintf('info',['Test case(s):\n\t%s,\n ran %d test(s) ',...
                'in %.3fs(%.3fm)\n'], ...
                testCaseName,tests_run, tElapsed,tElapsed/60);
            %
            if (isPassed(result))
                mlunitext.logprintf('info','OK\n');
            else
                mlunitext.logprintf('info',...
                    'FAILED (errors=%d, failures=%d)\n', ...
                    getNErrors(result), getNFailures(result));
            end
        end
    end
end
