function [problem,integer_variables,binary_variables,parametric_variables,uncertain_variables,semicont_variables,quad_info] = categorizeproblem(F,P,h,relax,parametric,evaluation,F_vars)
%categorizeproblem          Internal function: tries to determine the type of optimization problem

% Author Johan L�fberg
% $Id: categorizeproblem.m,v 1.24 2009-05-29 08:05:12 joloef Exp $

Counter = size(F.clauses,2);
Ftype = zeros(Counter,1);

real_data = 1;
int_data  = 0;
interval_data  = 0;
bin_data = 0;
par_data = 0;
scn_data = 0;

poly_constraint = 0;
bilin_constraint = 0;
sigm_constraint = 0;
rank_constraint = 0;
rank_objective = 0;

parametric_variables = [];
kyp_prob  = 0;
gkyp_prob  = 0;

% ***********************************************
% Setup an empty problem definition
% ***********************************************
problem.objective.linear = 0;
problem.objective.quadratic.convex = 0;
problem.objective.quadratic.nonconvex = 0;
problem.objective.polynomial = 0;
problem.objective.maxdet.convex = 0;
problem.objective.maxdet.nonconvex = 0;
problem.objective.sigmonial = 0;

problem.constraint.equalities.linear     = 0;
problem.constraint.equalities.quadratic  = 0;
problem.constraint.equalities.polynomial = 0;
problem.constraint.equalities.sigmonial  = 0;

problem.constraint.inequalities.elementwise.linear = 0;
problem.constraint.inequalities.elementwise.quadratic.convex = 0;
problem.constraint.inequalities.elementwise.quadratic.nonconvex = 0;
problem.constraint.inequalities.elementwise.sigmonial = 0;
problem.constraint.inequalities.elementwise.polynomial = 0;

problem.constraint.inequalities.semidefinite.linear = 0;
problem.constraint.inequalities.semidefinite.quadratic = 0;
problem.constraint.inequalities.semidefinite.polynomial = 0;
problem.constraint.inequalities.semidefinite.sigmonial = 0;

problem.constraint.inequalities.rank = 0;

problem.constraint.inequalities.secondordercone = 0;
problem.constraint.inequalities.rotatedsecondordercone = 0;
problem.constraint.inequalities.powercone = 0;

problem.constraint.complementarity.linear = 0;
problem.constraint.complementarity.nonlinear = 0;

problem.constraint.integer = 0;
problem.constraint.binary = 0;
problem.constraint.semicont = 0;
problem.constraint.sos1 = 0;
problem.constraint.sos2 = 0;

problem.complex = 0;
problem.parametric = parametric;
problem.interval = 0;
problem.evaluation = evaluation;

% ********************************************************
% Make a list of all globally available discrete variables
% ********************************************************
integer_variables   = yalmip('intvariables');
binary_variables    = yalmip('binvariables');
semicont_variables = yalmip('semicontvariables');
uncertain_variables = yalmip('uncvariables');
for i = 1:Counter
    switch F.clauses{i}.type
        case 7
            integer_variables = union(integer_variables,getvariables(F.clauses{i}.data));
        case 8
            binary_variables = union(binary_variables,getvariables(F.clauses{i}.data));
        case 13
            parametric_variables = union(parametric_variables,getvariables(F.clauses{i}.data));
        case 52
            semicont_variables = union(semicont_variables,getvariables(F.clauses{i}.data));
        otherwise
    end
end

% ********************************************************
% Logarithmic objective?
% ********************************************************
if ~isempty(P)
    problem.objective.maxdet.convex = 1;
    problem.objective.maxdet.nonconvex = 1;
    problem.objective.maxdet.convex = all(P.gain<=0);
    problem.objective.maxdet.nonconvex = any(P.gain>0);                  
end
%problem.objective.maxdet = ~isempty(P);

% ********************************************************
% Rank variables
% ********************************************************
rank_variables = yalmip('rankvariables');
any_rank_variables = ~isempty(rank_variables);

% ********************************************************
% Make a list of all globally available nonlinear variables
% ********************************************************
[monomtable,variabletype] = yalmip('monomtable');

linear_variables = find(variabletype==0);
nonlinear_variables = find(variabletype~=0);
sigmonial_variables = find(variabletype==4);

if isempty(F_vars)
    allvars = getvariables(F);
else
    allvars = F_vars;
end

any_nonlinear_variables =~isempty(find(ismembc(nonlinear_variables,allvars)));
any_discrete_variables = ~isempty(integer_variables) | ~isempty(binary_variables) | ~isempty(semicont_variables);

interval_data = isinterval(h);

for i = 1:Counter
    
    Fi = F.clauses{i};
    % Only real-valued data?
    real_data = real_data & isreal(Fi.data);
    interval_data = interval_data |  isinterval(Fi.data);
    
    % Any discrete variables used
    if any_discrete_variables
        Fvar = getvariables(Fi.data);
        int_data = int_data | any(ismembc(Fvar,integer_variables));
        bin_data = bin_data | any(ismembc(Fvar,binary_variables));
        par_data = par_data | any(ismembc(Fvar,parametric_variables));
        scn_data = scn_data | any(ismembc(Fvar,semicont_variables));
    end
    
    if any_rank_variables
        rank_constraint = rank_constraint | any(ismember(getvariables(Fi.data),rank_variables));
    end
    
    if ~any_nonlinear_variables % No nonlinearly parameterized constraints
        
        switch Fi.type
            case {1,9,40}
                problem.constraint.inequalities.semidefinite.linear = 1;
            case 2
                problem.constraint.inequalities.elementwise.linear = 1;
            case 3
                problem.constraint.equalities.linear = 1;
            case {4,54}
                problem.constraint.inequalities.secondordercone = 1;
            case 5
                problem.constraint.inequalities.rotatedsecondordercone = 1;
            case 20
                problem.constraint.inequalities.powercone = 1;
            case 50
                problem.constraint.sos2 = 1;
            case 51
                problem.constraint.sos1 = 1;                
            case 55
                problem.constraint.complementarity.linear = 1;
            otherwise
        end
    else
        % Can be nonlinear stuff
        vars = getvariables(Fi.data);
        usednonlins = find(ismembc(nonlinear_variables,vars));
        if ~isempty(usednonlins)
            usedsigmonials = find(ismember(sigmonial_variables,vars));
            if ~isempty(usedsigmonials)
                switch Fi.type
                    case 1
                        problem.constraint.inequalities.semidefinite.sigmonial = 1;
                    case 2
                        problem.constraint.inequalities.elementwise.sigmonial = 1;
                    case 3
                        problem.constraint.equalities.sigmonial = 1;
                    case {4,54}
                        error('Sigmonial SOCP not supported');
                    case 5
                        error('Sigmonial RSOCP not supported');
                    otherwise
                        error('Report bug in problem classification (sigmonial constraint)');
                end
            else
                deg = degree(Fi.data);
                switch deg
                    
                    case 1
                        switch Fi.type
                            case 1
                                problem.constraint.inequalities.semidefinite.linear = 1;
                            case 2
                                problem.constraint.inequalities.elementwise.linear = 1;
                            case 3
                                problem.constraint.equalities.linear = 1;
                            case {4,54}
                                problem.constraint.inequalities.secondordercone = 1;
                            case 5
                                problem.constraint.inequalities.rotatedsecondordercone = 1;
                            case 20
                                problem.constraint.inequalities.powercone = 1;
                                
                            otherwise
                                error('Report bug in problem classification (linear constraint)');
                        end
                    case 2
                        switch Fi.type
                            case 1
                                problem.constraint.inequalities.semidefinite.quadratic = 1;
                            case 2
                                % FIX : This should be re-used from
                                % convertconvexquad
                                convex = 1;
                                f = Fi.data;f = f(:);
                                ii = 1;
                                while convex & ii<=length(f)
                                    [Q,caux,faux,xaux,info] = quaddecomp(f(ii));
                                    
                                    if info | any(eig(full(Q)) > 0)
                                        convex = 0;
                                    end
                                    ii= ii + 1;
                                end
                                if convex
                                    problem.constraint.inequalities.elementwise.quadratic.convex = 1;
                                else
                                    problem.constraint.inequalities.elementwise.quadratic.nonconvex = 1;
                                end
                            case 3
                                problem.constraint.equalities.quadratic = 1;
                            case {4,54}
                                error
                            case 5
                                error
                            case 55
                                problem.constraint.complementarity.nonlinear = 1;
                            otherwise
                                error('Report bug in problem classification (quadratic constraint)');
                        end
                    otherwise
                        switch Fi.type
                            case 1
                                problem.constraint.inequalities.semidefinite.polynomial = 1;
                            case 2
                                problem.constraint.inequalities.elementwise.polynomial = 1;
                            case 3
                                problem.constraint.equalities.polynomial = 1;
                            case {4,54}
                                %   problem.constraint.inequalities.secondordercone = 1;
                            case 5
                                %   problem.constraint.inequalities.rotatedsecondordercone = 1;
                            case 55
                                problem.constraint.complementarity.nonlinear = 1;
                            otherwise
                                error('Report bug in problem classification (polynomial constraint)');
                        end
                        
                end
            end
        else
            switch Fi.type
                case 1
                    problem.constraint.inequalities.semidefinite.linear = 1;
                case 2
                    problem.constraint.inequalities.elementwise.linear = 1;
                case 3
                    problem.constraint.equalities.linear = 1;
                case {4,54}
                    problem.constraint.inequalities.secondordercone = 1;
                case 5
                    problem.constraint.inequalities.rotatedsecondordercone = 1;
                case 20
                    problem.constraint.inequalities.powercone = 1;
                case 7
                    problem.constraint.integer = 1;
                case 8
                    problem.constraint.binary = 1;
                case 50
                    problem.constraint.sos2 = 1;
                case 51
                    problem.constraint.sos1 = 1;                    
                case 52
                    problem.constraint.semicont = 1;
                case 55
                    problem.constraint.complementarity.linear = 1;
                otherwise
                    error('Report bug in problem classification (linear constraint)');
            end
        end
    end
end

if int_data
    problem.constraint.integer = 1;
end
if bin_data
    problem.constraint.binary = 1;
end
if scn_data
    problem.constraint.semicont = 1;
end
if ~real_data
    problem.complex = 1;
end
if interval_data
    problem.interval = 1;
end
if rank_constraint
    problem.constraint.inequalities.rank = 1;
end
if ~isempty(uncertain_variables)
    problem.uncertain = 1;
end

if (relax==1) | (relax==2)
    problem.constraint.integer = 0;
    problem.constraint.binary = 0;
    problem.constraint.sos2 = 0;
    problem.constraint.semicont = 0;
    int_data = 0;
    bin_data = 0;
    scn_data = 0;
end
if (relax==1) | (relax==3)
    problem.constraint.equalities.linear = problem.constraint.equalities.linear | problem.constraint.equalities.quadratic | problem.constraint.equalities.polynomial | problem.constraint.equalities.sigmonial;
    problem.constraint.equalities.quadratic = 0;
    problem.constraint.equalities.polynomial = 0;
    problem.constraint.equalities.sigmonial = 0;
    
    problem.constraint.inequalities.elementwise.linear = problem.constraint.inequalities.elementwise.linear | problem.constraint.inequalities.elementwise.quadratic.convex | problem.constraint.inequalities.elementwise.quadratic.nonconvex | problem.constraint.inequalities.elementwise.sigmonial | problem.constraint.inequalities.elementwise.polynomial;
    problem.constraint.inequalities.elementwise.quadratic.convex = 0;
    problem.constraint.inequalities.elementwise.quadratic.nonconvex = 0;
    problem.constraint.inequalities.elementwise.sigmonial   = 0;
    problem.constraint.inequalities.elementwise.polynomial  = 0;
    
    problem.constraint.inequalities.semidefinite.linear =  problem.constraint.inequalities.semidefinite.linear | problem.constraint.inequalities.semidefinite.quadratic | problem.constraint.inequalities.semidefinite.polynomial | problem.constraint.inequalities.semidefinite.sigmonial;
    problem.constraint.inequalities.semidefinite.quadratic  = 0;
    problem.constraint.inequalities.semidefinite.polynomial = 0;
    problem.constraint.inequalities.semidefinite.sigmonial  = 0;
    
    poly_constraint = 0;
    bilin_constraint = 0;
    sigm_constraint = 0;
    problem.evaluation = 0;
end


% Analyse the objective function
quad_info = [];
if (~isempty(h)) & ~is(h,'linear') &~(relax==1) &~(relax==3)
    if ~(isempty(binary_variables) & isempty(integer_variables))
        h_var = depends(h);
        if any(ismember(h_var,binary_variables))
            problem.constraint.binary = 1;
        end
        if any(ismember(h_var,integer_variables))
            problem.constraint.integer = 1;
        end
    end
    if any(ismember(getvariables(h),sigmonial_variables))
        problem.objective.sigmonial = 1;
    else
        [Q,c,f,x,info] = quaddecomp(h);
        if ~isreal(Q) % Numerical noise common on imaginary parts
            Qr = real(Q);
            Qi = imag(Q);
            Qr(abs(Qr)<1e-10) = 0;
            Qi(abs(Qi)<1e-10) = 0;
            cr = real(c);
            ci = imag(c);
            cr(abs(cr)<1e-10) = 0;
            ci(abs(ci)<1e-10) = 0;
            Q = Qr + sqrt(-1)*Qi;
            c = cr + sqrt(-1)*ci;
        end
        if info==0
            % OK, we have some kind of quadratic expression
            % Find involved variables
            index = find(any(Q,2));
            if length(index) < length(Q)
                Qsub = Q(index,index);
                [Rsub,p]=chol(Qsub);
                if p
                    % Maybe just some silly numerics
                    [Rsub,p]=chol(Qsub+1e-12*eye(length(Qsub)));
                end
                if p==0
                    [i,j,k] = find(Rsub);
                    R = sparse((i),index(j),k,length(Qsub),length(Q));
                    %                    R = Q*0;
                    %                    R(index,index) = Rsub;
                else
                    R = [];
                end
            else
                [R,p]=chol(Q);
            end
            if p~=0
                Q = full(Q);
                if min(eig(Q))>=-1e-10
                    p=0;
                    try
                        [U,S,V]=svd(Q);
                    catch
                        [U,S,V]=svd(full(Q));
                    end
                    i = find(diag(S)>1e-10);
                    R = sqrt(S(1:max(i),1:max(i)))*V(:,1:max(i))';
                end
            end
            if p==0
                problem.objective.quadratic.convex = 1;
            else
                problem.objective.quadratic.nonconvex = 1;
            end
            quad_info.Q = Q;
            quad_info.c = c;
            quad_info.f = f;
            quad_info.x = x;
            quad_info.R = R;
            quad_info.p = p;
        else
            problem.objective.polynomial = 1;
        end
    end
else
    problem.objective.linear = ~isempty(h);
end