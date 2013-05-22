classdef test_loader
    % TEST_LOADER loads tests from test case classes
    %
    % $Authors: Peter Gagarinov <pgagarinov@gmail.com>
    % $Date: March-2013 $
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2012-2013$
    %
    methods
        %
        function methodNameList = get_test_case_names(~, testCaseClassName)
            % GET_TEST_CASE_NAMES returns a list of string
            % with all test* methods from the test_case_class.
            %
            % Input:
            %   regular:
            %       self:
            %       test_case_class: mlunitext.test_case[1,1] - get test case
            %           method names
            % Output:
            %   names: cell[1,] of char[1,] - list of test case names
            % Example:
            %  get_test_case_names is for example called from
            %  test_loader.load_tests_from_test_case:
            %   names = get_test_case_names(self, test_case_class);
            %
            % See also MLUNITEXT.TEST_LOADER.LOAD_TESTS_FROM_MFILE.
            %
            import mlunitext.*;
            typeInfo = reflect(testCaseClassName);
            methodNameList = get_methods(typeInfo);
            isTestVec=cellfun(@(x)strncmp(x, 'test', 4),methodNameList);
            methodNameList=methodNameList(isTestVec);
            methodNameList = sort(methodNameList);
        end
        %
        function suite = load_tests_from_test_case(self,...
                testCaseClassName,varargin)
            % LOAD_TESTS_FROM_TEST_CASE returns a test_suite
            % with all test* methods from a test case. If tests are not
            % found an empty matrix returned
            %
            % Input:
            %   regular:
            %       self: mlunitext.test_loader[1,1]
            %       testCaseClassName: char[1,] - name of test case class
            %           from which the tests are to be loaded
            %
            %   optional/properties:
            %       any of the optional parameters or properties of
            %           mlunitext.test_case class
            %
            % Output:
            %   suite: mlunitext.test_suite
            %
            % Example:
            %   loader = test_loader;
            %   suite = test_suite(load_tests_from_test_case(loader, 'my_test'));
            
            import mlunitext.*;
            %
            testNameList = get_test_case_names(self, testCaseClassName);
            if isempty(testNameList)
                suite = test_suite;
            else
                suite = test_suite(map(self, ...
                    testCaseClassName, ...
                    testNameList,varargin{:}));
            end
        end
        %
        function testList = map(self, testCaseClassName, testMethodNameList,...
                varargin) %#ok
            % MAP returns a list of objects instantiated from
            % the class testCaseClassName and the methods specified by
            % testMethodNameList
            %
            % Input:
            %   regular:
            %       self: mlunitext.test_loader[1,1]
            %       testCaseClassName: char[1,] - name of test case class
            %           from which the tests are to be loaded
            %       testMethodNameList: cell[1,] of char[1,] - list of
            %       test case method names
            %
            %   optional/properties:
            %       any of the optional parameters or properties of
            %           mlunitext.test_case class
            %
            % Output:
            %   suite: mlunitext.test_suite
            %
            %  Example:
            %    If you have for example a test_case my_test with two
            %    methods test_foo1 and test_foo2, then
            %         map(test_loader, 'my_test', {'test_foo1' 'test_foo2'})
            %    returns a list with two objects of my_tests, one
            %    instantiated with test_foo1, the other with test_foo2.
            %
            %  See also MLUNITEXT.TEST_LOADER.LOAD_TESTS_FROM_MFILE.
            %
            nTests=length(testMethodNameList);
            testList = cell(1,nTests);
            for iTest = 1:nTests
                testObj = feval(testCaseClassName,...
                    testMethodNameList{iTest},...
                    testCaseClassName,varargin{:});
                testList{iTest} = testObj;
            end;
        end
    end
end
