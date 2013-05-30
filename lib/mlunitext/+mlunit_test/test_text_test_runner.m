classdef test_text_test_runner < mlunitext.test_case
    %test_text_test_runner tests the class text_test_runner.
    %
    %  Example:
    %         run(gui_test_runner, 'test_text_test_runner');
    %
    %  See also MLUNITEXT.TEXT_TEST_RUNNER.

    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$

    properties (Access=private)
        runner = [];
    end

    methods
        function self = test_text_test_runner(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end

        function self = set_up(self)
            % SET_UP sets up the fixture for
            % 
            %
            %  Example:
            %         run(gui_test_runner, 'test_text_test_runner');

            import mlunitext.*;

            self.runner = text_test_runner(1, 0);
        end

        function self = test_run_failed_tests(self)
            % TEST_RUN TESTS the method
            %   text_test_runner.run with failing tests.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_text_test_runner(''test_run_failed_tests'');');
            %
            %  See also MLUNITEXT.TEXT_TEST_RUNNER.RUN.

            import mlunitext.*;

            % verbosity = 0
            suite = test_suite;
            suite.add_test(...
                mlunit_test.test_test_case('test_template_method'));
            suite.add_test(...
                mlunit_test.test_test_case('test_broken_method'));
            stdOut = evalc('run(self.runner, suite);');
            linesCVec = strsplit(stdOut);
            iLine = 1;
            
            while iLine <= numel(linesCVec) && isempty(findstr('Test case(s):',linesCVec{iLine}))
                iLine = iLine + 1;
            end
            iLine=iLine+1;
            nTests=length(suite.tests);
            for iTest=1:nTests,
                methodStr=strcat(class(suite.tests{iTest}),'/',suite.tests{iTest}.name);
                if iTest==nTests,
                    methodStr=strcat(methodStr,',');
                end
                if ~strncmp(fliplr(linesCVec{iLine}),fliplr(methodStr),numel(methodStr)),
                    assert(0);
                end
                iLine = iLine + 1;
            end
            if isempty( findstr('ran 2 test(s) in ', linesCVec{iLine}) )
                message = sprintf('Test result invalid, expected <ran 2 test(s)>, but was <%s>.', linesCVec{iLine});
                assert(0, message);
            end;

            iLine = iLine + 1;
            assert_equals(false, isempty(findstr('FAILED (errors=1, failures=0)', linesCVec{iLine})));
        end

        function self = test_run_with_nonexisting_test_case(self)
            % TEST_RUN_WITH_NONEXISTING_TEST_CASE
            %   tests the behaviour of the run method for a nonexisting
            %   test_case.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_text_test_runner(''test_run_with_nonexisting_test_case'');');
            %
            %  See also MLUNITEXT.TEXT_TEST_RUNNER.RUN.

            import mlunitext.*;

            try
                run(self.runner, 'mlunit_nonexisting_test');
            catch meObj
                mlunitext.assert_equals(true,...
                    ~isempty(strfind(meObj.identifier,'noSuchClass')));
            end
        end

        function self = test_verbosity_null(self)
            % TEST_VERBOSITY_NULL tests the method
            %   text_test_runner.run with verbosity = 0.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_text_test_runner(''test_verbosity_null'');');
            %
            %  See also MLUNITEXT.TEXT_TEST_RUNNER.RUN.

            import mlunitext.*;

            % verbosity = 0
            test = mlunit_test.test_test_case('test_template_method');
            stdOut = evalc('run(self.runner, test);');
            linesCVec = strsplit(stdOut);
            iLine = 1;
                
            assert(strfind(fliplr(linesCVec{iLine}),...
                '----------------------------------------------------------------------') == 1);

            iLine = iLine + 2;
            methodStr=strcat(class(test),'/',test.name,',');
            if ~strncmp(fliplr(linesCVec{iLine}),fliplr(methodStr),numel(methodStr)),
                assert(0);
            end
            iLine = iLine + 1;
            pos = findstr('ran 1 test(s) in ', linesCVec{iLine});
            if (~isempty(pos))
                assert(pos(1) == 1);
            else
                assert(0);
            end;

            iLine = iLine + 1;
            assert_equals(true, strncmp('KO', fliplr(linesCVec{iLine}), 2));
        end

        function self = test_verbosity_one(self)
            % TEST_VERBOSITY_ONE tests the method
            %   text_test_runner.run with verbosity = 1.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_text_test_runner(''test_verbosity_one'');');
            %
            %  See also MLUNITEXT.TEXT_TEST_RUNNER.RUN.

            import mlunitext.*;

            self.runner = text_test_runner(1, 1);
            stdOut = evalc('run(self.runner, mlunit_test.test_test_case(''test_template_method''))');
            assert_equals('.', stdOut(1));
        end
    end
end