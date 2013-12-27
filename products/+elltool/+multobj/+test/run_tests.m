function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
suite = mlunitext.test_suite.fromTestCaseNameList({...
    'elltool.multobj.test.mlunit.ObjectApproximationTestCase'}, varargin);
   
%
result=runner.run(suite);