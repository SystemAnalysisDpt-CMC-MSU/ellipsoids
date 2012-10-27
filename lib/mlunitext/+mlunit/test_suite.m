classdef test_suite < handle
    % The class test_suite is a composite class to run multiple tests. A
    % test suite is created as follows:
    %
    %  Example:
    %         suite = test_suite;
    %         suite = add_test(suite, my_test('test_foo'));
    %         suite = add_test(suite, my_test('test_bar'));
    %  or
    %         loader = test_loader;
    %         suite = test_suite(load_tests_from_test_case(loader, 'my_test'));
    %
    %  Running a test suite is done the same way as a single test. Example:
    %         result = test_result;
    %         [suite, result] = run(suite, result);
    %         summary(result)
    %
    %  See also MLUNIT.TEST_CASE, MLUNIT.TEST_LOADER, MLUNIT.TEST_RESULT.
    
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    properties (Access=private)
        confRepoMgr = [];
        hConfFunc = [];
    end
    
    properties (SetAccess=protected,GetAccess=public)
        tests = {};
        name = '';
        % The marker property is needed so that suites can be treated like
        % tests when they are part of another suite
        marker = '';
    end
    
    methods
        function set.tests(self,value)
            % SET.TESTS puts a list of test suites or test cases into the
            % suite
            %
            % Input:
            %   regular:
            %       self:
            %       value: cell[1,] of
            %           mlunit.test_suite1[1,1]/mlunit.test_case[1,1] -
            %           list of test suites or test cases to inject into
            %           the suite
            
            if ~all(cellfun(@(x)isa(x,'mlunit.test_case'),value)|...
                    cellfun(@(x)isa(x,'mlunit.test_suite'),value))
                error([upper(mfilename),':wrongInput'],...
                    ['tests property can only contain ',...
                    'test_case and test_suite class objects']);
            end
            self.tests=value;
        end
        function self = test_suite(varargin)
            % TEST_SUITE constructor
            %
            % Case#1: Regular constructor:
            % Input:
            %   optional:
            %     tests: cell[1,] of mlunit.test_suite/
            %           mlunit.test_suite[1,1] - test_case objects. When
            %           omitted, an empty suite is constructed
            %   properties:
            %     confRepoMgr: object[1,1] - a ConfRepoManager instance,
            %       used in some applications for configuring a logger (see
            %       hConfFunc)
            %     hConfFunc: function_handle[1,1] - function that the RUN
            %       method will call in order to configure a logger. It
            %       will be passed confRepoMgr as a parameter. Either both
            %       or neither hConfFunc and confRepoMgr should be given.
            %
            % Case#2: Copy constructor:
            % Input:
            %   regular:
            %     testSuite: mlunit.test_suite[1,1] - an instance of
            %       mlunit.test_suite
            %   optional:
            %     tests: cell[1,] of mlunit.test_suite/
            %           mlunit.test_suite[1,1] - test_case objects. If
            %       specified, these tests are assigned to the copy suite,
            %       instead of the tests in the original suite
            %
            % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
            % Faculty of Computational Mathematics and Cybernetics, System Analysis
            % Department, 7-October-2012, <pgagarinov@gmail.com>$
            
            [reg,prop]=modgen.common.parseparams(varargin);
            nReg = length(reg);
            nProp=length(prop);
            if nReg > 0 && nReg < 3 && isa(reg{1}, class(self))
                %% Copy constructor
                %
                if nProp > 0
                    error([upper(mfilename),':wrongInput'], ...
                        'Copy constructor does not take any properties');
                end
                testSuite = reg{1};
                if nReg > 1
                    self.tests = reg{2};
                    checkTests('Invalid size or type of parameter #2');
                else
                    self.tests = testSuite.tests;
                end
                self.name = testSuite.name;
                self.confRepoMgr = testSuite.confRepoMgr;
                self.hConfFunc = testSuite.hConfFunc;
            else
                %% Regular constructor
                %
                if (nReg == 0)
                    self.tests = cell(0,1);
                elseif nReg == 1
                    self.tests = reg{1};
                    checkTests('Invalid size or type of parameter #1');
                else
                    error([upper(mfilename),':wrongInput'], ...
                        'Too many regular arguments');
                end;
                %
                for iProp=1:2:nProp-1,
                    switch lower(prop{iProp})
                        case 'confrepomgr',
                            self.confRepoMgr=prop{iProp+1};
                            if ~isscalar(self.confRepoMgr) ...
                                    || ~isa(self.confRepoMgr, ...
                                    'modgen.configuration.ConfRepoManager')
                                error([upper(mfilename),':wrongInput'], ...
                                    'Invalid size or type of %s', prop{iProp});
                            end
                        case 'hconffunc',
                            self.hConfFunc=prop{iProp+1};
                            if ~isscalar(self.hConfFunc) ...
                                    || ~isa(self.hConfFunc, 'function_handle')
                                error([upper(mfilename),':wrongInput'], ...
                                    'Invalid size or type of %s', prop{iProp});
                            end
                        otherwise
                            error([upper(mfilename),':wrongInput'], ...
                                'Unknown property: %s', prop{iProp});
                    end
                end
                if isempty(self.confRepoMgr) && ~isempty( self.hConfFunc) ...
                        || ~isempty(self.confRepoMgr) && isempty( self.hConfFunc)
                    error([upper(mfilename),':wrongInput'], ...
                        'Either none or both confRepoMgr and hConfFunc should be specified');
                end
                % Default configuration
                if isempty(self.hConfFunc)
                    self.hConfFunc = @(x)modgen.logging.log4j.Log4jConfigurator.configureSimply;
                end
            end
            %
            %
            function checkTests(msg)
                if ~iscell(self.tests) || ~isvector(self.tests) ...
                        || ~isempty(self.tests) &&...
                        ~all(cellfun(@(x)(isa(x,'mlunit.test_case')||...
                        isa(x,'mlunit.test_suite')),self.tests))
                    error([upper(mfilename),':wrongInput'], msg);
                end
            end
        end
        function add_test(self, test)
            % ADD_TEST adds a test to the test suite. If test is empty,
            % nothing is done.
            %
            % Input:
            %   regular:
            %       self:
            %       test: mlunit.test_case[1,1] /mlunit.test_suite[1,1] -
            %           source of added tests
            %
            % Example:
            %         suite = test_suite;
            %         suite = add_test(suite, my_test('test_foo'));
            %         suite = add_test(suite, my_test('test_bar'));
            %         count_test_cases(suite); % Should return 2.
            %
            %  See also MLUNIT.TEST_SUITE.
            
            if (~isempty(test))
                self.tests{length(self.tests) + 1} = test;
            end;
        end
        
        function add_tests(self, tests)
            % ADD_TEST adds a cell array of tests to the test
            % suite.
            %
            % Example:
            %         suite = test_suite;
            %         suite = add_tests(suite, {my_test('test_foo') ...
            %             my_test('test_bar')});
            %         count_test_cases(suite); % Should return 2.
            %
            %  See also MLUNIT.TEST_SUITE.
            %
            modgen.common.type.simple.checkgen(tests,'iscell(x)');
            self.tests = [self.tests,tests];
        end
        function count = count_test_cases(self)
            % COUNT_TEST_CASES returns the number of test cases
            % executed by run.
            %
            % Example:
            %   suite = mlunit_all_tests;
            %   count_test_cases(test);
            %
            % See also MLUNIT.TEST_SUITE, MLUNIT.TEST_CASE.
            
            nTests = length(self.tests);
            count = 0;
            for i = 1:nTests
                count = count + count_test_cases(self.tests{i});
            end;
        end
        
        function result = run(self, result)
            % RUN executes the test suite and saves the results
            % in result.
            %
            % Input:
            %   self:
            %   result: mlunit.test_result[1,1] - destination object for
            %   the test results
            %
            % Example:
            %    Running a test suite is done the same way as a single
            %    test.
            %       suite = ...; % Create test suite, e.g. with test_loader.
            %       result = test_result;
            %       [suite, result] = run(suite, result);
            %       summary(result)
            %
            %  See also MLUNIT.TEST_SUITE.
            
            feval(self.hConfFunc, self.confRepoMgr);
            %
            nTests = length(self.tests);
            mlunit.logprintf('debug', '==== START suite [%s] with %d tests', ...
                self.str(), nTests);
            for i = 1:nTests
                if (get_should_stop(result))
                    break;
                end;
                
                result = run(self.tests{i}, result);
            end;
            mlunit.logprintf('debug', '====  END  suite [%s]', self.str());
        end
        
        function set_name(self, name)
            % SET_NAME sets an optional name for the test suite.
            %  The name is used by gui_test_runner to re-run a test_suite,
            %  which is created by an .m-file.
            %
            % Input:
            %   regular:
            %       self:
            %       name: char[1,] - name of the suite
            %
            %  Example:
            %         function suite = all_tests
            %
            %         suite = test_suite;
            %         suite = set_name(suite, 'all_tests');
            %         suite = add_test(suite, my_test('test_foo'));
            %         suite = add_test(suite, my_test('test_bar'));
            
            self.name = name;
        end
        
        function set_marker(self, marker)
            % MARK_TESTS marks all constituent tests with the
            % same marker
            %
            % Input:
            %   regular:
            %       self:
            %       marker: char[1,] - marker
            %
            cellfun(@(x)x.set_marker(marker), self.tests);
        end
        
        function s = str(self)
            % STR returns a string with the name of the test
            % suite. The name has to be set with SET_DISPLAY_NAME method
            % first.
            %
            % Example:
            %   str(mlunit_all_tests)
            
            if ~isempty(self.name)
                s = self.name;
            else
                % Concatenate all unique class-name/marker pairs from the
                % constituent tests
                testClassCVec = cellfun(@class, self.tests, 'UniformOutput', false);
                testMarkerCVec = cellfun(@(x)x.marker, self.tests, 'UniformOutput', false);
                isEmptyMarker = cellfun(@isempty, testMarkerCVec);
                testMarkerCVec(~isEmptyMarker) = cellfun(@(x)['[',x,']'],...
                    testMarkerCVec(~isEmptyMarker), 'UniformOutput', false);
                testNameCVec = cellfun(@(x,y)[x,y], testClassCVec, testMarkerCVec, ...
                    'UniformOutput', false);
                s = modgen.string.catwithsep( sort(unique(testNameCVec)), '|' );
            end
        end
    end
end