classdef text_test_runner
% TEXT_TEST_RUNNER class runs a test_case or test_suite and 
%  writes the results to a stream in textual form (using 
%  text_test_result).
%
%  Example:
%      runner = text_test_runner(1, 1);
%      run(runner, mlunit_all_tests);
%
%  See also MLUNIT.TEXT_TEST_RESULT.

% $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
% Faculty of Applied Mathematics and Cybernetics, System Analysis
% Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties
        stream
        verbosity
    end

    methods
        function self = text_test_runner(stream, verbosity)
            if (nargin == 0)
                stream = 1;
                verbosity = 0;
            end;
            %
            self.stream = stream;
            self.verbosity = verbosity;
        end

        function result = run(self, test)
            % RUN executes the test and writes the results 
            % to a stream in textual form (using text_test_result).
            %
            % Input:
            %   regular:
            %       self:
            %       test: any of
            %           mlunit.test_suite[1,1] - test suite to run
            %           mlunit.test_case[1,1] - test case to run
            %           char[1,] - name of test case to run 
            %           
            %  Example:
            %      runner = text_test_runner(1, 1);
            %      run(runner, mlunit_all_tests);
            %
            %  See also MLUNIT.TEXT_TEST_RUNNER, MLUNIT.TEXT_TEST_RESULT.

            import mlunit.*;

            if (ischar(test))
                % This will throw an exception (:noSuchClass) if there is
                % no such class
                test = load_tests_from_test_case(test_loader, test);
            end;

            result = text_test_result(self.stream, self.verbosity);
            t = clock;
            result = run(test, result); 
            time = etime(clock, t);
            print_errors(result);
            mlunit.logprintf('info','----------------------------------------------------------------------\n');
            tests_run = get_tests_run(result);
            %
            if isa(test,'mlunit.test_case')
                testCaseNameList={class(test)};
                testNameList={test.name};
            elseif isa(test,'mlunit.test_suite')
                testCaseNameList=cellfun(@class,test.tests,'UniformOutput',false);
                testNameList=cellfun(@(x)x.name,test.tests,'UniformOutput',false);
            else
                error([upper(mfilename),':wrongInput'],...
                    'Oops, we shouldn''t be here');
            end
            %
            testCaseNameList=strcat(testCaseNameList,'/',testNameList);
            %
            testCaseName=modgen.string.catwithsep(testCaseNameList,sprintf('\n'));
            %
            mlunit.logprintf('info',['Test case(s): %s,\n ran %d test(s) ',...
                'in %.3fs(%.3fm)\n'], ...
                testCaseName,tests_run, time,time/60);
            %    
            if (was_successful(result))
                mlunit.logprintf('info','OK\n');
            else
                mlunit.logprintf('info','FAILED (errors=%d, failures=%d)\n', ...
                    get_errors(result), get_failures(result));
            end;
        end
    end
end