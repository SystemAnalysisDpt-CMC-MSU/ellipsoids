classdef mlunit_test_runtestcase < mlunitext.test_case
    methods
        function self = mlunit_test_runtestcase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function test_not_found(self)
            % If the test case class is not found or no test methods match
            % the pattern given to runtestcase, the method should throw an
            % exception
            self.runAndCheckError('mlunitext.runtestcase(''wrongClass'')',...
                ':noSuchClass');
            self.runAndCheckError('mlunitext.runtestcase(''wrongClass'',''someMethod'')',...
                ':noSuchClass');
            self.runAndCheckError(['mlunitext.runtestcase(''', class(self),...
                ''', ''wrongMethod'')'], ':wrongInput');
        end
        function test_marker(self)
            import mlunitext.*;
            tests{1} = mlunit_test.mock_test('test_method');
            tests{2} = mlunit_test.mock_test('test_broken_method');
            %
            runner=mlunit.text_test_runner(1, 1);
            suite=test_suite(tests,'marker','nda');
            result = runner.run(suite); %#ok
            mlunit.assert_equals(2, get_tests_run(result));            
            mlunit.assert_equals('mlunit_test.mock_test[nda]', suite.str());
            %
            loader = mlunitext.test_loader();
            suite=loader.load_tests_from_test_case(...
                'mlunit_test.mock_test','marker','nda');
            mlunit.assert_equals('', suite.marker);            
            mlunit.assert_equals('mlunit_test.mock_test[nda]', suite.str());
            cellfun(@checktest,suite.tests);
            function checktest(test)
                mlunit.assert_equals('nda',test.marker);
            end
        end

    end
end