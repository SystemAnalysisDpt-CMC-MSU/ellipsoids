function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite1 = loader.load_tests_from_test_case(...
    'elltool.core.test.mlunit.EllipsoidIntUnionTC',varargin{:});
suite2 =loader.load_tests_from_test_case(...
    'elltool.core.test.mlunit.EllipsoidTestCase',varargin{:});
suite3 = loader.load_tests_from_test_case(...
        'elltool.core.test.mlunit.HyperplaneTestCase', varargin{:});
suite=mlunit.test_suite(horzcat(suite1.tests,suite2.tests,suite3.tests));

result=runner.run(suite);