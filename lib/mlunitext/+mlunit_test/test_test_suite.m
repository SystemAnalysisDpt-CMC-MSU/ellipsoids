classdef test_test_suite < mlunitext.test_case&mlunit_test.AuxChecker
    % TEST_TEST_SUITE tests the class test_suite.
    %
    %  Example:
    %         run(gui_test_runner, 'test_test_suite');
    %
    %  See also MLUNITEXT.TEST_SUITE.
    
    % $Author: Peter Gagarinov, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 7-October-2012, <pgagarinov@gmail.com>$
    
    properties (Access=private)
        result = 0;
        suite = 0;
    end
    
    methods
        function self = test_test_suite(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function set_up(self)
            % SET_UP SETS up the fixture for
            %
            %
            %  Example:
            %         run(gui_test_runner, 'test_test_suite');
            
            import mlunitext.*;
            
            self.result = test_result;
            self.suite = test_suite;
        end
        
        function test_add_tests(self)
            % TEST_ADD_TESTS tests the method
            %   test_suite.add_tests.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_suite(''test_add_tests'');');
            %
            %  See also MLUNIT_TEST.TEST_ADD_TESTS.
            
            tests{1} = mlunit_test.mock_test('test_method');
            tests{2} = mlunit_test.mock_test('test_broken_method');
            tests{3} = mlunit_test.mock_test('test_method_no_return');
            self.suite.add_tests(tests);
            self.result = run(self.suite, self.result);
            self.checkResultReport(self.result,3,1,0);
        end
        function testFromTestCaseNameList(~)
            % TEST_ADD_TESTS_AS_A_SUITE tests the method
            %   test_suite.add_tests with a test_suite as its argument.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_suite(''test_add_tests_as_a_suite'');');
            %
            %  See also MLUNIT_TEST.TEST_ADD_TESTS.
            
            import mlunitext.*;
            resultEth=mlunitext.test_result;
            resultAlt=mlunitext.test_result;
            suiteEth = load_tests_from_test_case(test_loader, ...
                'mlunit_test.mock_test');
            suiteEth.add_test(load_tests_from_test_case(test_loader, ...
                'mlunit_test.mock_sec_test'));
            
            suiteAlt=mlunitext.test_suite.fromTestCaseNameList({...
                'mlunit_test.mock_test','mlunit_test.mock_sec_test'});
            resultEth = run(suiteEth, resultEth);
            resultAlt = run(suiteAlt, resultAlt);
            
            assert_equals(getNTestsRun(resultEth),...
                getNTestsRun(resultAlt));
            assert_equals(getNErrors(resultEth),...
                getNErrors(resultAlt));
            assert_equals(getNFailures(resultEth),...
                getNFailures(resultAlt));
        end
        function test_add_tests_as_a_suite(self)
            % TEST_ADD_TESTS_AS_A_SUITE tests the method
            %   test_suite.add_tests with a test_suite as its argument.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_suite(''test_add_tests_as_a_suite'');');
            %
            %  See also MLUNIT_TEST.TEST_ADD_TESTS.
            
            import mlunitext.*;
            
            suite = load_tests_from_test_case(test_loader, ...
                'mlunit_test.mock_test');
            self.suite.add_test(suite);
            self.result = run(self.suite, self.result);
            assert_equals(3, getNTestsRun(self.result));
            assert_equals(1, getNErrors(self.result));
        end
        
        function test_construct(self)
            % TEST_CONSTRUCT tests the constructor of
            %   test_suite.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_suite(''test_construct'');');
            %
            %  See also MLUNITEXT.TEST_SUITE.
            %
            import mlunitext.*;
            %
            tests{1} = mlunit_test.mock_test('test_method');
            tests{2} = mlunit_test.mock_test('test_broken_method');
            suite = test_suite(tests);
            assert_equals('mlunit_test.mock_test', suite.str());
            
            self.result = run(suite, self.result);
            assert_equals(2, getNTestsRun(self.result));
            
            tests{2}.set_marker('broken');
            suite = test_suite(tests);
            assert_equals('mlunit_test.mock_test|mlunit_test.mock_test[broken]',...
                suite.str());
            suite.set_marker('nada');
            assert_equals('mlunit_test.mock_test[nada]', suite.str());
            %
            self.result = run(suite, self.result);
            assert_equals(4, getNTestsRun(self.result));
            %
        end
        function testGetCopyFiltered(~)
            import mlunitext.*;
            tests{1} = mlunit_test.mock_test('test_method');
            tests{2} = mlunit_test.mock_test('test_broken_method');
            suite = test_suite(tests);            
            suite2=test_suite(suite,'marker','suite2');
            %
            tests{1} = mlunit_test.mock_sec_test('test_method');
            tests{2} = mlunit_test.mock_sec_test('test_broken_method');
            suite3 = test_suite(tests);       
            suite4=test_suite(suite3,'marker','suite2');
            testList=[suite.tests,suite2.tests,suite3.tests,suite4.tests];
            suite=test_suite(testList);
            %
            check({'suite2','.*','test_method'},...
                {@(x)isequal(x.name,'test_method'),...
                @(x)isequal(x.marker,'suite2')},...
                4);
            %
            check({'.*','mock_sec_test','.*'},...
                {@(x)isequal(class(x),'mlunit_test.mock_sec_test')},...
                4);
            %
            function check(inpFiltList,fCheckList,nExp)
                import mlunitext.*;                
                suiteFilt=suite.getCopyFiltered(inpFiltList{:});                
                assert_equals(suiteFilt.count_test_cases,nExp);
                isOk=all(cellfun(@(x)isMatch(x,suiteFilt),fCheckList));
                assert(isOk);
                function isPos=isMatch(fMatch,suite)
                    isPos=all(cellfun(fMatch,suite.tests));
                end                              
            end
            %
        end
        function test_construct_copy(~)
            % TEST_CONSTRUCT_COPY tests the copy constructor
            %    of test_suite.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_suite(''test_construct_copy'');');
            %
            %  See also MLUNITEXT.TEST_SUITE.
            
            import mlunitext.*;
            %
            tests{1} = mlunit_test.mock_test('test_method');
            tests{2} = mlunit_test.mock_test('test_broken_method');
            tests{2}.set_marker('broken');
            aSuite = test_suite(tests);
            aSuite.set_name('aSuite');
            %
            suiteCopyAll = test_suite(aSuite);
            assert_equals(true, isequal(aSuite, suiteCopyAll));
            %
            aSuite.set_name('');
            suiteCopySome = test_suite(aSuite, tests(1));
            assert_equals(aSuite.name, suiteCopySome.name);
            assert_equals('mlunit_test.mock_test', suiteCopySome.str());
            assert_equals(true, isequal(suiteCopySome.tests, tests(1)));
        end
        
        function test_count_test_cases(~)
            % TEST_COUNT_TEST_CASES tests the method
            %   test_suite.count_tests_cases.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_suite(''test_count_test_cases'');');
            %
            %  See also MLUNITEXT.TEST_SUITE.COUNT_TEST_CASES.
            
            import mlunitext.*;
            
            suite = test_suite;
            assert(0 == count_test_cases(suite));
            suite.add_test(mlunit_test.mock_test('test_method'));
            assert(1 == count_test_cases(suite));
            suite.add_test(mlunit_test.mock_test('test_broken_method'));
            assert(2 == count_test_cases(suite));
        end
        function test_suite(self)
            % TEST_SUITE TESTS the basic behaviour of
            %   test_suite.run.
            %
            %  Example:
            %         run(gui_test_runner,
            %             'test_test_suite(''test_suite'');');
            %
            %  See also MLUNITEXT.TEST_SUITE.RUN.
            
            self.suite.add_test(mlunit_test.mock_test('test_method'));
            self.suite.add_test(...
                mlunit_test.mock_test('test_broken_method'));
            self.result = run(self.suite, self.result);
            self.checkResultReport(self.result,2,1,0);
            [nErrors,nFailures]=self.result.getErrorFailCount();
            assert(nErrors==1);
            assert(nFailures==0);
        end
    end
end