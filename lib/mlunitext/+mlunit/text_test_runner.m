classdef text_test_runner
% TEXT_TEST_RUNNER class runs a test_case or test_suite and 
%  writes the results to a textOutFid in textual form (using 
%  text_test_result).
%
%  Example:
%      runner = text_test_runner(1, 1);
%      run(runner, mlunit_all_tests);
%
%  See also MLUNIT.TEXT_TEST_RESULT.

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
        textOutFid
        verbosityLevel
    end

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

        function result = run(self, test)
            % RUN executes the test and writes the results 
            % to a textOutFid in textual form (using text_test_result).
            %
            % Input:
            %   regular:
            %       self:
            %       test: any of
            %           mlunit.test_suite[1,1] - test suite to run
            %           mlunit.test_case[1,1] - test case to run
            %           char[1,] - name of test case to run 
            %
            % Output: 
            %   result: mlunit.test_result[1,1] - result of the test run
            %           
            %  Example:
            %      runner = text_test_runner(1, 1);
            %      run(runner, mlunit_all_tests);
            %
            %  See also MLUNIT.TEXT_TEST_RUNNER, MLUNIT.TEXT_TEST_RESULT.

            import mlunit.*;
            import modgen.common.throwerror;

            if ischar(test)
                % This will throw an exception (:noSuchClass) if there is
                % no such class
                test = load_tests_from_test_case(test_loader, test);
            end

            result = text_test_result(self.textOutFid,self.verbosityLevel);
            tStart = clock;
            result = run(test, result); 
            tElapsed = etime(clock, tStart);
            print_errors(result);
            mlunit.logprintf('info','----------------------------------------------------------------------\n');
            tests_run = get_tests_run(result);
            %
            if isa(test,'mlunit.test_case')
                testCaseNameList={class(test)};
                testNameList={test.name};
            elseif isa(test,'mlunit.test_suite')
                testCaseNameList=cellfun(@class,test.tests,...
                    'UniformOutput',false);
                testNameList=cellfun(@(x)x.name,test.tests,...
                    'UniformOutput',false);
            else
                throwerror('wrongInput','Oops, we shouldn''t be here');
            end
            %
            testCaseNameList=strcat(testCaseNameList,'/',testNameList);
            %
            testCaseName=modgen.string.catwithsep(testCaseNameList,...
                sprintf('\n\t'));
            %
            mlunit.logprintf('info',['Test case(s):\n\t%s,\n ran %d test(s) ',...
                'in %.3fs(%.3fm)\n'], ...
                testCaseName,tests_run, tElapsed,tElapsed/60);
            %    
            if (was_successful(result))
                mlunit.logprintf('info','OK\n');
            else
                mlunit.logprintf('info',...
                    'FAILED (errors=%d, failures=%d)\n', ...
                    get_errors(result), get_failures(result));
            end
        end
    end
end