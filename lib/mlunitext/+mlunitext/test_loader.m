classdef test_loader<mlunit.test_loader
    % TEST_LOADER loads tests from test case classes
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    %
    methods
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
            suite=load_tests_from_test_case@mlunit.test_loader(self,...
                testCaseClassName,varargin{:});
            suite=mlunitext.test_suite(suite.tests);
        end
    end
end
