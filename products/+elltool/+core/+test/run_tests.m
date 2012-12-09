function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
 suite1 = loader.load_tests_from_test_case(...
     'elltool.core.test.mlunit.EllipsoidIntUnionTC',varargin{:});
 suite2 =loader.load_tests_from_test_case(...
     'elltool.core.test.mlunit.EllipsoidTestCase',varargin{:});
 suite3 =loader.load_tests_from_test_case(...
     'elltool.core.test.mlunit.EllipsoidSecTestCase',varargin{:});
 suite4 = loader.load_tests_from_test_case(...
         'elltool.core.test.mlunit.HyperplaneTestCase', varargin{:});
 suite=mlunit.test_suite(horzcat(suite1.tests,suite2.tests,suite3.tests,suite4.tests));
 resList{1}=runner.run(suite);
 
 suite = loader.load_tests_from_test_case(...
 'elltool.core.test.mlunit.EllipsoidTestCase',varargin{:});
 resList{2}=runner.run(suite);
 
 suite = loader.load_tests_from_test_case(...
 'elltool.core.test.mlunit.EllipsoidSecTestCase',varargin{:});
 resList{3}=runner.run(suite);
 
 suite = loader.load_tests_from_test_case(...
 'elltool.core.test.mlunit.HyperplaneTestCase',varargin{:});
 resList{4}=runner.run(suite);

 suite = loader.load_tests_from_test_case(...
 'elltool.core.test.mlunit.GenEllipsoidTestCase',varargin{:});
 resList{5}=runner.run(suite);

result=[resList{:}];