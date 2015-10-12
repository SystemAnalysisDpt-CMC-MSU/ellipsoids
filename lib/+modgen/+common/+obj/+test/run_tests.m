function results=run_tests()
runner = mlunitext.text_test_runner(1, 1);
suite = mlunitext.test_suite.fromTestCaseNameList(...
    {'modgen.common.obj.test.mlunit.TestSuiteStaticProp',...
    'modgen.common.obj.test.mlunit.HandleObjectClonerTC'});
%
results=runner.run(suite);