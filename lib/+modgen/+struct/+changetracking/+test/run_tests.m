function results=run_tests()
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'modgen.struct.changetracking.test.mlunit_test_structchangetracker');
%
suite = mlunitext.test_suite(horzcat(...
    suite.tests));
results=runner.run(suite);
