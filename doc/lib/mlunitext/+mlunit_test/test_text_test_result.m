classdef test_text_test_result < mlunitext.test_case&mlunit_test.AuxChecker
    % TEST_TEXT_TEST_RESULT tests the class text_test_result.
    %
    % Example:
    %         run(gui_test_runner, 'test_text_test_result');
    %
    % See also MLUNITEXT.TEXT_TEST_RESULT.
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    %
    properties
        runner = [];
    end
    
    methods
        function self = test_text_test_result(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function result = set_result(self, result) %#ok
            % SET_RESULT sets up the contents of
            %   result with a number of sample results.
            %
            % Example:
            %   result = set_result(self, result);
            %
            % See also MLUNIT_TEST.TEST_TEXT_TEST_RESULT.TEST_RESULT.
            
            import mlunit_test.*;
            
            testObj=mock_test('test_method');
            start_test(result, testObj);
            add_success(result, testObj);
            stop_test(result, testObj);
            testObj=mock_test('test_method','marker','a');
            start_test(result, testObj);
            add_error_by_message(result,...
                testObj,'foo error');
            stop_test(result, testObj);
            testObj=mock_test('test_method','marker','b');
            start_test(result, testObj);
            add_failure_by_message(result,testObj, 'foo failure');
            stop_test(result,testObj);
        end
        function self = test_verbosity_null(self)
            % TEST_VERBOSITY_NULL tests the behaviour
            %   of text_test_result for verbosity = 0.
            %
            % Example:
            %         run(gui_test_runner,
            %             'test_text_test_result(''test_verbosity_null'');');
            %
            %  See also MLUNIT_TEST.TEXT_TEST_RESULT.
            
            import mlunitext.*;
            
            result = text_test_result(1,0);
            stdOut = evalc('set_result(self, result);');
            assert(isempty(stdOut));
        end
        
        function self = test_verbosity_one(self)
            % TEST_VERBOSITY_ONE tests the behaviour
            %   of text_test_result for verbosity = 1.
            %
            % Example:
            %   run(gui_test_runner,
            %       'test_text_test_result(''test_verbosity_one'');');
            %
            %  See also MLUNITEXT.TEXT_TEST_RESULT.
            import mlunitext.*;
            %
            result = text_test_result(1,1);
            [stdOut, result] = evalc('set_result(self, result);');
            assert(strcmp('.EF', stdOut));
            self.checkResultReport(result,3,1,1);            
        end
        
        function self = test_verbosity_two(self)
            % TEST_VERBOSITY_TWO tests the behaviour
            %   of text_test_result for verbosity = 2.
            %
            % Example:
            %   run(gui_test_runner,
            %       'test_text_test_result(''test_verbosity_two'');');
            %
            %  See also MLUNITEXT.TEXT_TEST_RESULT.
            
            import mlunitext.*;
            %
            result = text_test_result(1,2);
            [stdOut, result] = evalc('set_result(self, result);');
            assert_equals(false, isempty(regexp(stdOut, ...
                '^[^\n]* ... OK\n[^\n]* ... ERROR\n[^\n]* ... FAIL', 'once')));
            
            stdOut = evalc('print_errors(result);');
            linesCVec = strsplit(stdOut);
            iLine = 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                '======================================================================$', 'once')));
            iLine = iLine + 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                [regexptranslate('escape','ERROR: mlunit_test.mock_test[a](''test_method'')'),'$'], 'once')));
            iLine = iLine + 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                '----------------------------------------------------------------------$', 'once')));
            iLine = iLine + 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                'foo error$', 'once')));
            iLine = iLine + 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                '======================================================================$', 'once')));
            iLine = iLine + 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                [regexptranslate('escape','FAIL: mlunit_test.mock_test[b](''test_method'')'),'$'], 'once')));
            iLine = iLine + 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                '----------------------------------------------------------------------$', 'once')));
            iLine = iLine + 1;
            assert_equals(false, isempty(regexp(linesCVec{iLine}, ...
                'foo failure$', 'once')));
        end
    end
end