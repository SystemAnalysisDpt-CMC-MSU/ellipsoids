function [output,cost,psave] = solvelower(p,options,lowersolver,xmin,upper)

psave = p;
removeThese = find(p.InequalityConstraintState==inf);
p.F_struc(p.K.f + removeThese,:) = [];
p.K.l = p.K.l - length(removeThese);

removeThese = find(p.EqualityConstraintState==inf);
p.F_struc(removeThese,:) = [];
p.K.f = p.K.f - length(removeThese);


p_cut = addBilinearVariableCuts(p);
if ~isempty(p.evalMap)
    p_cut = addEvalVariableCuts(p_cut);
    psave.evalMap = p_cut.evalMap;
end
p_cut = addMonomialCuts(p_cut);

% if p_cut.solver.lowersolver.constraint.inequalities.secondordercone
%     if length(p_cut.bilinears) > 0
%         for i = 1:length(p_cut.bilinears)
%             if p_cut.bilinears(i,2) == p_cut.bilinears(i,3)
%                 q = p_cut.bilinears(i,1);
%                 xi = p_cut.bilinears(i,2);
%                 p_cut.K.q = [p_cut.K.q 3];
%                 p_cut.F_struc(end+1,1)=1;
%                 p_cut.F_struc(end,1+q)=1;
%                 p_cut.F_struc(end+1,1+xi)=2;
%                 p_cut.F_struc(end+1,1)=1;
%                 p_cut.F_struc(end,1+q)=-1;
%             end
%         end
%         p_cut.K.q =  p_cut.K.q(p_cut.K.q>0);
%     end
% end

% **************************************
% SOLVE NODE PROBLEM
% **************************************
if any(p_cut.ub+1e-8<p_cut.lb)
    output.problem=1;
    cost = inf;
else
    % We are solving relaxed problem (penbmi might be local solver)
    p_cut.monomtable = eye(length(p_cut.c));
    
    if p.solver.lowersolver.objective.quadratic.convex
        % Setup quadratic
        for i = 1:size(p.bilinears,1)
            if p_cut.c(p.bilinears(i,1))
                p_cut.Q(p.bilinears(i,2),p.bilinears(i,3)) = p_cut.c(p.bilinears(i,1))/2;
                p_cut.Q(p.bilinears(i,3),p.bilinears(i,2)) = p_cut.Q(p.bilinears(i,3),p.bilinears(i,2))+p_cut.c(p.bilinears(i,1))/2;
                p_cut.c(p.bilinears(i,1)) = 0;
            end
        end
        
        if ~all(eig(full(p_cut.Q))>-1e-12)
            p_cut.Q = p.Q;
            p_cut.c = p.c;
        end
    end
    
    fixed = p_cut.lb >= p_cut.ub;
    if nnz(fixed) == length(p.c)
        % All variables are fixed to a bound
        output.Primal = p.lb;
        res = constraint_residuals(p,output.Primal);
        eq_ok = all(res(1:p.K.f)>=-p.options.bmibnb.eqtol);
        iq_ok = all(res(1+p.K.f:end)>=p.options.bmibnb.pdtol);
        feasible = eq_ok & iq_ok;
        if feasible
            output.problem = 0;
        else
            output.problem = 1;
        end
        cost = output.Primal'*p.Q*output.Primal + p.c'*output.Primal + p.f;
    else
        
        if nnz(fixed)==0
            
            if ~isempty(p_cut.bilinears) & 0
                top = size(p_cut.F_struc,1);
                if length(p_cut.K.s)==1 & p_cut.K.s(1)==0
                    p_cut.K.s = [];
                end
                usedterms = zeros(size(p_cut.bilinears,1),1);
                for i = 1:size(p_cut.bilinears,1)
                    if ~usedterms(i)
                        windex = p_cut.bilinears(i,1);
                        xindex = p_cut.bilinears(i,2);
                        yindex = p_cut.bilinears(i,3);
                        if xindex ~=yindex
                            % OK, we have a bilinear term
                            xsquaredindex = find(p_cut.bilinears(:,2)==xindex & p_cut.bilinears(:,3)==xindex);
                            ysquaredindex = find(p_cut.bilinears(:,2)==yindex & p_cut.bilinears(:,3)==yindex);
                            if ~isempty(xsquaredindex) & ~isempty(ysquaredindex)
                                usedterms(i) = 1;
                                usedterms(xsquaredindex) = 1;
                                usedterms(ysquaredindex) = 1;
                                xsquaredindex =  p_cut.bilinears(xsquaredindex,1);
                                ysquaredindex =  p_cut.bilinears(ysquaredindex,1);
                                if 0
                                    Z = zeros(9,size(p_cut.F_struc,2));
                                    Z(1,xsquaredindex+1) = 1;
                                    Z(2,windex+1) = 1;
                                    Z(4,windex+1) = 1;
                                    Z(5,ysquaredindex+1) = 1;
                                    Z(3,xindex+1) = 1;
                                    Z(7,xindex+1) = 1;
                                    Z(6,yindex+1) = 1;
                                    Z(8,yindex+1) = 1;
                                    Z(9,1)=1;
                                else
                                    xL = p.lb(xindex);
                                    yL = p.lb(yindex);
                                    
                                    Z = zeros(9,size(p_cut.F_struc,2));
                                    Z(1,xsquaredindex+1) = 1;
                                    Z(2,windex+1) = 1;
                                    Z(4,windex+1) = 1;
                                    Z(5,ysquaredindex+1) = 1;
                                    Z(3,xindex+1) = 1;
                                    Z(7,xindex+1) = 1;
                                    Z(6,yindex+1) = 1;
                                    Z(8,yindex+1) = 1;
                                    Z(9,1)=1;
                                    Z(3,1) = -xL;
                                    Z(7,1) = -xL;
                                    Z(6,1) = -yL;
                                    Z(8,1) = -yL;
                                    
                                    Z(1,xindex+1) = -2*xL;
                                    Z(5,yindex+1) = -2*yL;
                                    
                                    Z(1,1) = xL^2;
                                    Z(5,1) = yL^2;
                                    
                                    Z(4,xindex+1) = -yL;
                                    Z(4,yindex+1) = -xL;
                                    Z(4,1) = xL*yL;
                                    
                                    Z(2,xindex+1) = -yL;
                                    Z(2,yindex+1) = -xL;
                                    Z(2,1) = xL*yL;
                                    
                                    
                                end
                                p_cut.F_struc = [p_cut.F_struc;Z];
                                p_cut.K.s = [p_cut.K.s 3];
                            end
                        end
                    end
                end
            end
            
            p_cut.linearindicies = 1:length(p.c);
            p_cut.nonlinearindicies = [];
            p_cut.variabletype = zeros(1,length(p.c));
            p_cut.deppattern = eye(length(p.c));
            p_cut.linears = 1:length(p.c);
            p_cut.bilinears = [];
            p_cut.nonlinears = [];
            p_cut.monomials = [];
            p_cut.evaluation_scheme = [];
            
            output = feval(lowersolver,p_cut);
            cost = output.Primal'*p_cut.Q*output.Primal + p_cut.c'*output.Primal + p.f;
            % Minor clean-up
            pp=p;
            output.Primal(output.Primal<p.lb) = p.lb(output.Primal<p.lb);
            output.Primal(output.Primal>p.ub) = p.ub(output.Primal>p.ub);
            x=output.Primal;
            return
        else
            pp = p_cut;
            removethese = fixed;
            if ~isempty(p_cut.F_struc)
                p_cut.F_struc(:,1)=p_cut.F_struc(:,1)+p_cut.F_struc(:,1+find(fixed))*p_cut.lb(fixed);
                p_cut.F_struc(:,1+find(fixed))=[];
                
                rf = find(~any(p_cut.F_struc,2));
                rf = rf(rf<=(p_cut.K.f + p_cut.K.l));
                p_cut.F_struc(rf,:) = [];
                p_cut.K.l = p_cut.K.l - nnz(rf>p_cut.K.f);
                p_cut.K.f = p_cut.K.f - nnz(rf<=p_cut.K.f);
            end
            p_cut.c(removethese)=[];
            if nnz(p_cut.Q)>0
                p_cut.c = p_cut.c + 2*p_cut.Q(find(~removethese),find(removethese))*p_cut.lb(removethese);
                p_cut.Q(:,find(removethese))=[];
                p_cut.Q(find(removethese),:)=[];
            else
                p_cut.Q = spalloc(length(p_cut.c),length(p_cut.c),0);
            end
            
            if ~isempty(p_cut.binary_variables)
                new_bin = [];
                new_var = find(~fixed);
                for i = 1:length(p_cut.binary_variables)
                    temp = find(p_cut.binary_variables(i) == new_var);
                    new_bin =  [new_bin temp(:)'];
                end
                p_cut.binary_variables = new_bin;
            end
            if ~isempty(p_cut.integer_variables)
                new_bin = [];
                new_var = find(~fixed);
                for i = 1:length(p_cut.integer_variables)
                    temp = find(p_cut.integer_variables(i) == new_var);
                    new_bin =  [new_bin temp(:)'];
                end
                p_cut.integer_variables = new_bin;
            end
            
            p_cut.lb(removethese)=[];
            p_cut.ub(removethese)=[];
            p_cut.x0(removethese)=[];
            p_cut.monomtable(:,find(removethese))=[];
            p_cut.monomtable(find(removethese),:)=[];
            try
                output = feval(lowersolver,p_cut);
            catch
                1
            end
            x=p.c*0;
            x(removethese)=p.lb(removethese);
            x(~removethese)=output.Primal;
            output.Primal = x;
            cost = output.Primal'*pp.Q*output.Primal + pp.c'*output.Primal + p.f;
        end
    end
end