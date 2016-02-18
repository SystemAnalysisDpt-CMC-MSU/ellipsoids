function results=run_tests(varargin)
resList={};

resList{end+1}=gras.ellapx.uncertcalc.test.run_tests(varargin{:});
resList{end+1}=gras.ellapx.uncertmixcalc.test.run_tests(varargin{:});
resList{end+1}=gras.ellapx.smartdb.test.run_tests(varargin{:});
resList{end+1}=gras.ellapx.lreachplain.probdef.test.run_tests(varargin{:});
resList{end+1}=gras.ellapx.lreachuncert.probdef.test.run_tests(varargin{:});

results=[resList{:}];