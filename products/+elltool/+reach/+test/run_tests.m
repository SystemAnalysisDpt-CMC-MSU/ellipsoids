function result = run_tests(varargin)
    runner = mlunitext.text_test_runner(1, 1);
    suite =mlunitext.test_suite.fromTestCaseNameList({...
        'elltool.reach.test.mlunit.NewReachTestCase',...
        'elltool.reach.test.mlunit.ReachTestCase'},varargin);
    %
result = runner.run(suite);