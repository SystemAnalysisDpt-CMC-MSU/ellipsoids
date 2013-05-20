function results=run_tests(varargin)
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'modgen.string.test.mlunit_test_string');
%
results=runner.run(suite);