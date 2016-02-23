function results=run_discr_tests(varargin)
import gras.ellapx.lreachplain.probdyn.test.*;

confList = {
    'discrFirstTest';
    'discrSecondTest';
    'demo3thirdTest';
	'checkTime';
};

suiteDefList = {
	struct(...
    'fDefConstr', @gras.ellapx.lreachplain.probdef.LReachContProblemDef,...
    'fDynConstr', @gras.ellapx.lreachplain.probdyn.LReachDiscrForwardDynamics,...
	'testCase', 'gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainDiscrTC',...
    'confList', {confList}...
    );
};

results=run_discr_tests_from_suitedef(suiteDefList);
end