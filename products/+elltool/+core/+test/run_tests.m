function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
'elltool.core.test.mlunit.EllipsoidIntUnionTC',varargin{:});
resList{1}=runner.run(suite);

suite = loader.load_tests_from_test_case(...
'elltool.core.test.mlunit.EllipsoidTestCase',varargin{:});
resList{2}=runner.run(suite);

suite = loader.load_tests_from_test_case(...
'elltool.core.test.mlunit.HyperplaneTestCase',varargin{:});
resList{3}=runner.run(suite);

result=[resList{:}];