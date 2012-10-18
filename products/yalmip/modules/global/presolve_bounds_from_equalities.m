function p = presolve_bounds_from_equalities(p)

% Simple extraction first
if p.K.f > 0
    [p.lb,p.ub] = remove_bounds_from_Aeqbeq(-p.F_struc(1:p.K.f,2:end),p.F_struc(1:p.K.f,1),p.lb,p.ub);
end

p.equalitypresolved = 1;
LU = [p.lb p.ub];

p_F_struc = p.F_struc;
n_p_F_struc_cols = size(p_F_struc,2);

if p.K.f >0
    % Find bounds from sum(xi) = 1, xi>0
    for j = 1:p.K.f
        if p_F_struc(j,1)>0
            [row,col,val] = find(p_F_struc(j,:));
            if all(val(2:end) < 0)
                if all(p.lb(col(2:end)-1)>=0)
                    p.ub(col(2:end)-1) = min( p.ub(col(2:end)-1) , val(1)./abs(val(2:end)'));
                end
            end
        end
    end
   
    A = p.F_struc(1:p.K.f,2:end);
    AT = A';
    Ap = max(0,A);ApT = Ap';
    Am = min(0,A);AmT = Am';
    
    two_terms = sum(p.F_struc(1:p.K.f,2:end) | p.F_struc(1:p.K.f,2:end),2)==2;
      
    for j = find(sum(p.F_struc(1:p.K.f,2:end) | p.F_struc(1:p.K.f,2:end),2)>1)'
        % Simple x == y
        done = 0;
        b = full(p_F_struc(j,1));
        if b==0 & two_terms(j)
            [row,col,val] = find(p_F_struc(j,:));
            if length(row) == 2
                if val(1) == -val(2)
                    p.lb(col(1)-1) = max(p.lb(col(1)-1),p.lb(col(2)-1));
                    p.lb(col(2)-1) = max(p.lb(col(1)-1),p.lb(col(2)-1));
                    p.ub(col(1)-1) = min(p.ub(col(1)-1),p.ub(col(2)-1));
                    p.ub(col(2)-1) = min(p.ub(col(1)-1),p.ub(col(2)-1));
                    done = 1;
                elseif val(1) == val(2)
                    p.lb(col(1)-1) = max(p.lb(col(1)-1),-p.ub(col(2)-1));
                    p.lb(col(2)-1) = max(-p.ub(col(1)-1),p.lb(col(2)-1));
                    p.ub(col(1)-1) = min(p.ub(col(1)-1),-p.lb(col(2)-1));
                    p.ub(col(2)-1) = min(-p.lb(col(1)-1),p.ub(col(2)-1));
                    done = 1;
                end
            end
        end
        if ~done
            a = AT(:,j)';
            ap = (ApT(:,j)');
            am = (AmT(:,j)');
            find_a = find(a);
            
            p_ub = p.ub(find_a);
            p_lb = p.lb(find_a);
            
            if  any(isinf(p_lb)) | any(isinf(p_ub))
                [p_lb,p_ub] = propagatewINFreduced(full(a(find_a)),full(ap(find_a)),full(am(find_a)),p_lb,p_ub,b);
                p.lb(find_a) = p_lb;
                p.ub(find_a) = p_ub;
            else
                [p_lb,p_ub] = propagatewoINFreduced(full(a(find_a)),full(ap(find_a)),full(am(find_a)),p_lb,p_ub,b);
                p.lb(find_a) = p_lb;
                p.ub(find_a) = p_ub;
            end
            %               if  any(isinf(p.lb)) | any(isinf(p.ub))
            %                p = propagatewINF(p,AT,ApT,AmT,j,b);
            %            else
            %                p = propagatewoINF(p,AT,ApT,AmT,j,b);
            %            end
        end
    end
end
close = find(abs(p.lb - p.ub) < 1e-12);
p.lb(close) = (p.lb(close)+p.ub(close))/2;
p.ub(close) = p.lb(close);
if ~isequal(LU,[p.lb p.ub])
    p.changedbounds = 1;
end



function [p_lb,p_ub] = propagatewINFreduced(a,ap,am,p_lb,p_ub,b);
%a = AT(:,j)';
%ap = (ApT(:,j)');
%am = (AmT(:,j)');

%p_ub = p.ub;
%p_lb = p.lb;

%find_a = find(a);
%  find_a = find_a(min(find(isinf(p.lb(find_a)) | isinf(p.ub(find_a)))):end);
for k = 1:length(a)%find_a
    
    p_ub_k = p_ub(k);
    p_lb_k = p_lb(k);
    
    if (p_ub_k-p_lb_k) > 1e-8
        L = p_lb;
        U = p_ub;
        L(k) = 0;
        U(k) = 0;
        ak = a(k);
        if ak > 0
            newlower = (-b - ap*U - am*L)/ak;
            newupper = (-b - am*U - ap*L)/ak;
        else
            newlower = (-b - am*U - ap*L)/ak;
            newupper = (-b - ap*U - am*L)/ak;
        end       
        if p_ub_k>newupper
            p_ub(k) = newupper;           
        end
        if p_lb_k<newlower
            p_lb(k) = newlower;
        end
    end
end
p.ub = p_ub;
p.lb = p_lb;

function [p_lb,p_ub] = propagatewoINFreduced(a,ap,am,p_lb,p_ub,b);

L = p_lb;
U = p_ub;

apU = ap*U;
amU = am*U;
apL = ap*L;
amL = am*L;

papU = ap.*U';
pamU = am.*U';
papL = ap.*L';
pamL = am.*L';

minusbminusapUminusamL = -b-apU-amL;
minusbminusamUminusapL = -b-amU-apL;
for k = 1:length(a)%find_a
    
    p_ub_k = p_ub(k);
    p_lb_k = p_lb(k);
    
    if (p_ub_k-p_lb_k) > 1e-8
        ak = a(k);
        if ak > 0
            %newlower = (-b-apU+papU(k)-amL+pamL(k) )/ak;
            %newupper = (-b-amU+pamU(k)-apL+papL(k) )/ak;
            newlower = (minusbminusapUminusamL+papU(k)+pamL(k) )/ak;
            newupper = (minusbminusamUminusapL+pamU(k)+papL(k) )/ak;
        else
            newlower = (minusbminusamUminusapL+pamU(k)+papL(k) )/ak;
            newupper = (minusbminusapUminusamL+papU(k)+pamL(k) )/ak;
        end
        if p_ub_k>newupper
            p_ub(k) = newupper;
            U(k) = newupper;
            apU = ap*U;
            amU = am*U;
            papU = ap.*U';
            pamU = am.*U';
            minusbminusapUminusamL = -b-apU-amL;
            minusbminusamUminusapL = -b-amU-apL;
        end
        if p_lb_k<newlower
            p_lb(k) = newlower;
            L(k) = newlower;
            apL = ap*L;
            amL = am*L;
            papL = ap.*L';
            pamL = am.*L';
            minusbminusapUminusamL = -b-apU-amL;
            minusbminusamUminusapL = -b-amU-apL;
        end
    end
end
%p.ub = p_ub;
%p.lb = p_lb;

function p = propagatewINF(p,AT,ApT,AmT,j,b);
a = AT(:,j)';
ap = (ApT(:,j)');
am = (AmT(:,j)');


p_ub = p.ub;
p_lb = p.lb;

find_a = find(a);
%  find_a = find_a(min(find(isinf(p.lb(find_a)) | isinf(p.ub(find_a)))):end);
for k = find_a
    
    p_ub_k = p_ub(k);
    p_lb_k = p_lb(k);
    
    if (p_ub_k-p_lb_k) > 1e-8
        L = p_lb;
        U = p_ub;
        L(k) = 0;
        U(k) = 0;
        ak = a(k);
        if ak > 0
            newlower = (-b - ap*U - am*L)/ak;
            newupper = (-b - am*U - ap*L)/ak;
        else
            newlower = (-b - am*U - ap*L)/ak;
            newupper = (-b - ap*U - am*L)/ak;
        end
        %                     if isinf(newlower) | isinf(newupper)
        %                         z = newlower;
        %                     end
        if p_ub_k>newupper
            p_ub(k) = newupper;           
        end
        if p_lb_k<newlower
            p_lb(k) = newlower;
        end
    end
end
p.ub = p_ub;
p.lb = p_lb;

function p = propagatewoINF(p,AT,ApT,AmT,j,b);
a = full(AT(:,j)');
ap = full((ApT(:,j)'));
am = full((AmT(:,j)'));


p_ub = p.ub;
p_lb = p.lb;

find_a = find(a);

    L = p_lb;
    U = p_ub;
    
    apU = ap*U;
    amU = am*U;
    apL = ap*L;
    amL = am*L;
    
    papU = ap.*U';
    pamU = am.*U';
    papL = ap.*L';
    pamL = am.*L';
    
    
    minusbminusapUminusamL = -b-apU-amL;    
    minusbminusamUminusapL = -b-amU-apL;    
for k = find_a
    
    p_ub_k = p_ub(k);
    p_lb_k = p_lb(k);
    
    if (p_ub_k-p_lb_k) > 1e-8
        ak = a(k);
        if ak > 0
            %newlower = (-b-apU+papU(k)-amL+pamL(k) )/ak;
            %newupper = (-b-amU+pamU(k)-apL+papL(k) )/ak;
            newlower = (minusbminusapUminusamL+papU(k)+pamL(k) )/ak;
            newupper = (minusbminusamUminusapL+pamU(k)+papL(k) )/ak;
        else
            newlower = (minusbminusamUminusapL+pamU(k)+papL(k) )/ak;
            newupper = (minusbminusapUminusamL+papU(k)+pamL(k) )/ak;
        end
        if p_ub_k>newupper
            p_ub(k) = newupper;
            U(k) = newupper;
            apU = ap*U;
            amU = am*U;
            papU = ap.*U';
            pamU = am.*U';
            minusbminusapUminusamL = -b-apU-amL;    
            minusbminusamUminusapL = -b-amU-apL;    
        end
        if p_lb_k<newlower
            p_lb(k) = newlower;
            L(k) = newlower;
            apL = ap*L;
            amL = am*L;
            papL = ap.*L';
            pamL = am.*L';
            minusbminusapUminusamL = -b-apU-amL;    
            minusbminusamUminusapL = -b-amU-apL;    
        end
    end
end
p.ub = p_ub;
p.lb = p_lb;






























