% *************************************************************************
% Tighten bounds at root
% *************************************************************************
function p = root_node_tighten(p,upper);
p.feasible = all(p.lb<=p.ub) & p.feasible;
if p.options.bmibnb.roottight & p.feasible
    pin = p;
    if ~isempty(p.bilinears)
        %         f = p.F_struc(1:p.K.f,:);
        %         p.F_struc(1:p.K.f,:)=[];
        %         p = addBilinearVariableCuts(p);
        %         p.F_struc = [f;p.F_struc];
        %     %    p.K.l = 0;
    end

    if all(p.K.q == 0) & all(p.K.s == 0) & all(p.K.r == 0)
        lowersolver = eval(['@' p.solver.lpcall]);
    else
        lowersolver = eval(['@' p.solver.lowercall]);
    end

    c = p.c;
    Q = p.Q;
    mt = p.monomtable;
    p.monomtable = eye(length(c));
    i = 1;

    % Add an upper bound cut?
    if (upper < inf)
        % p.c'*x+p.f < upper
        newline = [upper-p.f -p.c'];
        p.F_struc = [p.F_struc(1:p.K.f,:);newline;p.F_struc(1+p.K.f:end,:)];
        p.K.l = p.K.l + 1;
    end

    while i<=length(p.linears) & p.feasible
        j = p.linears(i);
        if p.lb(j) < p.ub(j) & (ismember(j,p.branch_variables) | (p.options.bmibnb.roottight == 2))
            p.c = eyev(length(p.c),j);
            output = feval(lowersolver,p);
            if (output.problem == 0) & (output.Primal(j)>p.lb(j)+1e-4)
                p.lb(j) = output.Primal(j);
                p = updateonenonlinearbound(p,j);
                p = clean_bounds(p);
            end
            if output.problem == 1
                p.feasible = 0;
            elseif p.lb(j) < p.ub(j) % We might have updated lb
                p.c = -eyev(length(p.c),j);
                output = feval(lowersolver,p);
                if (output.problem == 0) & (output.Primal(j) < p.ub(j)-1e-4)
                    p.ub(j) = output.Primal(j);
                    if p.ub(j)<p.lb(j)
                        p.ub(j) = p.lb(j);
                    end
                    p = updateonenonlinearbound(p,j);
                    p = clean_bounds(p);
                end
                if output.problem == 1
                    p.feasible = 0;
                end
                i = i+1;
            end
        else
            i = i + 1;
        end
    end

    %     if upper < inf
    %         p.F_struc(1+p.K.f,:) = [];
    %         p.K.l = p.K.l - 1;
    %     end
    %
    %     p.c = c;
    %     p.Q = Q;
    %     p.monomtable = mt;
    p.lb(p.lb<-1e10) = -inf;
    p.ub(p.ub>1e10) = inf;
    pin.lb = p.lb;
    pin.ub = p.ub;
    pin.feasible = p.feasible;
    p = pin;
end