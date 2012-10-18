function model = yalmip2nonlinearsolver(model)

if ~model.equalitypresolved
    model = presolve_bounds_from_equalities(model);
end

K = model.K;
lb = model.lb;
ub = model.ub;
x0 = model.x0;
c = model.c;

if isempty(model.evaluation_scheme)
    model = build_recursive_scheme(model);
end
model = compress_evaluation_scheme(model);

% Do some pre-calc to be used in calls from fmincon
nonlinearindicies = union(find(model.variabletype~=0),model.evalVariables);
linearindicies    = setdiff(find(model.variabletype==0),nonlinearindicies);
model.nonlinearindicies = nonlinearindicies;
model.linearindicies    = linearindicies;

model.Anonlinineq = [];
model.bnonlinineq = [];
model.Anonlineq = [];
model.bnonlineq = [];

% Extract linear and nonlinear equality constraints
if K.f>0
    Aeq = -model.F_struc(1:1:K.f,2:end);
    beq = model.F_struc(1:1:model.K.f,1);
    
    nonlinear_equalities_indicies = find(any(Aeq(:,nonlinearindicies),2));
    model.Anonlineq = Aeq(nonlinear_equalities_indicies,:);
    model.bnonlineq = beq(nonlinear_equalities_indicies);
    
    Aeq(nonlinear_equalities_indicies,:) = [];
    beq(nonlinear_equalities_indicies,:) = [];
    Aeq(:,nonlinearindicies) = [];
    model.F_struc(1:model.K.f,:) = [];
    model.K.f = 0;
else
    Aeq = [];
    beq = [];
end

% Find nonlinear eualities implied by lower and upper bounds
if ~isempty(ub) & ~isempty(lb)
    nonlinearequality = find(lb(nonlinearindicies) == ub(nonlinearindicies));
    if ~isempty(nonlinearequality)
        for i = 1:length(nonlinearequality)
            model.Anonlineq = [model.Anonlineq;eyev(length(c),nonlinearindicies(nonlinearequality(i)))'];
            model.bnonlineq = [model.bnonlineq;lb(nonlinearindicies(nonlinearequality(i)))];
        end
    end
end

% Extract linear and nonlinear inequality constraints
if model.K.l>0
    A = -model.F_struc(1:model.K.l,2:end);
    b = model.F_struc(1:model.K.l,1);
    
    nonlinear_inequalities_indicies = find(any(A(:,nonlinearindicies),2));
    
    model.Anonlinineq = A(nonlinear_inequalities_indicies,:);
    model.bnonlinineq = b(nonlinear_inequalities_indicies);
    
    A(nonlinear_inequalities_indicies,:) = [];
    b(nonlinear_inequalities_indicies,:) = [];
    A(:,nonlinearindicies) = [];
    
    model.F_struc(1:model.K.l,:) = [];
    model.K.l = 0;
else
    A = [];
    b = [];
end

% This helps with robustness in bnb in some cases
x0candidate = zeros(length(c),1);
if ~isempty(lb) & ~isempty(ub)
    bounded = find(~isinf(lb) & ~isinf(ub));
    x0candidate(bounded) = (lb(bounded) + ub(bounded))/2;
    bounded_below = find(~isinf(lb) & isinf(ub));
    x0candidate(bounded_below) = lb(bounded_below) + 0.5;
    bounded_above = find(~isinf(lb) & isinf(ub));
    x0candidate(bounded_above) = lb(bounded_above) + 0.5;
end

if isempty(x0)
    x0 = x0candidate(linearindicies);
else
    if ~isempty(lb) & ~isempty(ub)
        x0((x0 < lb) | (x0 > ub)) = x0candidate((x0 < lb) | (x0 > ub));
    end
    x0 = x0(linearindicies);
end

if ~isempty(lb)
    lb = lb(linearindicies);
end
if ~isempty(ub)
    ub = ub(linearindicies);
end

lb_old = lb;
ub_old = ub;
[lb,ub,A,b] = remove_bounds_from_Ab(A,b,lb,ub);
[lb,ub,Aeq,beq] = remove_bounds_from_Aeqbeq(Aeq,beq,lb,ub);

    
if size(A,1) == 0
    A = [];
end

if size(b,1) == 0
    b = [];
end

if size(Aeq,1) == 0
    Aeq = [];
end

if size(beq,1) == 0
    beq = [];
end

if ~isempty(beq) &  (~model.equalitypresolved | ~(isequal(lb,lb_old) & isequal(ub,ub_old)))
    % This helps when there are artificial variables introduced to model
    % nonlinear operators such as log(2*x+1)
    p.F_struc = [beq -Aeq];
    p.K.f = size(beq,1);
    p.lb = lb;
    p.ub = ub;
    p = presolve_bounds_from_equalities(p);
    lb = p.lb;
    ub = p.ub;
end

model.A = A;
model.b = b;
model.Aeq = Aeq;
model.beq = beq;
model.lb = lb;
model.ub = ub;
model.x0 = x0;

model = setup_fmincon_params(model);

% Check if all derivatives are available
model.derivative_available = 1;
for i = 1:length(model.evalMap)
    if isempty(model.evalMap{i}.properties.derivative)
        model.derivative_available = 0;
        break
    end
end

% Some precomputation of computational scheme for Jacobian
allA = [model.Anonlineq;model.Anonlinineq];
requested = any(allA',2);
[i,j] = find((model.deppattern(find(requested),:)));
requested(j) = 1;
model.Crecursivederivativeprecompute = precomputeDerivative(model,requested);

% Some precomputation of computational scheme for gradient
requested = model.c | any(model.Q,2);
[i,j,k] = find((model.deppattern(find(requested),:)));
requested(j) = 1;
model.frecursivederivativeprecompute = precomputeDerivative(model,requested);

% Precomputed list of bilinear expressions, used in
% apply_recursive_differentiation
Bilinears = find(model.variabletype==1);
BilinearsList = zeros(length(model.c),2);
for i = Bilinears
    vars = find(model.monomtable(i,:));
    BilinearsList(i,:) = vars(:)';
end
model.Bilinears = Bilinears;
model.BilinearsList = BilinearsList;
% Precomputed list of quadratic expressions, used in
% apply_recursive_differentiation
Quadratics = find(model.variabletype==2);
QuadraticsList = zeros(length(model.c),2);
for i = Quadratics
    vars = find(model.monomtable(i,:));
    QuadraticsList(i,:) = vars(:)';
end
model.Quadratics = Quadratics;
model.QuadraticsList = QuadraticsList;


function precompute = precomputeDerivative(model,requested)

Z = double(model.monomtable | model.monomtable);
precompute = cell(length(model.linearindicies),length(model.evaluation_scheme));
for variable = 1:length(model.linearindicies)
    dx = zeros(length(model.c),1);
    dx(model.linearindicies(variable)) = 1;
    if any(model.deppattern(requested,model.linearindicies(variable)))
        for i = 1:length(model.evaluation_scheme)
            precompute{variable,i}=0;
            switch model.evaluation_scheme{i}.group
                case 'eval'
                    for j = model.evaluation_scheme{i}.variables
                        k = model.evalMap{j}.variableIndex;
                        if any(dx(k))
                            if any(requested(model.evalMap{j}.computes))
                                precompute{variable,i}(j)=1;
                                if any(requested(model.evalMap{j}.computes))
                                    dx(model.evalMap{j}.computes) = 1;
                                end
                            end
                        end
                    end
                case 'monom'
                    computed = model.monomials(model.evaluation_scheme{i}.variables);                   
                    hh = any(Z(computed,find(dx)),2);                    
                    for j = computed(find(hh))
                        if requested(j)
                            dx(j) = 1;
                        end
                    end
                    
                otherwise
            end
            precompute{variable,i} = find(precompute{variable,i});
        end
    end
end
