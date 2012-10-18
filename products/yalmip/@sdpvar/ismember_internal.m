function YESNO = ismember_internal(x,p)
%ISMEMBER_INTERNAL Helper for ISMEMBER

if isa(x,'sdpvar') & (isa(p,'polytope') | isa(p,'Polyhedron'))

    if length(p) == 1
        [H,K,Ae,be] = poly2data(p);
        if min(size(x))>1
            error('first argument should be a vector');
        end
        if length(x) == size(H,2)
            x = reshape(x,length(x),1);
            YESNO = [H*x <= K,Ae*x == be];
            return
        else
            disp('The polytope in the ismember condition has wrong dimension')
            error('Dimension mismatch.');
        end

    else
        d = binvar(length(p),1);
        YESNO = set(sum(d)==1);
        [L,U] = safe_bounding_box(p(1));
        for i = 1:length(p)
            [Li,Ui] = safe_bounding_box(p(i));
            L = min([L Li],[],2);
            U = max([U Ui],[],2);
        end
        for i = 1:length(p)
            [H,K,Ae,be] = poly2data(p(i));
            % Merge equalities into inequalities
            H = [H;Ae;-Ae];
            K = [K;be;-be];
            if min(size(x))>1
                error('first argument should be a vector');
            end
            if length(x) == size([H],2)
                x = reshape(x,length(x),1);
                lhs = H*x-K;
                % Derive bounds based on YALMIPs knowledge on bounds on
                % involved variables
                [M,m] = derivebounds(lhs);
                % Strengthen by using MPTs bounding box
                %[temp,L,U] = bounding_box(p(i));
                Hpos = (H>0);
                Hneg = (H<0);
                M = min([M (H.*Hpos*U+H.*Hneg*L-K)],[],2);
                YESNO = YESNO + set(H*x-K <= M.*(1-extsubsref(d,i)));
            else
                error('Dimension mismatch.');
            end
        end

    end
    return
end

if isa(x,'sdpvar') & isa(p,'double')
    
    x = reshape(x,prod(x.dim),1);
   
    
    if numel(p)==1
        F = set(x == p);
    else
        if size(p,1)==length(x) & size(p,2)>1
            Delta = binvar(size(p,2),1);
            F = [sum(Delta) == 1, x == p*Delta];
        else
            p = p(:);
            Delta = binvar(length(x),length(p),'full');
            F = [sum(Delta,2) == 1, x == Delta*p];
        end
    end

    YESNO = F;
    return
end

function [H,K,Ae,be] = poly2data(p);

if isa(p,'polytope')
    [H,K] = double(p);
    Ae = [];
    be = [];
    
else
    p = convexHull(p);
    H = p.A;
    K = p.b;
    Ae = p.Ae;
    be = p.be;   
end

function [L,U] = safe_bounding_box(P)

if isa(P,'polytope')
     [temp,L,U] = bounding_box(P);
else
    S = outerApprox(P);
    L = S.Internal.lb;
    U = S.Internal.ub;
end