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
    'defConstr', @gras.ellapx.lreachplain.probdef.LReachContProblemDef,...
    'dynConstr', @gras.ellapx.lreachplain.probdyn.LReachDiscrForwardDynamics,...
    'confs', {confList},...
    'TC', 'gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainDiscrTC'...
    );
};

results=run_discr_tests_from_suitedef(suiteDefList);
end