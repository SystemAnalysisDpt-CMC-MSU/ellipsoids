function result = run_discrete_reach_tests(varargin)
    runner = mlunitext.text_test_runner(1, 1);
    loader = mlunitext.test_loader;
    suiteBasic =...
        loader.load_tests_from_test_case(...
        'elltool.reach.test.mlunit.DiscreteReachTestCase', varargin{:});
    %
    suite = mlunit.test_suite(suiteBasic.tests);
    %
    result = runner.run(suite);
end