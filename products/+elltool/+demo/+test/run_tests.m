function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
suiteList = {};
suiteList{end+1} = loader.load_tests_from_test_case(...
    'elltool.demo.test.mlunit.ETManualTC');
suiteList{end+1} = loader.load_tests_from_test_case(...
       'elltool.demo.test.mlunit.BasicTestCase');
%
testLists = cellfun(@(x) x.tests, suiteList, 'UniformOutput', false);
suite = mlunitext.test_suite(horzcat(testLists{:}),...
    'nParallelProcesses',1,...
    'hExecFunc',@(varargin)elltool.demo.test.auxdfeval(varargin{:},...
    'alwaysFork',true));
%
%resultList{2}=elltool.demo.test.run_demo_tests();
resultList{1}=runner.run(suite);

result=[resultList{:}];