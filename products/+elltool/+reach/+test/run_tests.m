function results=run_tests(varargin)
resList{1} = elltool.reach.test.run_discr_tests();
resList{2} = elltool.reach.test.run_cont_tests();
results=[resList{:}];
