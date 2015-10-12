function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suiteText = loader.load_tests_from_test_case('mlunitext.test.mlunit_test_text_test_result');
suiteRunTestCase = loader.load_tests_from_test_case('mlunitext.test.mlunit_test_runtestcase');
suiteSaveXml = loader.load_tests_from_test_case('mlunitext.test.mlunit_test_savexml');
%
suite = mlunitext.test_suite(horzcat(...
    suiteText.tests,...
    suiteRunTestCase.tests,...
    suiteSaveXml.tests));
%
resList{2}=runner.run(suite);
%reference to mlunitext tests
resList{1}=mlunit_test.run();
%
result=[resList{:}];
