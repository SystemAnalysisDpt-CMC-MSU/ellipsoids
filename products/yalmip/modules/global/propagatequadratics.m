function pout = propagatequadratics(p,upper,lower)

pout = p;
if p.bilinears~=0
    F_struc = p.F_struc;

    p.F_struc = [-p.F_struc(1:p.K.f,:);p.F_struc];
    p.K.f=2*p.K.f;
    
    InequalityConstraintState = [p.EqualityConstraintState;p.EqualityConstraintState;p.InequalityConstraintState];
    
    if p.K.l+p.K.f>0
        quadratic_variables = find(p.bilinears(:,2) == p.bilinears(:,3));
        if ~isempty(quadratic_variables)
            quadratic_variables = p.bilinears(quadratic_variables,1);
            for i = 1:length(quadratic_variables)
                k = quadratic_variables(i);
                if p.lb(k) >= 0 & (p.lb(k) < p.ub(k)-1e-4)
                    x = p.bilinears(p.bilinears(:,1)==k,2);% x^2
                    candidates = find((InequalityConstraintState==1) & p.F_struc(1:p.K.f+p.K.l,1+k))';
                    for j = candidates
                        a = p.F_struc(j,2:end);
                        aij = a(k);
                        if aij > 0
                            indNEG = find(a < 0);
                            indPOS = find(a > 0);
                            LB = p.lb;
                            UB = p.ub;
                            LB(k) = 0;
                            UB(k) = 0;
                            a(k) = 0;
                            newLB = (-p.F_struc(j,1)-a([indPOS(:);indNEG(:)])*[UB(indPOS);LB(indNEG)])/aij;
                            p.lb(k) = max(p.lb(k),newLB);
                            if p.lb(x)>0
                                p.lb(x) = max(p.lb(x),sqrt(max(0,newLB)));
                            elseif p.ub(x)<0
                                p.ub(x) = min(p.ub(x),-sqrt(max(0,newLB)));
                            end
                        elseif aij < 0
                            indNEG = find(a < 0);
                            indPOS = find(a > 0);
                            LB = p.lb;
                            UB = p.ub;
                            LB(k) = 0;
                            UB(k) = 0;
                            a(k) = 0;
                            newUB = (p.F_struc(j,1)+a([indPOS(:);indNEG(:)])*[UB(indPOS);LB(indNEG)])/(-aij);
                            p.ub(k) = min(p.ub(k),newUB);
                            p.ub(x) = min(p.ub(x),sqrt(max(0,newUB)));
                        end
                    end
                elseif p.lb(k)<0
                    %  [p.lb(k) p.ub(k)]
                end
            end
        end
    end

    if p.K.l+p.K.f>0
        bilinear_variables = find(p.bilinears(:,2) ~= p.bilinears(:,3));
        if ~isempty(bilinear_variables)
            bilinear_variables = p.bilinears(bilinear_variables,1);
            for i = 1:length(bilinear_variables)
                k = bilinear_variables(i);
                if p.lb(k) >= -5000000000 & (p.lb(k) < p.ub(k)-1e-4)
                    x = p.bilinears(p.bilinears(:,1)==k,2);% x^2
                    y = p.bilinears(p.bilinears(:,1)==k,3);% x^2
                    candidates = find((InequalityConstraintState==1) & p.F_struc(1:p.K.f+p.K.l,1+k))';
                    for j = candidates
                        a = p.F_struc(j,2:end);
                        aij = a(k);
                        if aij > 0
                            indNEG = find(a < 0);
                            indPOS = find(a > 0);
                            LB = p.lb;
                            UB = p.ub;
                            LB(k) = 0;
                            UB(k) = 0;
                            a(k) = 0;
                            newLB = (-p.F_struc(j,1)-a([indPOS(:);indNEG(:)])*[UB(indPOS);LB(indNEG)])/aij;
                            p.lb(k) = max(p.lb(k),newLB);
% 
%                             if p.lb(y) > 0 & p.ub(y)~=0
%                                 p.lb(x) = max(p.lb(x),newLB/p.ub(y));                                
%                             end
%                             if p.lb(x) > 0 & p.ub(x)~=0
%                                 p.lb(y) = max(p.lb(y),newLB/p.ub(x));                                
%                             end

                        elseif aij < 0
                            indNEG = find(a < 0);
                            indPOS = find(a > 0);
                            LB = p.lb;
                            UB = p.ub;
                            LB(k) = 0;
                            UB(k) = 0;
                            a(k) = 0;
                            newUB = (p.F_struc(j,1)+a([indPOS(:);indNEG(:)])*[UB(indPOS);LB(indNEG)])/(-aij);
                            p.ub(k) = min(p.ub(k),newUB);
%                             if p.lb(y) > 0 & p.lb(y)~=0
%                                 p.ub(x) = min(p.ub(x),newUB/p.lb(y));                                
%                             end
%                             if p.lb(x) > 0 & p.lb(x)~=0
%                                 p.ub(y) = min(p.ub(y),newUB/p.lb(x));
%                             end
                        end
                    end    
                    
                    if p.lb(k)>0 & p.lb(x)>0 & p.lb(y)>0
                        p.ub(x) = min(p.ub(x), p.ub(k)/p.lb(y));
                        p.ub(y) = min(p.ub(y), p.ub(k)/p.lb(x));
                        p.lb(x) = max(p.lb(x), p.lb(k)/p.ub(y));
                        p.lb(y) = max(p.lb(y), p.lb(k)/p.ub(x));                                                
                    end
                    
                    
                elseif p.lb(k)<0
                    %   [p.lb(k) p.ub(k)]
                end
            end
        end
    end
end
if ~isequal([p.lb p.ub],[pout.lb pout.ub])
    pout.changedbounds = 1;
end
pout.lb = p.lb;
pout.ub = p.ub;