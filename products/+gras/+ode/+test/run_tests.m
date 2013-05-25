function results=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
suiteList{1} = loader.load_tests_from_test_case(...
    'gras.ode.test.mlunit.SuiteBasic', 'gras.ode.ode45reg',...
    'ode45','marker','ode45');
suiteList{2} = loader.load_tests_from_test_case(...
    'gras.ode.test.mlunit.SuiteBasic', 'gras.ode.ode113reg',...
    'ode113','marker','ode113');
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));

results=runner.run(suite);
