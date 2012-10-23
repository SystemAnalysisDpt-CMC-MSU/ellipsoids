classdef mlunit_test_text_test_result < mlunitext.test_case
    methods
        function self = mlunit_test_text_test_result(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function test_dots(~)
            runner = mlunit.text_test_runner(1,1); %#ok<NASGU>
            loader = mlunitext.test_loader;
            tests = loader.map('mlunitext.test.mock_test',...
                {'test_pass_one','test_fail_one','test_error_one'}, false);
            suite = mlunitext.test_suite(tests); %#ok<NASGU>
            stdOut=evalc('runner.run(suite);');
            linesCVec = strsplit(stdOut);
            isFound = false;
            for line = linesCVec
                if isequal(line{1},'.FE')
                    isFound = true;
                    break;
                end
            end
            mlunit.assert_equals(true,isFound, 'Expected standard output not found');
        end
    end
end