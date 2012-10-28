function results=run_tests(varargin)
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'gras.la.test.mlunit.SuiteOrthTransl');
%
resList{1}=runner.run(suite);
results=[resList{:}];