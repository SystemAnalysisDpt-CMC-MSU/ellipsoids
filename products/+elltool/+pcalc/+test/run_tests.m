function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
suite = mlunitext.test_suite.fromTestCaseNameList({...
    'elltool.pcalc.test.mlunit.ParCalculatorTestCase'}, varargin);
   
%
result=runner.run(suite);
