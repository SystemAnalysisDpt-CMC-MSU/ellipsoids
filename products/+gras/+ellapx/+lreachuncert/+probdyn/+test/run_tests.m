function results=run_tests(varargin)
testCase = 'gras.ellapx.lreachuncert.probdyn.test.mlunit.ProbDynUncertTC';

confList = {
    'demo3firstTest';
    'demo3secondTest';
    'demo3thirdTest';
    'demo3fourthTest';
};

suiteDefList = {
	struct(...
    'defConstr', @gras.ellapx.lreachuncert.probdef.ReachContLTIProblemDef,...
    'dynConstr', {{
        @gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.create
     }},...
    'confs', {confList([1 4])}...
    );
    
    struct(...
    'defConstr', @gras.ellapx.lreachuncert.probdef.LReachContProblemDef,...
    'dynConstr', {{
        @gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.create
    }},...
    'confs', {confList([2 3])}...
    );
    
    struct(...
    'defConstr', [],...
    'dynConstr', {{
        @gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory.createByParams
    }},...
    'confs', {confList(3)}... %TODO: check to add more configs
    );
};

import gras.ellapx.lreachplain.probdyn.test.run_cont_tests_from_package;
results=run_cont_tests_from_package(testCase, suiteDefList, varargin{:});