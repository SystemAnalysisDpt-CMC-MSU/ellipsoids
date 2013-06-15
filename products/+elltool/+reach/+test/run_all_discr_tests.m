function results = run_all_discr_tests(varargin)
resList{1} = elltool.reach.test.run_most_discr_tests(varargin{:});
testCaseNameStr = 'elltool.reach.test.mlunit.DiscreteReachProjAdvTestCase';
resList{2} = elltool.reach.test.run_reach_proj_adv_tests(testCaseNameStr);
results = [resList{:}];