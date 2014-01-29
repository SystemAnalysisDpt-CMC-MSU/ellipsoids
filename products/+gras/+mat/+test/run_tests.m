function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
suiteList{1}=loader.load_tests_from_test_case(...
'gras.mat.test.mlunit.SuiteBasic',varargin{:});
suiteList{2}=loader.load_tests_from_test_case(...
'gras.mat.test.mlunit.SuiteOp',varargin{:});
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
resList{1}=runner.run(suite);
%
result=[resList{:}];