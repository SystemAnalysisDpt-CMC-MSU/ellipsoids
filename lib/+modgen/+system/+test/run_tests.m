function results=run_tests()
runner = mlunitext.text_test_runner(1, 1);
suite=mlunitext.test_suite.fromTestCaseNameList(...
    {'modgen.system.test.BasicTC'});
%
resList{1}=runner.run(suite);
results=[resList{:}];