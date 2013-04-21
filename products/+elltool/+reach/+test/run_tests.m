function results=run_tests(varargin)
resList{1} = elltool.reach.test.run_discrete_reach_tests();
% resList{2} = elltool.reach.test.run_continuous_reach_tests();
results=[resList{:}];