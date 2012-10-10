classdef test_loader
    % TEST_LOADER  is used to create a test_suite with all  test*
    % methods from a test_case.
    %
    % Example:
    %   loader = test_loader;
    %   suite = test_suite(load_tests_from_test_case(loader, 'my_test'));
    %
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Applied Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    methods
        function names = get_test_case_names(self, test_case_class) 
            % GET_TEST_CASE_NAMES returns a list of string
            % with all test* methods from the test_case_class.
            %
            % Input:
            %   regular:
            %       self:
            %       test_case_class: mlunit.test_case[1,1] - get test case
            %           method names
            % Output:
            %   names: cell[1,] of char[1,] - list of test case names
            % Example:
            %  get_test_case_names is for example called from
            %  test_loader.load_tests_from_test_case:
            %   names = get_test_case_names(self, test_case_class);
            %
            % See also MLUNIT.TEST_LOADER.LOAD_TESTS_FROM_MFILE.
            %
            import mlunit.*;
            t = reflect(test_case_class);
            names = get_methods(t);
            for i = size(names, 1):-1:1
                if (~strncmp(names(i), 'test', 4))
                    names(i) = [];
                end;
            end;
            names = sortrows(names);
            if (~isempty(names))
                t = eval([test_case_class, '(''', char(names(1)), ''')']);
            end;
            
            if (~isa(t, 'test_case'))
                names = [];
            end;
        end
        
        function suite = load_tests_from_test_case(self, test_case_class)
            % LOAD_TESTS_FROM_TEST_CASE returns a test_suite
            % with all test* methods from a test_case. It returns an 
            % empty matrix, if the test is not found.
            %
            % Input:
            %   regular:
            %       self:
            %       test_case_class: mlunit.test_case[1,1] - test case
            %           object
            %
            % Output:
            %   suite: mlunit.test_suite[1,1] - resulting test suite
            %
            % Example:
            %   loader = test_loader;
            %   suite = test_suite(load_tests_from_test_case(loader, 'my_test'));
            
            import mlunit.*;
            suite = [];
            names = get_test_case_names(self, test_case_class);
            if (~isempty(names))
                suite = test_suite(map(self, ...
                    test_case_class, ...
                    names));
            end;
        end
        
        function tests = map(self, test_case_class, test_names) %#ok
            % MAP returns a list of objects instantiated from
            %   the class test_case_class and the methods in test_names.
            %
            % Input:
            %   regular:
            %       self:
            %       test_case_class: char[1,] - test case class name
            %       test_names: cell[1,] of char[1,] - list of test names
            %
            % Output:
            %   tests: cell[1,] of mlunit.test_case[1,1] - list of created
            %       test objects
            %
            %  Example:
            %    If you have for example a test_case my_test with two
            %    methods test_foo1 and test_foo2, then
            %         map(test_loader, 'my_test', {'test_foo1' 'test_foo2'})
            %    returns a list with two objects of my_tests, one
            %    instantiated with test_foo1, the other with test_foo2.
            %
            %  See also MLUNIT.TEST_LOADER.LOAD_TESTS_FROM_MFILE.
            
            tests = {};
            for i = 1:length(test_names)
                test = eval([test_case_class, '(''', char(test_names(i)), ''')']);
                tests{i} = test; %#ok<AGROW>
            end;
        end
    end
end