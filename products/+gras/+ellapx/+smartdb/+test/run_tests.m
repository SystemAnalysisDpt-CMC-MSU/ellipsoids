function results=run_tests(varargin)
runner = mlunit.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'gras.ellapx.smartdb.test.mlunit.SuiteEllTube');
resList{1}=runner.run(suite);
results=[resList{:}];