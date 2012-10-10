classdef test_loader<mlunit.test_loader
    %TEST_LOADER_EXTENDED Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function suite = load_tests_from_test_case(self, test_case_class,varargin)
            %test_loader.load_tests_from_test_case returns a test_suite
            %with all test* methods from a test_case.
            %  It returns an empty matrix, if the test is not found.
            %
            %  Example:
            %         loader = test_loader;
            %         suite = test_suite(load_tests_from_test_case(loader, 'my_test'));
            
            import mlunitext.*;
            
            suite = test_suite;
            names = get_test_case_names(self, test_case_class);
            if (~isempty(names))
                suite = test_suite(map(self, ...
                    test_case_class, ...
                    names,varargin{:}));
            end;
        end
        function tests = map(self, test_case_class, test_names,varargin) %#ok
            %test_loader.map returns a list of objects instantiated from
            %the class test_case_class and the methods in test_names.
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
                %test = eval([test_case_class, '(''', char(test_names(i)), ''')']);
                test = feval(test_case_class, test_names{i},test_case_class,varargin{:});
                tests{i} = test; %#ok<AGROW>
            end;
        end
    end
    
end

