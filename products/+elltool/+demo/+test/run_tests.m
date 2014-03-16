function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;

nDirs = 5;
suiteList = {};
suiteList{end+1} = loader.load_tests_from_test_case(...
    'elltool.demo.test.mlunit.ETManualTC');
suiteList{end+1} = loader.load_tests_from_test_case(...
       'elltool.demo.test.mlunit.BasicTestCase');
suiteList{end+1} = loader.load_tests_from_test_case(...
       'elltool.demo.test.mlunit.TouchTestCase',...
       nDirs,'marker','testControl');
%
testLists = cellfun(@(x) x.tests, suiteList, 'UniformOutput', false);
suite = mlunitext.test_suite(horzcat(testLists{:}));
result=runner.run(suite);