function results=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;

suiteGoodDirs = loader.load_tests_from_test_case(...
    'gras.ellapx.lreachplain.test.mlunit.GoodDirsTestCase');

resList{1} = runner.run(suiteGoodDirs);
results=[resList{:}];