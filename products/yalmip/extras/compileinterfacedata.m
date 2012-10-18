function [interfacedata,recoverdata,solver,diagnostic,F,Fremoved] = compileinterfacedata(F,aux_obsolete,logdetStruct,h,options,findallsolvers,parametric)

persistent CACHED_SOLVERS
persistent EXISTTIME
persistent NCHECKS

%% Initilize default empty outputs
diagnostic = [];
interfacedata = [];
recoverdata = [];
solver = [];
Fremoved  = [];
        
%% Did we make the call from SOLVEMP
if nargin<7
    parametric = 0;
end

%% Clean objective to default empty
if isa(h,'double')
    h = [];
end

% *************************************************************************
%% Exit if LOGDET objective is nonlinear
% *************************************************************************
if ~isempty(logdetStruct)
    for i = 1:length(logdetStruct.P)
        if ~is(logdetStruct.P{i},'linear')
            diagnostic.solvertime = 0;
            diagnostic.problem = -2;
            diagnostic.info = yalmiperror(diagnostic.problem,'');
            return
        end
    end
end

% *************************************************************************
%% EXTRACT LOW-RANK DESCRIPTION
% *************************************************************************
lowrankdetails = getlrdata(F);
if ~isempty(lowrankdetails)
    F = F(~is(F,'lowrank'));
end

% *************************************************************************
%% PERTURB STRICT INEQULAITIES
% *************************************************************************
if isa(options.shift,'sdpvar') | (options.shift~=0)
    F = shift(F,options.shift);
end

% *************************************************************************
%% ADD RADIUS CONSTRAINT
% *************************************************************************
if isa(options.radius,'sdpvar') | ~isinf(options.radius)
    x = recover(unique(union(depends(h),depends(F))));
    if length(x)>1
        F = F + set(cone(x,options.radius));
    else
        F = F + set(-options.radius <= x <= options.radius);
    end
end

% *************************************************************************
%% CONVERT LOGIC CONSTRAINTS
% *************************************************************************
[F,changed] = convertlogics(F);
if changed
    options.saveduals = 0; % Don't calculate duals since we changed the problem
end

% *************************************************************************
%% Take care of the nonlinear operators by converting expressions such as
% t = max(x,y) to standard conic models and mixed integer models
% This part also adds parts from logical expressions and mpower terms
% *************************************************************************
if options.expand
    % Experimental hack due to support for the PWQ function used for
    % quadratic dynamic programming with MPT.
    % FIX: Clean up and generalize
    try
        h1v = depends(h);
        h2v = getvariables(h);
        if ~isequal(h1v,h2v)            
            variables = uniquestripped([h1v h2v]);
        else
            variables = h1v;
        end
        extendedvariables = yalmip('extvariables');
        index_in_extended = find(ismembc(variables,extendedvariables));
        if ~isempty(index_in_extended)
            extstruct = yalmip('extstruct',variables(index_in_extended));
            if isequal(extstruct.fcn ,'pwq_yalmip')
                [properties,Fz,arguments]=model(extstruct.var,'integer',options,extstruct);
                if iscell(properties)
                    properties = properties{1};
                end
                gain = getbasematrix(h,getvariables(extstruct.var));
                h = replace(h,extstruct.var,0);
                h = h + gain*properties.replacer;
                F = F + Fz;
            end
        end
    catch
    end
    [F,failure,cause,operators] = expandmodel(F,h,options);
    if failure % Convexity propgation failed
        interfacedata = [];
        recoverdata = [];
        solver = '';
        diagnostic.solvertime = 0;
        diagnostic.problem = 14;
        diagnostic.info = yalmiperror(14,cause);
        return
    end
    evalVariables = unique(determineEvaluationBased(operators));%yalmip('evalVariables');
    %evalVariables = yalmip('evalVariables');    
    if isempty(evalVariables)
        evaluation_based = 0;
    else
        evaluation_based = ~isempty(intersect([depends(h) depends(F)],evalVariables));
    end
else
    evalVariables = [];
    evaluation_based = 0;    
end

% *************************************************************************
%% LOOK FOR AVAILABLE SOLVERS
% Finding solvers can be very slow on some systems. To alleviate this
% problem, YALMIP can cache the list of available solvers.
% *************************************************************************
if (options.cachesolvers==0) | isempty(CACHED_SOLVERS)
    getsolvertime = clock;
    solvers = getavailablesolvers(findallsolvers,options);
    getsolvertime = etime(clock,getsolvertime);
    % CODE TO INFORM USERS ABOUT SLOW NETWORKS!
    if isempty(EXISTTIME)
        EXISTTIME = getsolvertime;
        NCHECKS = 1;
    else
        EXISTTIME = [EXISTTIME getsolvertime];
        NCHECKS = NCHECKS + 1;
    end
    if (options.cachesolvers==0)
        if ((NCHECKS >= 3 & (sum(EXISTTIME)/NCHECKS > 1)) | EXISTTIME(end)>2)
            if warningon
                info = 'Warning: YALMIP has detected that your drive or network is unusually slow.\nThis causes a severe delay in SOLVESDP when I try to find available solvers.\nTo avoid this, use the options CACHESOLVERS in SDPSETTINGS.\nSee the FAQ for more information.\n';
                fprintf(info);
            end
        end
    end
    if length(EXISTTIME) > 5
        EXISTTIME = EXISTTIME(end-4:end);
        NCHECKS = 5;
    end
    CACHED_SOLVERS = solvers;
else
    solvers = CACHED_SOLVERS;
end

% *************************************************************************
%% NO SOLVER AVAILABLE
% *************************************************************************
if isempty(solvers)
    diagnostic.solvertime = 0;
    if isempty(options.solver)
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
    else
        diagnostic.info = yalmiperror(-3,'YALMIP');
        diagnostic.problem = -3;
    end
    if warningon & options.warning & isempty(findstr(diagnostic.info,'No problems detected'))
        disp(['Warning: ' diagnostic.info]);
    end
    return
end

% *************************************************************************
%% CONVERT CONVEX QUADRATIC CONSTRAINTS
% We do not convert quadratic constraints to SOCPs if we have have
% sigmonial terms (thus indicating a GP problem), if we have relaxed
% nonlinear expressions, or if we have specified a nonlinear solver.
% Why do we convert them already here? Don't remember, should be cleaned up
% *************************************************************************
[monomtable,variabletype] = yalmip('monomtable');
F_vars = getvariables(F);
do_not_convert = any(variabletype(F_vars)==4);
%do_not_convert = do_not_convert | ~solverCapable(solvers,options.solver,'constraint.inequalities.secondordercone');
do_not_convert = do_not_convert | strcmpi(options.solver,'bmibnb');
do_not_convert = do_not_convert | strcmpi(options.solver,'snopt');
do_not_convert = do_not_convert | strcmpi(options.solver,'snopt-geometric'); 
do_not_convert = do_not_convert | strcmpi(options.solver,'snopt-standard');
do_not_convert = do_not_convert | strcmpi(options.solver,'ipopt');
do_not_convert = do_not_convert | strcmpi(options.solver,'bonmin');
do_not_convert = do_not_convert | strcmpi(options.solver,'nomad');
do_not_convert = do_not_convert | strcmpi(options.solver,'ipopt-geometric');
do_not_convert = do_not_convert | strcmpi(options.solver,'ipopt-standard');
do_not_convert = do_not_convert | strcmpi(options.solver,'pennon');
do_not_convert = do_not_convert | strcmpi(options.solver,'pennon-geometric');
do_not_convert = do_not_convert | strcmpi(options.solver,'pennon-standard');
do_not_convert = do_not_convert | strcmpi(options.solver,'pennlp');
do_not_convert = do_not_convert | strcmpi(options.solver,'penbmi');
do_not_convert = do_not_convert | strcmpi(options.solver,'fmincon');
do_not_convert = do_not_convert | strcmpi(options.solver,'lindo');
do_not_convert = do_not_convert | strcmpi(options.solver,'sqplab');
do_not_convert = do_not_convert | strcmpi(options.solver,'fmincon-geometric');
do_not_convert = do_not_convert | strcmpi(options.solver,'fmincon-standard');
do_not_convert = do_not_convert | strcmpi(options.solver,'bmibnb');
do_not_convert = do_not_convert | strcmpi(options.solver,'moment');
do_not_convert = do_not_convert | strcmpi(options.solver,'sparsepop');
do_not_convert = do_not_convert | (options.convertconvexquad == 0);
do_not_convert = do_not_convert | (options.relax == 1);
if ~do_not_convert & any(variabletype(F_vars))
    [F,socp_changed,infeasible] = convertquadratics(F);
    if infeasible
        diagnostic.solvertime = 0;
        diagnostic.problem = 1;
        diagnostic.info = yalmiperror(diagnostic.problem,'YALMIP');
        return        
    end
    if socp_changed % changed holds the number of QC -> SOCC conversions
        options.saveduals = 0; % We cannot calculate duals since we changed the problem
        F_vars = []; % We have changed model so we cannot use this in categorizemodel
    end
else
    socp_changed = 0;
end

% CHEAT FOR QC
if socp_changed>0 & length(find(is(F,'socc')))==socp_changed
    socp_are_really_qc = 1;
else
    socp_are_really_qc = 0;
end

% *************************************************************************
%% WHAT KIND OF PROBLEM DO WE HAVE NOW?
% *************************************************************************
[ProblemClass,integer_variables,binary_variables,parametric_variables,uncertain_variables,semicont_variables,quad_info] = categorizeproblem(F,logdetStruct,h,options.relax,parametric,evaluation_based,F_vars);

% *************************************************************************
%% SELECT SUITABLE SOLVER
% *************************************************************************
[solver,problem] = selectsolver(options,ProblemClass,solvers,socp_are_really_qc);
if isempty(solver)
    diagnostic.solvertime = 0;
    if problem == -4
        diagnostic.info = yalmiperror(problem,options.solver);
    else
        diagnostic.info = yalmiperror(problem,'YALMIP');
    end
    diagnostic.problem = problem;

    if warningon & options.warning
        disp(['Warning: ' diagnostic.info]);
    end
    return
end
if length(solver.version)>0
    solver.tag = [solver.tag '-' solver.version];
end

if ProblemClass.constraint.complementarity.linear | ProblemClass.constraint.complementarity.nonlinear
    if ~(solver.constraint.complementarity.linear | solver.constraint.complementarity.nonlinear)
               
        % Extract the terms in the complementarity constraints x^Ty==0,
        % x>=0, y>=0, since these involves bounds that should be appended
        % to the list of constraints from which we do bound propagation
        Fc = F(find(is(F,'complementarity')));      
        Ftemp = F;
        for i = 1:length(Fc)
            [Cx,Cy] = getComplementarityTerms(Fc(i));
            Ftemp = [Ftemp, Cx>=0, Cy >=0];
        end
        % FIXME: SYNC with expandmodel       
        setupBounds(Ftemp,options,extendedvariables);
                        
        [F] = modelComplementarityConstraints(F,solver,ProblemClass);  
        % FIXME Reclassify should be possible to do manually!
        [ProblemClass,integer_variables,binary_variables,parametric_variables,uncertain_variables,semicont_variables,quad_info] = categorizeproblem(F,logdetStruct,h,options.relax,parametric,evaluation_based,F_vars);
    end
end

% *************************************************************************
%% DID WE SELECT THE INTERNAL BNB SOLVER
% IN THAT CASE, SELECT LOCAL SOLVER
% (UNLESS ALREADY SPECIFIED IN OPTIONS.BNB)
% *************************************************************************
localsolver.qc = 0;
localsolver = solver;
if strcmpi(solver.tag,'bnb')
    temp_options = options;
    temp_options.solver = options.bnb.solver;
    tempProblemClass = ProblemClass;
    tempProblemClass.constraint.binary  = 0;
    tempProblemClass.constraint.integer = 0;
    tempProblemClass.constraint.semicont = 0;
    localsolver = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    if isempty(localsolver) | strcmpi(localsolver.tag,'bnb')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.lower = localsolver;
end

if findstr(lower(solver.tag),'sparsecolo')
    temp_options = options;
    temp_options.solver = options.sparsecolo.SDPsolver;
    tempProblemClass = ProblemClass;   
    localsolver = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    if isempty(localsolver) | strcmpi(localsolver.tag,'sparsecolo')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.sdpsolver = localsolver;
end

% *************************************************************************
%% DID WE SELECT THE MPCVX SOLVER
% IN THAT CASE, SELECT SOLVER TO SOLVE BOUND COMPUTATIONS
% *************************************************************************
localsolver.qc = 0;
localsolver = solver;
if strcmpi(solver.tag,'mpcvx')
    temp_options = options;
    temp_options.solver = options.mpcvx.solver;
    tempProblemClass = ProblemClass;    
    tempProblemClass.objective.quadratic.convex = tempProblemClass.objective.quadratic.convex | tempProblemClass.objective.quadratic.nonconvex;
    tempProblemClass.objective.quadratic.nonconvex = 0;
    tempProblemClass.parametric = 0;
    localsolver = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    if isempty(localsolver) | strcmpi(localsolver.tag,'bnb') | strcmpi(localsolver.tag,'kktqp')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.lower = localsolver;
end

% *************************************************************************
%% DID WE SELECT THE INTERNAL EXPERIMENTAL KKT SOLVER
% IN THAT CASE, SELECT SOLVER TO SOLVE THE MILP PROBLEM
% *************************************************************************
localsolver.qc = 0;
localsolver = solver;
if strcmpi(solver.tag,'kktqp')
    temp_options = options;
    temp_options.solver = '';
    tempProblemClass = ProblemClass;
    tempProblemClass.constraint.binary = 1;
    tempProblemClass.objective.quadratic.convex = 0;
    tempProblemClass.objective.quadratic.nonconvex = 0;
    localsolver = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    if isempty(localsolver) | strcmpi(localsolver.tag,'bnb') | strcmpi(localsolver.tag,'kktqp')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.lower = localsolver;
end

% *************************************************************************
%% DID WE SELECT THE LMIRANK?
% FIND SDP SOLVER FOR INITIAL SOLUTION
% *************************************************************************
if strcmpi(solver.tag,'lmirank')
    temp_options = options;
    temp_options.solver = options.lmirank.solver;
    tempProblemClass = ProblemClass;
    tempProblemClass.constraint.inequalities.rank = 0;
    tempProblemClass.constraint.inequalities.semidefinite.linear = 1;
    tempProblemClass.objective.linear = 1;
    initialsolver = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    if isempty(initialsolver) | strcmpi(initialsolver.tag,'lmirank')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.initialsolver = initialsolver;
end

% *************************************************************************
%% DID WE SELECT THE VSDP SOLVER? Define a solver for VSDP to use
% *************************************************************************
if findstr(solver.tag,'VSDP')
    temp_options = options;
    temp_options.solver = options.vsdp.solver;
    tempProblemClass = ProblemClass;
    tempProblemClass.interval = 0;
    tempProblemClass.constraint.inequalities.semidefinite.linear =  tempProblemClass.constraint.inequalities.semidefinite.linear | tempProblemClass.objective.quadratic.convex;
    tempProblemClass.constraint.inequalities.semidefinite.linear =  tempProblemClass.constraint.inequalities.semidefinite.linear | tempProblemClass.constraint.inequalities.secondordercone;
    tempProblemClass.constraint.inequalities.secondordercone = 0;
    tempProblemClass.objective.quadratic.convex = 0;
    initialsolver = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    if isempty(initialsolver) | strcmpi(initialsolver.tag,'vsdp')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.solver = initialsolver;
end

% *************************************************************************
%% DID WE SELECT THE INTERNAL BMIBNB SOLVER? SELECT UPPER/LOWER SOLVERs
% (UNLESS ALREADY SPECIFIED IN OPTIONS)
% *************************************************************************
if strcmpi(solver.tag,'bmibnb')

    % Relax problem for lower solver
    tempProblemClass = ProblemClass;

    sdp = tempProblemClass.constraint.inequalities.semidefinite;
    tempProblemClass.constraint.inequalities.semidefinite.linear = sdp.linear | sdp.quadratic | sdp.polynomial;
    tempProblemClass.constraint.inequalities.semidefinite.quadratic = 0;
    tempProblemClass.constraint.inequalities.semidefinite.polynomial = 0;

    lp = tempProblemClass.constraint.inequalities.elementwise;
    tempProblemClass.constraint.inequalities.elementwise.linear = lp.linear | lp.quadratic.convex | lp.quadratic.nonconvex | sdp.polynomial;
    tempProblemClass.constraint.inequalities.elementwise.quadratic.convex = 0;
    tempProblemClass.constraint.inequalities.elementwise.quadratic.nonconvex = 0;
    tempProblemClass.constraint.inequalities.elementwise.polynomial = 0;
    tempProblemClass.constraint.inequalities.elementwise.sigmonial = 0;

    equ = tempProblemClass.constraint.equalities;
    tempProblemClass.constraint.equalities.linear = equ.linear | equ.quadratic | equ.polynomial;
    tempProblemClass.constraint.equalities.quadratic = 0;
    tempProblemClass.constraint.equalities.polynomial = 0;
    tempProblemClass.constraint.equalities.sigmonial = 0;

    tempProblemClass.objective.quadratic.nonconvex = 0;
    tempProblemClass.objective.polynomial = 0;
    tempProblemClass.objective.sigmonial = 0;

    tempProblemClass.constraint.inequalities.rank  = 0;
    tempProblemClass.evaluation  = 0;

    temp_options = options;
    temp_options.solver = options.bmibnb.lowersolver;

    % If the problem actually is quadratic, try to get a convex problem
    % this will typically allow us to solver better lower bounding problems
    % (we don't have to linearize the cost)
    [lowersolver,problem] = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    if isempty(lowersolver)| strcmpi(lowersolver.tag,'bmibnb') | strcmpi(lowersolver.tag,'bnb')
        % No, probably non-convex cost. Pick a linear solver instead and go
        % for lower bound based on a complete "linearization"
        tempProblemClass.objective.quadratic.convex = 0;
        [lowersolver,problem] = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
    end

    if isempty(lowersolver)| strcmpi(lowersolver.tag,'bmibnb') | strcmpi(lowersolver.tag,'bnb')
        tempbinary = tempProblemClass.constraint.binary;
        tempinteger = tempProblemClass.constraint.integer;
        tempsemicont = tempProblemClass.constraint.semicont;
        tempProblemClass.constraint.binary = 0;
        tempProblemClass.constraint.integer = 0;
        tempProblemClass.constraint.semicont = 0;
        [lowersolver,problem] = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
        tempProblemClass.constraint.binary = tempbinary;
        tempProblemClass.constraint.integer = tempinteger;
         tempProblemClass.constraint.semicont = tempsemicont;
    end

    if isempty(lowersolver) | strcmpi(lowersolver.tag,'bmibnb') | strcmpi(lowersolver.tag,'bnb')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.lowercall = lowersolver.call;
    solver.lowersolver = lowersolver;

    temp_options = options;
    temp_options.solver = options.bmibnb.uppersolver;
    temp_ProblemClass = ProblemClass;
    temp_ProblemClass.constraint.binary = 0;
    temp_ProblemClass.constraint.integer = 0;
    temp_ProblemClass.constraint.semicont = 0;
    [uppersolver,problem] = selectsolver(temp_options,temp_ProblemClass,solvers,socp_are_really_qc);
    if ~isempty(uppersolver) & strcmpi(uppersolver.tag,'bnb')
        temp_options.solver = 'none';
        [uppersolver,problem] = selectsolver(temp_options,temp_ProblemClass,solvers,socp_are_really_qc);
    end
    if isempty(uppersolver) | strcmpi(uppersolver.tag,'bmibnb')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    if strcmpi(uppersolver.version,'geometric') &  strcmpi(uppersolver.tag,'fmincon')
        uppersolver.version = 'standard';
        uppersolver.call = 'callfmincon';
    end
    if strcmpi(uppersolver.version,'geometric') &  strcmpi(uppersolver.tag,'ipopt')
        uppersolver.version = 'standard';
        uppersolver.call = 'callipoptmex';
    end    
    if strcmpi(uppersolver.version,'geometric') &  strcmpi(uppersolver.tag,'snopt')
        uppersolver.version = 'standard';
        uppersolver.call = 'callsnopt';
    end     
    if strcmpi(uppersolver.version,'geometric') &  strcmpi(uppersolver.tag,'pennon')
        uppersolver.version = 'standard';
        uppersolver.call = 'callpennonm';
    end     
    
    solver.uppercall = uppersolver.call;
    solver.uppersolver = uppersolver;

    temp_options = options;
    temp_options.solver = options.bmibnb.lpsolver;
    tempProblemClass.constraint.inequalities.semidefinite.linear = 0;
    tempProblemClass.constraint.inequalities.semidefinite.quadratic = 0;
    tempProblemClass.constraint.inequalities.semidefinite.polynomial = 0;
    tempProblemClass.constraint.inequalities.secondordercone = 0;
    tempProblemClass.objective.quadratic.convex = 0;
    tempProblemClass.objective.quadratic.nonconvex = 0;
    tempProblemClass.objective.quadratic.nonconvex = 0;
    tempProblemClass.objective.polynomial = 0;
    tempProblemClass.objective.sigmonial = 0;

    [lpsolver,problem] = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);

    if isempty(lowersolver)| strcmpi(lowersolver.tag,'bmibnb')
        tempbinary = tempProblemClass.constraint.binary;
        tempProblemClass.constraint.binary = 0;
        [lpsolver,problem] = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);
        tempProblemClass.constraint.binary = tempbinary;
    end

    if isempty(lpsolver) | strcmpi(lpsolver.tag,'bmibnb')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.lpsolver = lpsolver;
    solver.lpcall = lpsolver.call;
end

% *************************************************************************
%% DID WE SELECT THE INTERNAL SDPMILP SOLVER
% This solver solves MISDP problems by solving MILP problems and adding SDP
% cuts based on the infasible MILP solution.
% *************************************************************************
if strcmpi(solver.tag,'cutsdp')

    % Relax problem for lower solver
    tempProblemClass = ProblemClass;
    tempProblemClass.constraint.inequalities.elementwise.linear =  tempProblemClass.constraint.inequalities.elementwise.linear |     tempProblemClass.constraint.inequalities.semidefinite.linear | tempProblemClass.constraint.inequalities.secondordercone;
    tempProblemClass.constraint.inequalities.semidefinite.linear = 0;
    tempProblemClass.constraint.inequalities.secondordercone = 0;
    tempProblemClass.objective.quadratic.convex = 0;
    
    temp_options = options;
    temp_options.solver = options.cutsdp.solver;

    [lowersolver,problem] = selectsolver(temp_options,tempProblemClass,solvers,socp_are_really_qc);

    if isempty(lowersolver) | strcmpi(lowersolver.tag,'cutsdp') |strcmpi(lowersolver.tag,'bmibnb') | strcmpi(lowersolver.tag,'bnb')
        diagnostic.solvertime = 0;
        diagnostic.info = yalmiperror(-2,'YALMIP');
        diagnostic.problem = -2;
        return
    end
    solver.lower = lowersolver;
end

showprogress(['Solver chosen : ' solver.tag],options.showprogress);
% 
% % *************************************************************************
% %% CONVERT SOS2 to binary constraints
% % *************************************************************************
% if  ProblemClass.constraint.sos2 & ~solver.constraint.sos2
%     [F,binary_variables] = convertsos2(F,binary_variables);
% end

% *************************************************************************
%% CONVERT MAXDET TO SDP USING GEOMEAN?
% *************************************************************************
% MAXDET using geometric mean construction
if ~isempty(logdetStruct)
    if isequal(solver.tag,'BNB')
        can_solve_maxdet = solver.lower.objective.maxdet.convex;
    else
        can_solve_maxdet = solver.objective.maxdet.convex;
    end
    if ~can_solve_maxdet
        t = sdpvar(1,1);
        Ptemp = [];
        for i = 1:length(logdetStruct.P)
            Ptemp = blkdiag(Ptemp,logdetStruct.P{i});
        end
        P = {Ptemp};
        if length(F)>0
            if isequal(P,sdpvar(F(end)))
                F = F(1:end-1);
            end
        end
        F = F + detset(t,P{1});
        if isempty(h)
            h = -t;
        else
            h = h-t;
            % Warn about logdet -> det^1/m
            if options.verbose>0 & options.warning>0
                disp(' ')
                disp('Objective c''x-logdet(P) has been changed to c''x-det(P)^(1/(2^ceil(log2(length(X))))).')
                disp('See the MAXDET section in the manual for details.')
                disp(' ')
            end
        end
        P = [];
    end
end

% % *************************************************************************
% %% Change SOS2 to binary model
% % *************************************************************************
% old_binary_variables = binary_variables;
% if ~isempty(binary_variables) & (solver.constraint.binary==0)
%     x_bin = recover(binary_variables(ismember(binary_variables,unique([getvariables(h) getvariables(F)]))));
%     F = F + set(x_bin<1)+set(x_bin>0);
%     integer_variables = union(binary_variables,integer_variables);
%     binary_variables = [];
% end
% if  ProblemClass.constraint.semicont & ~solver.constraint.semivar
%      [F,binary_variables] = convertsos2(F,binary_variables);
% end

% *************************************************************************
%% Change binary variables to integer?
% *************************************************************************
old_binary_variables = binary_variables;
if ~isempty(binary_variables) & (solver.constraint.binary==0)
    x_bin = recover(binary_variables(ismember(binary_variables,unique([getvariables(h) getvariables(F)]))));
    F = F + set(x_bin<1)+set(x_bin>0);
    integer_variables = union(binary_variables,integer_variables);
    binary_variables = [];
end

% *************************************************************************
%% Model quadratics using SOCP?
% Should not be done when using PENNLP or BMIBNB or FMINCON, or if we have relaxed the
% monmial terms or...Ouch, need to clean up all special cases, this sucks.
% *************************************************************************
convertQuadraticObjective = ~strcmpi(solver.tag,'pennlp-standard');
convertQuadraticObjective = convertQuadraticObjective & ~strcmpi(solver.tag,'bmibnb');
relaxed = (options.relax==1 | options.relax==3);
%| (~isempty(quad_info) & strcmp(solver.tag,'bnb') & localsolver.objective.quadratic.convex==0)
convertQuadraticObjective = convertQuadraticObjective & (~relaxed & (~isempty(quad_info) & solver.objective.quadratic.convex==0));
%convertQuadraticObjective = convertQuadraticObjective; % | strcmpi(solver.tag,'cutsdp');
if any(strcmpi(solver.tag,{'bnb','cutsdp'})) & ~isempty(quad_info)
    if solver.lower.objective.quadratic.convex==0
        convertQuadraticObjective = 1;
    end
end

if convertQuadraticObjective
    t = sdpvar(1,1);
    x = quad_info.x;
    R = quad_info.R;
    if ~isempty(R)
        c = quad_info.c;
        f = quad_info.f;
        F = F + lmi(cone([2*R*x;1-(t-c'*x-f)],1+t-c'*x-f));
        h = t;
    end
    quad_info = [];
end
if solver.constraint.inequalities.rotatedsecondordercone == 0
    [F,changed] = convertlorentz(F);
    if changed
        options.saveduals = 0; % We cannot calculate duals since we change the problem
    end
end
% Whoa, horrible tests to find out when to convert SOCP to SDP
% This should not be done if :
%   1. Problem is actually a QCQP and solver supports this
%   2. Problem is integer, local solver supports SOCC
%   3. Solver supports SOCC
if ~((solver.constraint.inequalities.elementwise.quadratic.convex == 1) & socp_are_really_qc)
    if ~(strcmp(solver.tag,'bnb') & socp_are_really_qc & localsolver.constraint.inequalities.elementwise.quadratic.convex==1 )
        if ((solver.constraint.inequalities.secondordercone == 0) | (strcmpi(solver.tag,'bnb') & localsolver.constraint.inequalities.secondordercone==0))
            if solver.constraint.inequalities.semidefinite.linear
                [F,changed] = convertsocp(F);
            else
                [F,changed] = convertsocp2NONLINEAR(F);
            end
            if changed
                options.saveduals = 0; % We cannot calculate duals since we change the problem
            end
        end
    end
end

% *************************************************************************
%% Add logaritmic barrier cost/constraint for MAXDET and SDPT3-4. Note we
% have to add it her in order for a complex valued matrix to be converted.
% *************************************************************************
if ~isempty(logdetStruct) & solver.objective.maxdet.convex==1 & solver.constraint.inequalities.semidefinite.linear
    for i = 1:length(logdetStruct.P)
        F = F + set(logdetStruct.P{i} > 0);
        if ~isreal(logdetStruct.P{i})
            logdetStruct.gain(i) = logdetStruct.gain(i)/2;
            ProblemClass.complex = 1;
        end
    end
end

if ((solver.complex==0) & ProblemClass.complex) | ((strcmp(solver.tag,'bnb') & localsolver.complex==0) & ProblemClass.complex)
    showprogress('Converting to real constraints',options.showprogress)
    F = imag2reallmi(F);
    if ~isempty(logdetStruct) 
        for i = 1:length(logdetStruct.P)
            P{i} = sdpvar(F(end-length(logdetStruct.P)+i));
        end
    end
    options.saveduals = 0; % We cannot calculate duals since we change the problem
%else
%    complex_logdet = zeros(length(P),1);
end

% *************************************************************************
%% CREATE OBJECTIVE FUNCTION c'*x+x'*Q*x
% *************************************************************************
showprogress('Processing objective h(x)',options.showprogress);
try
    % If these solvers, the Q term is placed in c, hence quadratic terms
    % are treated as any other nonlinear term
    geometric = strcmpi(solver.tag,'fmincon-geometric')| strcmpi(solver.tag,'gpposy') | strcmpi(solver.tag,'mosek-geometric') | strcmpi(solver.tag,'snopt-geometric') | strcmpi(solver.tag,'ipopt-geometric') | strcmpi(solver.tag,'pennon-geometric');
    if strcmpi(solver.tag,'bnb')
        lowersolver = lower([solver.lower.tag '-' solver.lower.version]);
        if strcmpi(lowersolver,'fmincon-geometric')| strcmpi(lowersolver,'gpposy-') |  strcmpi(lowersolver,'mosek-geometric')
            geometric = 1;
        end
    end
    if strcmpi(solver.tag,'bmibnb') | strcmpi(solver.tag,'sparsepop') | strcmpi(solver.tag,'pennlp-standard') | geometric | evaluation_based ;
        tempoptions = options;
        tempoptions.relax = 1;
        [c,Q,f]=createobjective(h,logdetStruct,tempoptions,quad_info);
    else
        [c,Q,f]=createobjective(h,logdetStruct,options,quad_info);
    end
catch
    error(lasterr)
end

% *************************************************************************
%% Convert {F(x),G(x)} to a numerical SeDuMi-like format
% *************************************************************************
showprogress('Processing F(x)',options.showprogress);
F = lmi(F);
[F_struc,K,KCut,schur_funs,schur_data,schur_variables] = lmi2sedumistruct(F);
% We add a field to remember the dimension of the logarithmic cost.
% Actually, the actually value is not interesting, we know that the
% logarithmic cost corresponds to the last LP or SDP constraint anyway
if isempty(logdetStruct)
    K.m = 0;
else
    for i = 1:length(logdetStruct.P)
        K.m(i) = length(logdetStruct.P{i});        
    end
    K.maxdetgain = logdetStruct.gain;
end

if ~isempty(schur_funs)
    if length(schur_funs)<length(K.s)
        schur_funs{length(K.s)}=[];
        schur_data{length(K.s)}=[];
        schur_variables{length(K.s)}=[];
    end
end
K.schur_funs = schur_funs;
K.schur_data = schur_data;
K.schur_variables = schur_variables;

% *************************************************************************
%% SOME HORRIBLE CODE TO DETERMINE USED VARIABLES
% *************************************************************************
% Which sdpvar variables are actually in the problem
used_variables_LMI = find(any(F_struc(:,2:end),1));
used_variables_obj = find(any(c',1) | any(Q));
if isequal(used_variables_LMI,used_variables_obj)
    used_variables = used_variables_LMI;
else
    used_variables = uniquestripped([used_variables_LMI used_variables_obj]);
end
if ~isempty(K.sos)
    for i = 1:length(K.sos.type)
        used_variables = uniquestripped([used_variables K.sos.variables{i}(:)']);
    end
end
% The problem is that linear terms might be missing in problems with only
% nonlinear expressions
[monomtable,variabletype] = yalmip('monomtable');
if (options.relax==1)|(options.relax==3)
    monomtable = [];
    nonlinearvariables = [];
    linearvariables = used_variables;
else
    nonlinearvariables = find(variabletype);
    linearvariables = used_variables(find(variabletype(used_variables)==0));
end
needednonlinear = nonlinearvariables(ismembc(nonlinearvariables,used_variables));
linearinnonlinear = find(sum(abs(monomtable(needednonlinear,:)),1));
missinglinear = setdiff(linearinnonlinear(:),linearvariables);
used_variables = uniquestripped([used_variables(:);missinglinear(:)]);

% *************************************************************************
%% So are we done now? No... What about variables hiding inside so called
% evaluation variables. We detect these, and at the same time set up the
% structures needed to support general functions such as exp, log, etc
% NOTE : This is experimental code
% FIX  : Clean up...
% *************************************************************************
[evalMap,evalVariables,used_variables,nonlinearvariables,linearvariables] = detectHiddenNonlinear(used_variables,options,nonlinearvariables,linearvariables,evalVariables);

% Attach information on the evaluation based variables that was generated
% when the model was expanded
if ~isempty(evalMap)
    for i = 1:length(operators)
        index = find(operators{i}.properties.models(1) == used_variables(evalVariables));
        if ~isempty(index)
            evalMap{index}.properties = operators{i}.properties;
        end
    end
    for i = 1:length(evalMap)
        for j = 1:length(evalMap{i}.computes)
            evalMap{i}.computes(j) = find(evalMap{i}.computes(j) == used_variables);
        end
    end
end

% *************************************************************************
%% REMOVE UNNECESSARY VARIABLES FROM PROBLEM
% *************************************************************************
if length(used_variables)<yalmip('nvars')
    c = c(used_variables);
    if 0
        % very slow in some extreme cases
        Q = Q(:,used_variables);Q = Q(used_variables,:);
    else
        [i,j,s] = find(Q);
        keep = ismembc(i,used_variables) & ismembc(j,used_variables);
        i = i(keep);
        j = j(keep);
        s = s(keep);
        [ii,jj] = ismember(1:length(Q),used_variables);
        i = jj(i);
        j = jj(j);
        Q = sparse(i,j,s,length(used_variables),length(used_variables));
    end
                        
    if ~isempty(F_struc)
        F_struc = sparse(F_struc(:,[1 1+used_variables]));
    end
end

% *************************************************************************
%% Map variables and constraints in low-rank definition to local stuff
% *************************************************************************
if ~isempty(lowrankdetails)
    % Identifiers of the SDP constraints
    lmiid = getlmiid(F);
    for i = 1:length(lowrankdetails)
        lowrankdetails{i}.id = find(ismember(lmiid,lowrankdetails{i}.id));
        if ~isempty(lowrankdetails{i}.variables)
            index = ismember(used_variables,lowrankdetails{i}.variables);
            lowrankdetails{i}.variables = find(index);
        end
    end
end

% *************************************************************************
%% SPECIAL VARIABLES
% Relax = 1 : relax both integers and nonlinear stuff
% Relax = 2 : relax integers
% Relax = 3 : relax nonlinear stuff
% *************************************************************************
if (options.relax==1) | (options.relax==3)
    nonlins = [];
end
if (options.relax == 1) | (options.relax==2)
    integer_variables = [];
    binary_variables  = [];
    semicont_variables  = [];
    old_binary_variables  = find(ismember(used_variables,old_binary_variables));
else
    integer_variables = find(ismember(used_variables,integer_variables));
    binary_variables  = find(ismember(used_variables,binary_variables));
    semicont_variables = find(ismember(used_variables,semicont_variables));
    old_binary_variables  = find(ismember(used_variables,old_binary_variables));
end
parametric_variables  = find(ismember(used_variables,parametric_variables));
extended_variables =  find(ismember(used_variables,yalmip('extvariables')));
aux_variables =  find(ismember(used_variables,yalmip('auxvariables')));
if ~isempty(K.sos)
    for i = 1:length(K.sos.type)
        K.sos.variables{i} =  find(ismember(used_variables,K.sos.variables{i}));
        K.sos.variables{i} = K.sos.variables{i}(:); 
    end
end

% *************************************************************************
%% Equality constraints not supported or supposed to be removed
% *************************************************************************
% We may save some data in order to reconstruct
% dual variables related to equality constraints that
% have been removed.
oldF_struc = [];
oldQ = [];
oldc = [];
oldK = K;
Fremoved = [];
if (K.f>0)
    % reduce if user explicitely says remove, or user says nothing but
    % solverdefinitions does, and there are no nonlinear variables
    if ((options.removeequalities==1 | options.removeequalities==2) & isempty(intersect(used_variables,nonlinearvariables))) | ((options.removeequalities==0) & (solver.constraint.equalities.linear==-1))
        showprogress('Solving equalities',options.showprogress);
        [x_equ,H,A_equ,b_equ,factors] = solveequalities(F_struc,K,options.removeequalities==1);
        % Exit if no consistent solution exist
        if (norm(A_equ*x_equ-b_equ,'inf')>1e-5)%sqrt(eps)*size(A_equ,2))
            diagnostic.solvertime = 0;
            diagnostic.info = yalmiperror(1,'YALMIP');
            diagnostic.problem = 1;
            solution = diagnostic;
            solution.variables = used_variables(:);
            solution.optvar = x_equ;
            % And we are done! Save the result
            % sdpvar('setSolution',solution);
            return
        end
        % We dont need the rows for equalities anymore
        oldF_struc = F_struc;
        oldc = c;
        oldQ = Q;
        oldK = K;
        F_struc = F_struc(K.f+1:end,:);
        K.f = 0;
        Fold = F;
        [nlmi neq]=size(F);
        iseq = is(Fold(1:(nlmi+neq)),'equality');
        F = Fold(find(~iseq));
        Fremoved = Fold(find(iseq));

        % No variables left. Problem solved!
        if size(H,2)==0
            diagnostic.solvertime = 0;
            diagnostic.info = yalmiperror(0,'YALMIP');
            diagnostic.problem = 0;
            solution = diagnostic;
            solution.variables = used_variables(:);
            solution.optvar = x_equ;
            % And we are done! Save the result
            % Note, no dual is saved
            sdpvar('setSolution',solution);
            p = checkset(F);
            if any(p<1e-5)
                diagnostic.info = yalmiperror(1,'YALMIP');
                diagnostic.problem = 1;
            end
            return
        end
        showprogress('Converting problem to new basis',options.showprogress)

        % objective in new basis
        f = f + x_equ'*Q*x_equ;
        c = H'*c + 2*H'*Q*x_equ;
        Q = H'*Q*H;Q=((Q+Q')/2);
        % LMI in new basis
        F_struc = [F_struc*[1;x_equ] F_struc(:,2:end)*H];
    else
        % Solver does not support equality constraints and user specifies
        % double-sided inequalitis to remove them
        if (solver.constraint.equalities.linear==0 | options.removeequalities==-1)
            % Add equalities
            F_struc = [-F_struc(1:1:K.f,:);F_struc];
            K.l = K.l+K.f*2;
            % Keep this in mind...
            K.fold = K.f;
            K.f = 0;
        end
        % For simpliciy we introduce a dummy coordinate change
        x_equ   = 0;
        H       = 1;
        factors = [];
    end
else
    x_equ   = 0;
    H       = 1;
    factors = [];
end


% *************************************************************************
%% Setup the initial solution
% *************************************************************************
x0 = [];
if options.usex0
    if options.relax
        x0_used = relaxdouble(recover(used_variables));
    else
        %FIX : Do directly using yalmip('solution')
        %solution = yalmip('getsolution');
        x0_used = double(recover(used_variables));
    end
    x0 = zeros(sdpvar('nvars'),1);
    x0(used_variables)  = x0_used(:);
    x0(isnan(x0))=0;
end
if ~isempty(x0)
    % Get a coordinate in the reduced space
    x0 = H\(x0(used_variables)-x_equ);
end

% Monomial table for nonlinear variables
% FIX : Why here!!! mt handled above also
[mt,variabletype] = yalmip('monomtable');
if size(mt,1)>size(mt,2)
    mt(size(mt,1),size(mt,1)) = 0;
end
% In local variables
mt = mt(used_variables,used_variables);
variabletype = variabletype(used_variables);
if (options.relax == 1)|(options.relax==3)
    mt = eye(length(used_variables));
    variabletype = variabletype*0;
end

% FIX : Make sure these things work...
lub = yalmip('getbounds',used_variables);
lb = lub(:,1)-inf;
ub = lub(:,2)+inf;
lb(old_binary_variables) = max(lb(old_binary_variables),0);
ub(old_binary_variables) = min(ub(old_binary_variables),1);

% This does not work if we have used removeequalities, so we clear them for
% safety. note that bounds are not guaranteed to be used according to the
% manual, so this is allowed, although it might be a bit inconsistent to
% some users.
if ~isempty(oldc)
    lb = [];
    ub = [];
end

% *************************************************************************
%% GENERAL DATA EXCHANGE WITH SOLVER
% *************************************************************************
interfacedata.F_struc = F_struc;
interfacedata.c = c;
interfacedata.Q = Q;
interfacedata.f = f;
interfacedata.K = K;
interfacedata.lb = lb;
interfacedata.ub = ub;
interfacedata.x0 = x0;
interfacedata.options = options;
interfacedata.solver  = solver;
interfacedata.monomtable = mt;
interfacedata.variabletype = variabletype;
interfacedata.integer_variables   = integer_variables;
interfacedata.binary_variables    = binary_variables;
interfacedata.semicont_variables    = semicont_variables;
interfacedata.semibounds = [];
interfacedata.uncertain_variables = [];
interfacedata.parametric_variables= parametric_variables;
interfacedata.extended_variables  = extended_variables;
interfacedata.aux_variables  = aux_variables;
interfacedata.used_variables      = used_variables;
interfacedata.lowrankdetails = lowrankdetails;
interfacedata.problemclass = ProblemClass;
interfacedata.KCut = KCut;
interfacedata.getsolvertime = 1;
% Data to be able to recover duals when model is reduced
interfacedata.oldF_struc = oldF_struc;
interfacedata.oldc = oldc;
interfacedata.oldK = oldK;
interfacedata.factors = factors;
interfacedata.Fremoved = Fremoved;
interfacedata.evalMap = evalMap;
interfacedata.evalVariables = evalVariables;
interfacedata.evaluation_scheme = [];
interfacedata.equalitypresolved = 0;
interfacedata.ProblemClass = ProblemClass;

% *************************************************************************
%% GENERAL DATA EXCANGE TO RECOVER SOLUTION AND UPDATE YALMIP VARIABLES
% *************************************************************************
recoverdata.H = H;
recoverdata.x_equ = x_equ;
recoverdata.used_variables = used_variables;

%%
function yesno = warningon

s = warning;
if isa(s,'char')
    yesno = isequal(s,'on');
else
    yesno = isequal(s(1).state,'on');
end

%%
function [evalMap,evalVariables,used_variables,nonlinearvariables,linearvariables] = detectHiddenNonlinear(used_variables,options,nonlinearvariables,linearvariables,eIN)

%evalVariables = yalmip('evalVariables');
evalVariables = eIN;
old_used_variables = used_variables;
goon = 1;
if ~isempty(evalVariables)
    while goon
        % Which used_variables are representing general functions
     %   evalVariables = yalmip('evalVariables');
     evalVariables = eIN;
        usedEvalVariables = find(ismember(used_variables,evalVariables));
        evalMap =  yalmip('extstruct',used_variables(usedEvalVariables));
        if ~isa(evalMap,'cell')
            evalMap = {evalMap};
        end
        % Find all variables used in the arguments of these functions
        hidden = [];
        for i = 1:length(evalMap)
            n = length(evalMap{i}.arg{1});
            if isequal(getbase(evalMap{i}.arg{1}),[zeros(n,1) eye(n)])% & is(evalMap{i}.arg{1},'linear')
                for j = 1:length(evalMap{i}.arg)-1
                    % The last argument is the help variable z in the
                    % transformation from f(ax+b) to f(z),z==ax+b. We should not
                    % use this transformation if the argument already is unitary
                    hidden = [hidden getvariables(evalMap{i}.arg{j})];
                end
            else
                for j = 1:length(evalMap{i}.arg)
                    % The last argument is the help variable z in the
                    % transformation from f(ax+b) to f(z),z==ax+b. We should not
                    % use this transformation if the argument already is unitary
                    hidden = [hidden getvariables(evalMap{i}.arg{j})];
                end
            end
        end
        used_variables = union(used_variables,hidden);

        % The problem is that linear terms might be missing in problems with only
        % nonlinear expressions
        [monomtable,variabletype] = yalmip('monomtable');
        if (options.relax==1)|(options.relax==3)
            monomtable = [];
            nonlinearvariables = [];
            linearvariables = used_variables;
        else
            nonlinearvariables = find(variabletype);
            linearvariables = used_variables(find(variabletype(used_variables)==0));
        end
        needednonlinear = nonlinearvariables(ismembc(nonlinearvariables,used_variables));
        linearinnonlinear = find(sum(abs(monomtable(needednonlinear,:)),1));
        missinglinear = setdiff(linearinnonlinear(:),linearvariables);
        used_variables = uniquestripped([used_variables(:);missinglinear(:)]);


        usedEvalVariables = find(ismember(used_variables,evalVariables));
        evalMap =  yalmip('extstruct',used_variables(usedEvalVariables));
        if ~isa(evalMap,'cell')
            evalMap = {evalMap};
        end
        evalVariables = usedEvalVariables;

        for i = 1:length(evalMap)
            n = length(evalMap{i}.arg{1});
            if isequal(getbase(evalMap{i}.arg{1}),[zeros(n,1) eye(n)])
                index = ismember(used_variables,getvariables(evalMap{i}.arg{1}));
                evalMap{i}.variableIndex = find(index);
            else
                index = ismember(used_variables,getvariables(evalMap{i}.arg{end}));
                evalMap{i}.variableIndex = find(index);
            end
        end
        goon = ~isequal(used_variables,old_used_variables);
        old_used_variables = used_variables;
    end
else
    evalMap = [];
end


function evalVariables = determineEvaluationBased(operators)
evalVariables = [];
for i = 1:length(operators)
    if strcmpi(operators{i}.properties.model,'callback')
        evalVariables = [evalVariables operators{i}.properties.models];
    end
end


function  [Fout,binary_variables] = convertsos2(F,binary_variables)
Fout = [];
for i = 1:length(F)
    sos2i = is(F,'sos2');
    Fout = [Fout,F(find(~sos2i))];
    for i = find(sos2i(:))'
        lambda = recover(getvariables(F(i)));
        n = length(lambda)-1;
        r = binvar(n,1);binary_variables = [binary_variables,getvariables(r)];
        Fout = [Fout,lambda(0+1) <= r(1), sum(r)==1];
        for l =1:n-1
            Fout = [Fout,lambda(l+1)-r(l)-r(l+1) < 0];
        end
        Fout = [Fout,lambda(end)<r(end)];
    end
end


function [Fnew,changed] = convertsocp2NONLINEAR(F);
changed = 0;
socps = find(is(F,'socp'));
Fsocp = F(socps);
Fnew = F;
if length(socps) > 0
    changed = 1;
    Fnew(socps) = [];
    for i = socps(:)'
        z = sdpvar(Fsocp(i));
        Fnew = [Fnew, z(1)>=0, z(1)^2 >= z(2:end)'*z(2:end)];
    end
end




