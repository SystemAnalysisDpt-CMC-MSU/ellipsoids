function results=run_tests(varargin)
resList{1} = lib_run_tests(varargin{:});
resList{2} = elltool.core.tests.run_tests();

results = [resList{:}];