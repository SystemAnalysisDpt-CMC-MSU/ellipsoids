function results=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suite = loader.load_tests_from_test_case(...
    'gras.ellapx.uncertcalc.test.regr.mlunit.SuiteBasic');
%
resList{1}=runner.run(suite);
resList{2}=gras.ellapx.uncertcalc.conf.sysdef.test.run_tests();
resList{3}=gras.ellapx.uncertcalc.test.regr.run_support_function_tests();
resList{4}=gras.ellapx.uncertcalc.test.regr.run_regr_tests();
%
results=[resList{:}];