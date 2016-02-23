function results=run_discr_tests(varargin)

confList = {
    'discrFirstTest';
    'discrSecondTest';
    'demo3thirdTest';
    'checkTime';
};

suiteDefList = {
	struct(...
    'fDefConstr', @gras.ellapx.lreachuncert.probdef.LReachContProblemDef,...
    'fDynConstr', @gras.ellapx.lreachuncert.probdyn.LReachDiscrForwardDynamics,...
	'testCase', 'gras.ellapx.lreachuncert.probdyn.test.mlunit.ProbDynUncertDiscrTC',...
    'confList', {confList}...
    );
};

import gras.ellapx.lreachplain.probdyn.test.run_discr_tests_from_suitedef;
results=run_discr_tests_from_suitedef(suiteDefList);
end