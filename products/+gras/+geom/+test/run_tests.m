function results=run_tests(varargin)
suite = mlunitext.test_loader().load_tests_from_test_case(...
    'gras.geom.test.mlunit.SuiteBasic');
%
resCell{4}=mlunitext.text_test_runner(1,1).run(suite);
resCell{3}=gras.geom.ell.test.run_tests(varargin{:});
resCell{2}=gras.geom.tri.test.run_tests(varargin{:});
resCell{1}=gras.geom.sup.test.run_tests(varargin{:});
results=[resCell{:}];