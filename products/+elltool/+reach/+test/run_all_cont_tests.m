function results = run_all_cont_tests(varargin)
resList{1} = elltool.reach.test.run_most_cont_tests(varargin{:});
testCaseNameStr = 'elltool.reach.test.mlunit.ContinuousReachProjAdvTestCase';
resList{2} = elltool.reach.test.run_reach_proj_adv_tests(testCaseNameStr);
results = [resList{:}];
