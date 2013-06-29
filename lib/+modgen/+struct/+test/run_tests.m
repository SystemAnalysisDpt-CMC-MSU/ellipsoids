function results=run_tests()
%
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'modgen.struct.test.mlunit_test_structcompare');
%
suite_mixed = loader.load_tests_from_test_case(...
    'modgen.struct.test.StructDispTC');
%
suite = mlunitext.test_suite(horzcat(...
    suite.tests,suite_mixed.tests));
%
results=runner.run(suite);
resVec=modgen.struct.changetracking.test.run_tests();
%
results=[results,resVec];