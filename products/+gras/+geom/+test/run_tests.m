function results=run_tests(varargin)
resCell{3}=gras.geom.ell.test.run_tests(varargin{:});
resCell{2}=gras.geom.tri.test.run_tests(varargin{:});
resCell{1}=gras.geom.sup.test.run_tests(varargin{:});
results=[resCell{:}];