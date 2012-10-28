function results=run_tests(varargin)
resList{1}=gras.ellapx.uncertcalc.test.run_tests(varargin{:});
resList{2}=gras.ellapx.smartdb.test.run_tests();
results=[resList{:}];