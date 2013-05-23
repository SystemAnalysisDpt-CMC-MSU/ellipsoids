classdef mlunit_test_runtestcase < mlunitext.test_case
    % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2012-2013$
    methods
        function self = mlunit_test_runtestcase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        %
        function testTrickyTestName(~)
            result=mlunitext.runtestcase('mlunit_test.test_test_result',...
                'test_result');
            mlunitext.assert(result.getNTestsRun(),2);
            result=mlunitext.runtestcase('mlunit_test.test_test_result',...
                '^test_result');
            mlunitext.assert(result.getNTestsRun(),1);
        end
        function test_not_found(self)
            % If the test case class is not found or no test methods match
            % the pattern given to runtestcase, the method should throw an
            % exception
            self.runAndCheckError('mlunitext.runtestcase(''wrongClass'')',...
                ':noSuchClass');
            self.runAndCheckError(...
                'mlunitext.runtestcase(''wrongClass'',''someMethod'')',...
                ':noSuchClass');
            self.runAndCheckError(['mlunitext.runtestcase(''', class(self),...
                ''', ''wrongMethod'')'], ':wrongInput');
        end
        function test_marker(~)
            import mlunitext.*;
            tests{1} = mlunit_test.mock_test('test_method');
            tests{2} = mlunit_test.mock_test('test_broken_method');
            %
            runner=mlunitext.text_test_runner(1, 1);
            suite=test_suite(tests,'marker','nda');
            result = runner.run(suite);
            mlunitext.assert_equals(2, getNTestsRun(result));
            mlunitext.assert_equals('mlunit_test.mock_test[nda]',...
                suite.str());
            %
            loader = mlunitext.test_loader();
            suite=loader.load_tests_from_test_case(...
                'mlunit_test.mock_test','marker','nda');
            mlunitext.assert_equals('', suite.marker);
            mlunitext.assert_equals('mlunit_test.mock_test[nda]',...
                suite.str());
            cellfun(@checktest,suite.tests);
            function checktest(test)
                mlunitext.assert_equals('nda',test.marker);
            end
        end
        function test_run_and_check_errors(self) %#ok<MANU>
            %
            tCase =  mlunitext.test_case();
            ERROR_STRINGS = {'firstErr','secondErr','thirdErr','fourthErr'};
            ERROR_MSG = {'firstMsg!','','','fourthMsg'};
            %
            tCase.runAndCheckError(strcat('self.errorMaker',...
                '(ERROR_STRINGS{1},ERROR_MSG{1})'),...
                [],ERROR_MSG{1});
            tCase.runAndCheckError(strcat('self.errorMaker',...
                '(ERROR_STRINGS{1},ERROR_MSG{1})'),...
                ERROR_STRINGS{1});
            %
            tCase.runAndCheckError(strcat('self.errorMaker',...
                '(ERROR_STRINGS{1},ERROR_MSG{1})'),...
                ERROR_STRINGS{1},ERROR_MSG{1});
            tCase.runAndCheckError('self.errorMaker(ERROR_STRINGS{2})',...
                ERROR_STRINGS(1:4));
            tCase.runAndCheckError(strcat('self.errorMaker',...
                '(ERROR_STRINGS{1},ERROR_MSG{1})'),...
                ERROR_STRINGS(1:4),ERROR_MSG(1:4));
            tCase.runAndCheckError(strcat('self.errorMaker',...
                '(ERROR_STRINGS{2},ERROR_MSG{2})'),...
                ERROR_STRINGS(1:4),ERROR_MSG(1:4));
            %
            negTestRACE([1,4],1:4);
            negTestRACE([1,4],1);
            function negTestRACE(numErrVec,numMsgVec)
                try
                    tCase.runAndCheckError(strcat('self.errorMaker',...
                        '(ERROR_STRINGS{2},ERROR_MSG{2})'),...
                        ERROR_STRINGS(numErrVec),ERROR_MSG(numMsgVec));
                catch meObj
                    str = meObj.identifier;
                    isOk = ~isempty(strfind(str,'wrongInput'));
                    mlunitext.assert(isOk);
                end
            end
        end
        function errorMaker(self,msgIdent,varargin)
            import modgen.common.throwerror;
            if ~isempty(varargin)
                msgStr = varargin{1};
            else
                msgStr = '';
            end
            throwerror(msgIdent,msgStr);
        end
    end
end