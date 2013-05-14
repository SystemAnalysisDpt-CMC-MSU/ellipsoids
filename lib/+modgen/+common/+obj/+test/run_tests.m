function results=run_tests()
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'modgen.common.obj.test.mlunit.TestSuiteStaticProp');
%
results=runner.run(suite);