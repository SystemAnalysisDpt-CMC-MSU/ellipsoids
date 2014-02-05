function testResVec=run_tests(varargin)
resList{2}=modgen.graphics.bld.test.run_tests(varargin{:});
%
runner = mlunitext.text_test_runner(1, 1);
%
loader = mlunitext.test_loader;
suite=loader.load_tests_from_test_case(...
    'modgen.graphics.test.mlunit.SuiteBasic');

resList{1}=runner.run(suite);
%
testResVec=[resList{:}];