function output = callquadprog(interfacedata)

% Author Johan L�fberg
% $Id: callquadprog.m,v 1.17 2007-08-02 11:39:36 joloef Exp $

options = interfacedata.options;
model = yalmip2quadprog(interfacedata);

if options.savedebug
    save debugfile model
end

if options.showprogress;showprogress(['Calling ' interfacedata.solver.tag],options.showprogress);end
solvertime = clock;
solveroutput = callsolver(model,options);
if interfacedata.getsolvertime solvertime = etime(clock,solvertime);else solvertime = 0;end
solution = quadprogsol2yalmipsol(solveroutput,model);

% Save all data sent to solver?
if ~options.savesolverinput
    model = [];
end

% Save all data from the solver?
if ~options.savesolveroutput
    solveroutput = [];
end

% Standard interface
output.Primal      = solution.x(:);
output.Dual        = solution.D_struc;
output.Slack       = [];
output.problem     = solution.problem;
output.infostr     = yalmiperror(solution.problem,interfacedata.solver.tag);
output.solvertime  = solvertime;
if ~options.savesolverinput
    output.solverinput = [];
else
    output.solverinput = model;
end
if ~options.savesolveroutput
    output.solveroutput = [];
else
    output.solveroutput = solveroutput;
end

function solveroutput = callsolver(model,options)
x = [];
fmin = [];
flag = [];
output = [];
lambda = [];
if nnz(model.Q) == 0
    % BUG in LIN/QUADPROG, computation of lambda crashes in some rare
    % cases. To avoid seeing this when we don't want the lambdas anyway, we
    % don't ask for it
    if options.saveduals
        [x,fmin,flag,output,lambda] = linprog(model.c, model.A, model.b, model.Aeq, model.beq, model.lb, model.ub, model.x0,model.ops);
    else
        lambda = [];
        [x,fmin,flag,output] = linprog(model.c, model.A, model.b, model.Aeq, model.beq, model.lb, model.ub, model.x0,model.ops);
    end
else
    if options.saveduals
        [x,fmin,flag,output,lambda] = quadprog(model.Q, model.c, model.A, model.b, model.Aeq, model.beq, model.lb, model.ub, model.x0,model.ops);
    else
        lambda = [];
        [x,fmin,flag,output] = quadprog(model.Q, model.c, model.A, model.b, model.Aeq, model.beq, model.lb, model.ub, model.x0,model.ops);
    end
    if flag==5
        [x,fmin,flag,output,lambda] = quadprog(model.Q, model.c, model.A, model.b, model.Aeq, model.beq, model.lb, model.ub, [],model.ops);
    end
end
solveroutput.x = x;
solveroutput.fmin = fmin;
solveroutput.flag = flag;
solveroutput.output = output;
solveroutput.lambda = lambda;

function solution = quadprogsol2yalmipsol(solveroutput,model)

solution.x = solveroutput.x(:);
% Internal format for duals
if ~isempty(solveroutput.lambda)
    solution.D_struc = [solveroutput.lambda.eqlin;solveroutput.lambda.ineqlin];
else
    solution.D_struc = [];
end

% Check, currently not exhaustive...
problem = 0;
if solveroutput.flag==0
    solution.problem = 3;
else
    if solveroutput.flag==-3
        solution.problem = 2;
    elseif solveroutput.flag==-2
        solution.problem = 1;
    else
        if solveroutput.flag>0
            solution.problem = 0;
        else
            if isempty(solveroutput.x)
                solution.x = repmat(nan,length(model.f),1);
            end
            if any((model.A*solveroutput.x-model.b)>sqrt(eps)) | any( abs(model.Aeq*solveroutput.x-model.beq)>sqrt(eps))
                solution.problem = 1; % Likely to be infeasible
            else
                if model.f'*solveroutput.x<-1e10 % Likely unbounded
                    solution.problem = 2;
                else          % Probably convergence issues
                    solution.problem = 5;
                end
            end
        end
    end
end



