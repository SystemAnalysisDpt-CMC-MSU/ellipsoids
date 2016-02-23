function results=run_cont_tests(varargin)
testCase = 'gras.ellapx.lreachuncert.probdyn.test.mlunit.ProbDynUncertTC';

confList = {
    'demo3firstTest';
    'demo3secondTest';
    'demo3thirdTest';
    'demo3fourthTest';
};

suiteDefList = {
	struct(...
    'fDefConstr', @gras.ellapx.lreachuncert.probdef.ReachContLTIProblemDef,...
    'fDynConstrList', {{
        @gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.create
     }},...
    'confList', {confList([1 4])}...
    );
    
    struct(...
    'fDefConstr', @gras.ellapx.lreachuncert.probdef.LReachContProblemDef,...
    'fDynConstrList', {{
        @gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.create
    }},...
    'confList', {confList([2 3])}...
    );
    
    struct(...
    'fDefConstr', [],...
    'fDynConstrList', {{
        @gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.createByParams
    }},...
    'confList', {confList(3)}... %TODO: check to add more configs
    );
};

import gras.ellapx.lreachplain.probdyn.test.run_cont_tests_from_suitedef;
results=run_cont_tests_from_suitedef(testCase, suiteDefList, varargin{:});