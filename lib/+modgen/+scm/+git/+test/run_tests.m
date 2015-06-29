function results=run_tests()
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'modgen.scm.git.test.mlunit.TestSuite');
%
resList{1}=runner.run(suite);
results=[resList{:}];