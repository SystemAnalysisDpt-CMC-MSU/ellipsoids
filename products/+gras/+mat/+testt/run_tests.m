function result=run_tests(varargin)
runner = mlunitext.text_test_runner(1, 1);
loader = mlunitext.test_loader;
%
%disp('222');
suiteList{1}=loader.load_tests_from_test_case(...
'gras.mat.testt.mlunit.Test1',varargin{:});
%
testLists=cellfun(@(x)x.tests,suiteList,'UniformOutput',false);
suite=mlunitext.test_suite(horzcat(testLists{:}));
%
resList{1}=runner.run(suite);
%
result=[resList{:}];