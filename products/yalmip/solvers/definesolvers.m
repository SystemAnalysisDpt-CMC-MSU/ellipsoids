function solver = definesolvers

% ****************************
% Create a default solver
% ****************************
emptysolver.tag     = '';
emptysolver.version = '';
emptysolver.subversion = '';
emptysolver.checkfor= {''};
emptysolver.testcode= {''};
emptysolver.call    = '';
emptysolver.subcall = '';
emptysolver.show    = 1;
emptysolver.usesother = 0;

emptysolver.objective.linear = 0;
emptysolver.objective.quadratic.convex = 0;
emptysolver.objective.quadratic.nonconvex = 0;
emptysolver.objective.polynomial = 0;
emptysolver.objective.maxdet.convex = 0;
emptysolver.objective.maxdet.nonconvex = 0;
emptysolver.objective.sigmonial = 0;

emptysolver.constraint.equalities.linear     = 0;
emptysolver.constraint.equalities.quadratic  = 0;
emptysolver.constraint.equalities.polynomial = 0;
emptysolver.constraint.equalities.sigmonial  = 0;

emptysolver.constraint.inequalities.elementwise.linear = 0;
emptysolver.constraint.inequalities.elementwise.quadratic.convex = 0;
emptysolver.constraint.inequalities.elementwise.quadratic.nonconvex = 0;
emptysolver.constraint.inequalities.elementwise.polynomial = 0;
emptysolver.constraint.inequalities.elementwise.sigmonial = 0;

emptysolver.constraint.inequalities.semidefinite.linear = 0;
emptysolver.constraint.inequalities.semidefinite.quadratic = 0;
emptysolver.constraint.inequalities.semidefinite.polynomial = 0;
emptysolver.constraint.inequalities.semidefinite.sigmonial = 0;
emptysolver.constraint.inequalities.rank = 0;

emptysolver.constraint.inequalities.secondordercone = 0;
emptysolver.constraint.inequalities.rotatedsecondordercone = 0;
emptysolver.constraint.inequalities.powercone = 0;

emptysolver.constraint.complementarity.linear  = 0;
emptysolver.constraint.complementarity.nonlinear  = 0;

emptysolver.constraint.integer = 0;
emptysolver.constraint.binary = 0;
emptysolver.constraint.semivar = 0;
emptysolver.constraint.semiintvar = 0;
emptysolver.constraint.sos1 = 0;
emptysolver.constraint.sos2 = 0;

emptysolver.dual       = 0;
emptysolver.complex    = 0;
emptysolver.interval   = 0;
emptysolver.parametric = 0;
emptysolver.evaluation = 0;
emptysolver.uncertain  = 0;

% **************************************
% Some standard solvers to simplify code
% **************************************

% LP solver
lpsolver = emptysolver;
lpsolver.objective.linear = 1;
lpsolver.constraint.equalities.linear = 1;
lpsolver.constraint.inequalities.elementwise.linear = 1;
lpsolver.dual = 1;

% QP solver
qpsolver = emptysolver;
qpsolver.objective.linear = 1;
qpsolver.objective.quadratic.convex = 1;
qpsolver.constraint.equalities.linear = 1;
qpsolver.constraint.inequalities.elementwise.linear = 1;
qpsolver.dual = 1;

% SDP solver
sdpsolver = emptysolver;
sdpsolver.objective.linear = 1;
sdpsolver.constraint.equalities.linear = 1;
sdpsolver.constraint.inequalities.elementwise.linear = 1;
sdpsolver.constraint.inequalities.semidefinite.linear = 1;
sdpsolver.dual = 1;

% ****************************
% INITIALIZE COUNTER
% ****************************
i = 1;

% ****************************
% DEFINE SOLVERS
% ****************************

solver(i) = qpsolver;
solver(i).tag     = 'GUROBI';
solver(i).version = 'GUROBI';
solver(i).checkfor= {'gurobi'};
solver(i).call    = 'callgurobi';
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.sos2 = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'GUROBI';
solver(i).version = 'MEX';
solver(i).checkfor= {'gurobi_mex'};
solver(i).call    = 'callgurobimex';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.sos2 = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'IBM';
solver(i).subversion = '12.4';
solver(i).checkfor = {'cplexlp.m','cplexlink124'};
solver(i).call    = 'call_cplexibm_milp';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'IBM';
solver(i).subversion = '12.3';
solver(i).checkfor = {'cplexlp.m','cplexlink123'};
solver(i).call    = 'call_cplexibm_milp';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

% duals bug...(so we pick old versions
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexlp.m','cplexlink122'};
solver(i).subversion = '12.2';
i = i+1;
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexlp.m','cplexlink121'};
solver(i).subversion = '12.1';
i = i+1;
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexlp.m','cplexlink120'};
solver(i).subversion = '12.0';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'IBM';
solver(i).subversion = '12.4';
solver(i).checkfor= {'cplexqp.m','cplexlink124'};
solver(i).call    = 'call_cplexibm_miqp';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'IBM';
solver(i).subversion = '12.3';
solver(i).checkfor= {'cplexqp.m','cplexlink123'};
solver(i).call    = 'call_cplexibm_miqp';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

% duals bug...
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexqp.m','cplexlink122'};
solver(i).subversion = '12.2';
i = i+1;
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexqp.m','cplexlink121'};
solver(i).subversion = '12.1';
i = i+1;
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexqp.m','cplexlink120'};
solver(i).subversion = '12.0';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'IBM';
solver(i).subversion = '12.4';
solver(i).checkfor= {'cplexqcp.m','cplexlink124'};
solver(i).call    = 'call_cplexibm_qcmiqp';
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'IBM';
solver(i).subversion = '12.3';
solver(i).checkfor= {'cplexqcp.m','cplexlink123'};
solver(i).call    = 'call_cplexibm_qcmiqp';
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

% duals bug...
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexqcp.m','cplexlink122'};
solver(i).subversion = '12.2';
i = i+1;
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexqcp.m','cplexlink121'};
solver(i).subversion = '12.1';
i = i+1;
solver(i) = solver(i-1);
solver(i).checkfor = {'cplexqcp.m','cplexlink120'};
solver(i).subversion = '12.0';
i = i+1;

% Old interface, we really don't want to use it any longer
solver(i) = qpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'CPLEXINT';
solver(i).checkfor= {'cplexint'};
solver(i).call    = 'callcplexint';
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'CBC';
solver(i).version = '';
solver(i).checkfor= {'cbc','opti_cbc'};
solver(i).call    = 'callcbc';
solver(i).constraint.integer = 1;
solver(i).constraint.sos2 = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'GLPK';
solver(i).version = 'GLPKMEX-CC';
solver(i).checkfor= {'glpkcc'};
solver(i).call    = 'callglpkcc';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'GLPK';
solver(i).version = 'GLPKMEX';
solver(i).checkfor= {'glpkmex.m'};
solver(i).call    = 'callglpk';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'CDD';
solver(i).version = 'CDDMEX';
solver(i).checkfor= {'cddmex'};
solver(i).call    = 'callcdd';
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'NAG';
solver(i).version = 'e04mbf';
solver(i).checkfor= {'e04mbf'};
solver(i).call    = 'callnage04mbf';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'NAG';
solver(i).version = 'e04naf';
solver(i).checkfor= {'e04naf'};
solver(i).call    = 'callnage04naf';
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'CLP';
solver(i).version = 'CLPMEX-LP';
solver(i).checkfor= {'mexclp'};
solver(i).call    = 'callclp';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'SCIP';
solver(i).version = '';
solver(i).checkfor= {'scip'};
solver(i).call    = 'callscipmex';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'XPRESS';
solver(i).version = 'MEXPRESS 1.1';
solver(i).checkfor= {'xpress.m'};
solver(i).call    = 'callmexpress11';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'XPRESS';
solver(i).version = 'MEXPRESS 1.0';
solver(i).checkfor= {'mexpress.m'};
solver(i).call    = 'callmexpress';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'XPRESS';
solver(i).version = 'FICO';
solver(i).checkfor= {'xprsmip.m'};
solver(i).call    = 'call_xpressfico_milp';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'XPRESS';
solver(i).version = 'FICO';
solver(i).checkfor= {'xprsmiqp.m'};
solver(i).call    = 'call_xpressfico_miqp';
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.sos2 = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'QSOPT';
solver(i).version = 'OPTI';
solver(i).checkfor= {'opti_qsopt.m'};
solver(i).call    = 'calloptiqsopt';
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'QSOPT';
solver(i).version = 'MEXQSOPT';
solver(i).checkfor= {'qsopt.m'};
solver(i).call    = 'callqsopt';
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'LPSOLVE';
solver(i).version = 'MXLPSOLVE';
solver(i).checkfor= {'lp_solve.m'};
solver(i).call    = 'calllpsolve';
solver(i).constraint.integer = 1;
solver(i).constraint.sos2 = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'OSL';
solver(i).version = 'OSLPROG';
solver(i).checkfor= {'oslprog.m'};
solver(i).call    = 'calloslprog';
solver(i).constraint.integer = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'MOSEK';
solver(i).version = 'LP/QP';
solver(i).checkfor= {'mosekopt'};
solver(i).call    = 'callmosek';
solver(i).constraint.integer = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'MOSEK';
solver(i).version = 'SOCP';
solver(i).checkfor= {'mosekopt'};
solver(i).call    = 'callmosek';
solver(i).constraint.integer = 1;
solver(i).constraint.inequalities.secondordercone = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'MOSEK';
solver(i).version = 'GEOMETRIC';
solver(i).checkfor= {'mosekopt'};
solver(i).call    = 'callmosek';
solver(i).objective.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.equalities.elementwise.nonlinear = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'CPLEX';
solver(i).version = 'CPLEXMEX';
solver(i).checkfor= {'cplexmex'};
solver(i).call    = 'callcplexmex';
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'LINPROG';
solver(i).version = '';
solver(i).checkfor= {'linprog'};
solver(i).call    = 'calllinprog';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'BPMPD';
solver(i).version = '';
solver(i).checkfor= {'bp'};
solver(i).call    = 'callbpmpd';
i = i+1;



solver(i) = qpsolver;
solver(i).tag     = 'QUADPROG';
solver(i).version = '';
solver(i).checkfor= {'quadprog'};
solver(i).call    = 'callquadprog';
solver(i).objective.quadratic.nonconvex = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'CLP';
solver(i).version = 'CLPMEX-QP';
solver(i).checkfor= {'mexclp'};
solver(i).call    = 'callclp';
%solver(i).constraint.integer = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'CLP';
solver(i).version = 'OPTI';
solver(i).checkfor= {'clp','opti_clp'};
solver(i).call    = 'callopticlp';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'qpOASES';
solver(i).version = '';
solver(i).checkfor= {'qpOASES'};
solver(i).call    = 'callqpoases';
i = i+1;


solver(i) = qpsolver;
solver(i).tag     = 'OOQP';
solver(i).version = '';
solver(i).checkfor= {'opti_ooqp.m'};
solver(i).call    = 'calloptiooqp';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'OOQP';
solver(i).version = '';
solver(i).checkfor= {'ooqp.m'};
solver(i).call    = 'callooqp';
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'QPIP';
solver(i).version = '';
solver(i).checkfor= {'qpip'};
solver(i).call    = 'callqpip';
solver(i).objective.quadratic.nonconvex = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'QPAS';
solver(i).version = '';
solver(i).checkfor= {'qpas'};
solver(i).call    = 'callqpas';
solver(i).objective.quadratic.nonconvex = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'lindo';
solver(i).version = 'MIQP';
solver(i).checkfor= {'mxlindo'};
solver(i).call    = 'calllindo_miqp';
solver(i).constraint.integer = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SeDuMi';
solver(i).version = '1.1';
solver(i).checkfor= {'sedumi.m','ada_pcg.m','qinvsqrt','install_sedumi'};
solver(i).call    = 'callsedumi';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.inequalities.rotatedsecondordercone = 0;
solver(i).complex = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SeDuMi';
solver(i).version = '1.3';
solver(i).checkfor= {'sedumi.m','ada_pcg.m','install_sedumi'};
solver(i).call    = 'callsedumi';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.inequalities.rotatedsecondordercone = 0;
solver(i).complex = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SeDuMi';
solver(i).version = '1.05';
solver(i).checkfor= {'sedumi.m','ada_pcg.m','vecreal'};
solver(i).call    = 'callsedumi';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.inequalities.rotatedsecondordercone = 1;
solver(i).complex = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SeDuMi';
solver(i).version = '1.03';
solver(i).checkfor= {'sedumi.m','doinfac.m'};
solver(i).call    = 'callsedumi';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.inequalities.rotatedsecondordercone = 1;
solver(i).complex = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPT3';
solver(i).version = '4';
solver(i).checkfor= {'sqlp','skron','symqmr','blkbarrier'};
solver(i).call    = 'callsdpt34';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).objective.maxdet.convex = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPNAL';
solver(i).version = '0.1';
solver(i).checkfor= {'sdpnal'};
solver(i).call    = 'callsdpnal';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'LOGDETPPA';
solver(i).version = '0.1';
solver(i).checkfor= {'logdetppa'};
solver(i).call    = 'calllogdetppa';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).objective.maxdet.convex = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SparseCoLO';
solver(i).version = '0';
solver(i).checkfor= {'sparseCoLO'};
solver(i).call    = 'callsparsecolo';
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPT3';
solver(i).version = '3.1';
solver(i).checkfor= {'sqlp','skron','symqmr'};
solver(i).call    = 'callsdpt331';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPT3';
solver(i).version = '3.02';
solver(i).checkfor= {'sqlp','skron','schursysolve'};
solver(i).call    = 'callsdpt3302';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPT3';
solver(i).version = '3.0';
solver(i).checkfor= {'sqlp','mexexec'};
solver(i).call    = 'callsdpt330';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPA';
solver(i).version = 'M';
solver(i).checkfor= {'sdpam.m'};
solver(i).call    = 'callsdpa';
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'DSDP';
solver(i).version = '5';
solver(i).checkfor= {'dsdp','dvec'};
solver(i).call    = 'calldsdp5';
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'DSDP';
solver(i).version = '4';
solver(i).checkfor= {'dsdp'};
solver(i).call    = 'calldsdp';
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPLR';
solver(i).version = '';
solver(i).checkfor= {'sdplr'};
solver(i).call    = 'callsdplr';
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'CSDP';
solver(i).version = '';
solver(i).checkfor= {'csdp','readsol','writesdpa'};
solver(i).call    = 'callcsdp';
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'MAXDET';
solver(i).version = '';
solver(i).checkfor= {'maxdet.m'};
solver(i).call    = 'callmaxdet';
solver(i).objective.maxdet.convex = 1;
solver(i).constraint.equalities.linear = 0;
solver(i).dual = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'PENSDP';
solver(i).version = 'PENOPT';
solver(i).checkfor= {'pensdpm'};
solver(i).call    = 'callpensdpm';
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'PENSDP';
solver(i).version = 'TOMLAB';
solver(i).checkfor= {'pensdp'};
solver(i).call    = 'callpensdp';
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'PENBMI';
solver(i).version = 'PENOPT';
solver(i).checkfor= {'penbmim'};
solver(i).call    = 'callpenbmim';
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.equalities.linear = 0;
solver(i).constraint.inequalities.semidefinite.quadratic = 1;
solver(i).constraint.inequalities.semidefinite.polynomial = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'PENBMI';
solver(i).version = 'TOMLAB';
solver(i).checkfor= {'penbmi'};
solver(i).call    = 'callpenbmi';
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.equalities.linear = 0;
solver(i).constraint.inequalities.semidefinite.quadratic = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'LMILAB';
solver(i).version = '';
solver(i).checkfor= {'setlmis'};
solver(i).call    = 'calllmilab';
solver(i).dual = 0;
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'SDPNAL';
solver(i).version = '';
solver(i).checkfor= {'sdpnal'};
solver(i).call    = 'callsdpnal';
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'LMIRANK';
solver(i).version = '';
solver(i).checkfor= {'lmirank'};
solver(i).call    = 'calllmirank';
solver(i).dual = 0;
solver(i).constraint.inequalities.rank = 1;
solver(i).objective.linear = 0;
solver(i).constraint.equalities.linear = 0;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'VSDP';
solver(i).version = '0.1';
solver(i).checkfor= {'vsdpup','vsdpup_yalmip'};
solver(i).call    = 'callvsdp';
solver(i).constraint.equalities.linear = 0;
solver(i).constraint.inequalities.secondordercone = 0;
solver(i).interval = 1;
solver(i).usesother = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'MPT';
solver(i).version = '3';
solver(i).checkfor= {'mpt_mpqp','mpt_plcp'};
solver(i).call    = 'callmpt3';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).parametric = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'MPT';
solver(i).version = '2';
solver(i).checkfor= {'mpt_mpqp'};
solver(i).call    = 'callmpt';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).parametric = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'MPLCP';
solver(i).version = '';
solver(i).checkfor= {'mplcp.m'};
solver(i).call    = 'callmplcp';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).parametric = 1;
solver(i).constraint.binary = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'QUADPROGBB';
solver(i).version = '';
solver(i).checkfor= {'quadprogbb'};
solver(i).call    = 'callquadprogbb';
solver(i).objective.quadratic.nonconvex = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'KYPD';
solver(i).version = '';
solver(i).checkfor= {'kypd_solver'};
solver(i).call    = 'callkypd';
solver(i).usesother = 1;
i = i+1;

solver(i) = sdpsolver;
solver(i).tag     = 'STRUL';
solver(i).version = '1';
solver(i).checkfor= {'sqlp','skron','symqmr','blkbarrier','HKM_schur_LR_structure'};
solver(i).call    = 'callstrul';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).objective.maxdet.convex = 1;
solver(i).usesother = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'fmincon';
solver(i).version = 'geometric';
solver(i).checkfor= {'fmincon.m'};
solver(i).call    = 'callfmincongp';
solver(i).objective.sigmonial = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'fmincon';
solver(i).version = 'standard';
solver(i).checkfor= {'fmincon.m'};
solver(i).call    = 'callfmincon';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).dual = 1;
solver(i).evaluation = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'pennon';
solver(i).version = 'standard';
solver(i).checkfor= {'pennonm'};
solver(i).call    = 'callpennonm';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.inequalities.semidefinite.linear = 1;
solver(i).constraint.inequalities.semidefinite.quadratic = 1;
solver(i).constraint.inequalities.semidefinite.nonlinear = 1;
solver(i).dual = 1;
solver(i).evaluation = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'SNOPT';
solver(i).version = 'geometric';
solver(i).checkfor= {'snsolve.m'};
solver(i).call    = 'callsnoptgp';
solver(i).objective.sigmonial = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'SNOPT';
solver(i).version = 'standard';
solver(i).checkfor= {'snsolve.m'};
solver(i).call    = 'callsnopt';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).dual = 1;
solver(i).evaluation = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'bonmin';
solver(i).version = '';
solver(i).checkfor= {'bonmin'};
solver(i).call    = 'callbonmin';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).dual = 0;
solver(i).evaluation = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'nomad';
solver(i).version = '';
solver(i).checkfor= {'nomad'};
solver(i).call    = 'callnomad';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 0;
solver(i).constraint.equalities.quadratic = 0;
solver(i).constraint.equalities.polynomial = 0;
solver(i).constraint.equalities.sigmonial = 0;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).dual = 0;
solver(i).evaluation = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'lindo';
solver(i).version = 'NLP';
solver(i).checkfor= {'mxlindo'};
solver(i).call    = 'calllindo_nlp';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).dual = 1;
solver(i).evaluation = 1;
solver(i).constraint.integer = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'ipopt';
solver(i).version = 'standard';
solver(i).checkfor= {'ipopt'};
solver(i).call    = 'callipopt';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).dual = 0;
solver(i).evaluation = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'ipopt';
solver(i).version = 'geometric';
solver(i).checkfor= {'ipopt.m'};
solver(i).call    = 'callipoptgp';
solver(i).objective.sigmonial = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.equalities.sigmonial = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'GPPOSY';
solver(i).version = '';
solver(i).checkfor= {'gpposy'};
solver(i).call    = 'callgpposy';
solver(i).objective.sigmonial = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.equalities.elementwise.nonlinear = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'fminsearch';
solver(i).version = '';
solver(i).checkfor= {'fminsearch.m'};
solver(i).call    = 'callfminsearch';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).evaluation = 1;
solver(i).dual = 0;
i = i+1;

% solver(i) = emptysolver;
% solver(i).tag     = 'mpcvx';
% solver(i).tag     = 'mpcvx';
% solver(i).version = '';
% solver(i).checkfor= {'mpcvx'};
% solver(i).call    = 'mpcvx';
% solver(i).objective.linear = 1;
% solver(i).objective.quadratic.convex = 1;
% solver(i).objective.quadratic.nonconvex = 1;
% solver(i).constraint.inequalities.elementwise.linear = 1;
% solver(i).constraint.inequalities.secondordercone = 1;
% solver(i).constraint.inequalities.elementwise.polynomial = 1;
% solver(i).constraint.inequalities.semidefinite.linear = 1;
% solver(i).parametric = 1;
% i = i+1;

% % ***************************************
% % SOMEWHAT MORE COMPLEX DEFINITIONS OF
% % THE INTERNAL MICP SOLVER
% % ***************************************
solver(i) = emptysolver;
solver(i).tag     = 'BNB';
solver(i).version = '';
solver(i).checkfor= {'bnb'};
solver(i).call    = 'bnb';
solver(i).objective.linear = 1;
solver(i).objective.sigmonial = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.maxdet.convex = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.semidefinite.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.inequalities.rotatedsecondordercone = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).constraint.semivar = 1;
solver(i).constraint.semiintvar = 1;
solver(i).evaluation = 1;
solver(i).usesother = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'BINTPROG';
solver(i).version = '';
solver(i).checkfor= {'bintprog.m'};
solver(i).call    = 'callbintprog';
solver(i).constraint.binary = 1;
solver(i).constraint.integer = 1;
solver(i).dual = 0;
i = i+1;

% % ***************************************
% % Experimental min-max solver
% % ***************************************
% solver(i) = emptysolver;
% solver(i).tag     = 'minmax';
% solver(i).version = '';
% solver(i).checkfor= {'callminmax'};
% solver(i).call    = 'callminmax';
% solver(i).objective.linear = 1;
% solver(i).objective.sigmonial = 0;
% solver(i).objective.polynomial = 0;
% solver(i).objective.quadratic.convex = 0;
% solver(i).constraint.equalities.linear = 1;
% solver(i).constraint.inequalities.elementwise.linear = 1;
% solver(i).constraint.inequalities.elementwise.sigmonial = 0;
% solver(i).constraint.inequalities.elementwise.polynomial = 0;
% solver(i).constraint.inequalities.semidefinite.linear = 0;
% solver(i).constraint.inequalities.secondordercone = 0;
% solver(i).constraint.inequalities.rotatedsecondordercone = 0;
% solver(i).constraint.integer = 0;
% solver(i).constraint.binary = 0;
% i = i+1;

% % ***************************************
% % SOMEWHAT MORE COMPLEX DEFINITIONS OF
% % THE INTERNAL MICP SOLVER
% % ***************************************
solver(i) = emptysolver;
solver(i).tag     = 'CUTSDP';
solver(i).version = '';
solver(i).checkfor= {'cutsdp'};
solver(i).call    = 'cutsdp';
solver(i).objective.linear = 1;
solver(i).objective.sigmonial = 0;
solver(i).objective.polynomial = 0;
solver(i).objective.quadratic.convex = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.semidefinite.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.binary = 1;
solver(i).dual = 1;
solver(i).complex = 0;
solver(i).usesother = 1;
i = i+1;

% ***************************************
% SOMEWHAT MORE COMPLEX DEFINITIONS OF
% THE INTERNAL GLOBAL BMI SOLVER
% ***************************************
solver(i) = emptysolver;
solver(i).tag     = 'BMIBNB';
solver(i).version = '';
solver(i).checkfor= {'bmibnb'};
solver(i).call    = 'bmibnb';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).objective.sigmonial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).constraint.inequalities.elementwise.sigmonial = 1;
solver(i).constraint.inequalities.semidefinite.linear = 1;
solver(i).constraint.inequalities.semidefinite.quadratic = 1;
solver(i).constraint.inequalities.semidefinite.polynomial = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.inequalities.rotatedsecondordercone = 1;
solver(i).constraint.inequalities.rank = 0;
solver(i).constraint.binary  = 1;
solver(i).constraint.integer = 1;
solver(i).constraint.semivar = 0;
solver(i).evaluation = 1;
solver(i).usesother = 1;
i = i+1;

solver(i) = qpsolver;
solver(i).tag     = 'kktqp';
solver(i).version = '';
solver(i).checkfor= {'kktqp'};
solver(i).call    = 'kktqp';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.equalities.linear = 0;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).usesother = 1;
i = i+1;

solver(i) = emptysolver;
solver(i).tag     = 'sparsepop';
solver(i).version = '';
solver(i).checkfor= {'sparsePOP.m'};
solver(i).call    = 'callsparsepop';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).objective.polynomial = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.equalities.quadratic = 1;
solver(i).constraint.equalities.polynomial = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.elementwise.polynomial = 1;
solver(i).usesother = 1;
i = i+1;


solver(i) = emptysolver;
solver(i).tag     = 'none';
solver(i).version = '';
solver(i).checkfor= {'callnone.m'};
solver(i).call    = 'callnone';
solver(i).objective.linear = 1;
solver(i).objective.quadratic.convex = 1;
solver(i).objective.quadratic.nonconvex = 1;
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.elementwise.linear = 1;
solver(i).constraint.inequalities.elementwise.quadratic.convex = 1;
solver(i).constraint.inequalities.elementwise.quadratic.nonconvex = 1;
solver(i).constraint.inequalities.semidefinite.linear = 1;
solver(i).constraint.inequalities.semidefinite.quadratic = 1;
solver(i).constraint.inequalities.semidefinite.polynomial = 1;
solver(i).evaluation = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'powersolver';
solver(i).version = '';
solver(i).checkfor= {'powersolver.m'};
solver(i).call    = 'callpowersolver';
solver(i).constraint.equalities.linear = 1;
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.inequalities.rotatedsecondordercone = 1;
solver(i).constraint.inequalities.powercone = 1;
solver(i).complex = 1;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'LSQNONNEG';
solver(i).version = '';
solver(i).checkfor= {'lsqnonneg.m'};
solver(i).call    = 'calllsqnonneg';
solver(i).constraint.inequalities.secondordercone = 1;
solver(i).constraint.equalities.linear = 0;
solver(i).constraint.inequalities.linear = 0;
i = i+1;

solver(i) = lpsolver;
solver(i).tag     = 'LSQLIN';
solver(i).version = '';
solver(i).checkfor= {'lsqlin.m'};
solver(i).call    = 'calllsqlin';
solver(i).constraint.inequalities.secondordercone = 1;
i = i+1;