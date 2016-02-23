function results=run_cont_tests(varargin)
testCase = 'gras.ellapx.lreachplain.probdyn.test.mlunit.ProbDynPlainTC';

confList = {
    'demo3firstTest';
    'demo3secondTest';
    'demo3thirdTest';
    'demo3fourthTest';
};

suiteDefList = {
	struct(...
    'fDefConstr', @gras.ellapx.lreachplain.probdef.ReachContLTIProblemDef,...
    'fDynConstrList', {{
        @gras.ellapx.lreachplain.probdyn.LReachProblemDynamicsFactory.create
     }},...
    'confList', {confList([1 4])}...
    );
    
    struct(...
    'fDefConstr', @gras.ellapx.lreachplain.probdef.LReachContProblemDef,...
    'fDynConstrList', {{
        @gras.ellapx.lreachplain.probdyn.LReachProblemDynamicsFactory.create
    }},...
    'confList', {confList([2 3])}...
    );
    
    struct(...
    'fDefConstr', [],...
    'fDynConstrList', {{
        @gras.ellapx.lreachplain.probdyn.LReachProblemDynamicsFactory.createByParams
    }},...
    'confList', {confList([1 2 3 4])}...
    );
};

import gras.ellapx.lreachplain.probdyn.test.*;
results=run_cont_tests_from_suitedef(testCase, suiteDefList, varargin{:});