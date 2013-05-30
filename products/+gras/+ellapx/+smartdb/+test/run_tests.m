function results=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite1 = loader.load_tests_from_test_case(...
    'gras.ellapx.smartdb.test.mlunit.SuiteEllTube');
suite2 = loader.load_tests_from_test_case(...
    'gras.ellapx.smartdb.test.mlunit.EllTubePlotPropTest');
resList{1} = runner.run(suite1);
resList{2} = runner.run(suite2);
results=[resList{:}];