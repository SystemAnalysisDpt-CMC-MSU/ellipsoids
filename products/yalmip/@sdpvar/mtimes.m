function Z = mtimes(X,Y)
%MTIMES (overloaded)

% Author Johan L�fberg
% $Id: mtimes.m,v 1.81 2009-10-21 14:35:10 joloef Exp $

% Check classes
X_is_spdvar = isa(X,'sdpvar');
Y_is_spdvar = isa(Y,'sdpvar');

% Convert block objects
if ~X_is_spdvar
    if isa(X,'blkvar')
        X = sdpvar(X);
        X_is_spdvar = isa(X,'sdpvar');
    end
end

if ~Y_is_spdvar
    if isa(Y,'blkvar')
        Y = sdpvar(Y);
        Y_is_spdvar = isa(Y,'sdpvar');
    end
end

% Lame special cases, make sure to reurn
% empty matrices in the sense that the
% used MATLAB version
if isempty(X)
    YY = full(reshape(Y.basis(:,1),Y.dim(1),Y.dim(2)));
    Z = X*YY;
    return
elseif isempty(Y)
    XX = full(reshape(X.basis(:,1),X.dim(1),X.dim(2)));
    Z = XX*Y;
    return
end

% Optimized calls in different order?
if X_is_spdvar & Y_is_spdvar
    manytimesfew = length(X.lmi_variables) > 5*length(Y.lmi_variables);
    if manytimesfew
        Z = (Y'*X')'; % Optimized for this order (few variables * many variables)
        return
    end
end

% Different code for
% 1 : SDPVAR * DOUBLE
% 2 : DOUBLE * SDPVAR
% 3 : SDPVAR * SDPVAR
switch 2*X_is_spdvar+Y_is_spdvar
    case 3
        X = flush(X);
        Y = flush(Y);
        try
            % HACK: Return entropy when user types x*log(x)
            if isequal(Y.extra.opname,'log')
                Z = check_for_special_case(Y,X);
                if ~isempty(Z)
                    return
                end

            elseif isequal(X.extra.opname,'log')
                Z = check_for_special_case(X,Y);
                if ~isempty(Z)
                    return
                end
            end

            x_isscalar =  X.dim(1)*X.dim(2)==1;
            y_isscalar =  Y.dim(1)*Y.dim(2)==1;

            ny = Y.dim(1);
            my = Y.dim(2);
            nx = X.dim(1);
            mx = X.dim(2);

            [mt,oldvariabletype,mt_hash,hash] = yalmip('monomtable');

            % Super-special hack to speed up QP formulations
            % Requires that the involved variables never have been used
            % before in a nonlinear expression. By exploiting this fact, we
            % can avoid using findhash, which typically is the bottle-neck.
            if (nx == 1) & (my == 1) & isequal(X.lmi_variables,Y.lmi_variables)
                % Looks like w'Qw or similiar
                % Check that no nonlinear have been defined before, and that
                % the arguments are linear.
                if all(oldvariabletype(X.lmi_variables)==0) & nnz(mt(find(oldvariabletype),X.lmi_variables)) == 0
                    Z = super_fast_quadratic_multiplication(X,Y,mt,oldvariabletype,mt_hash,hash);
                    return
                end
            end

            % Optimized unique
            all_lmi_variables = uniquestripped([X.lmi_variables Y.lmi_variables]);

            % Create clean SDPVAR object
            Z = X;Z.dim(1) = 1;Z.dim(2) = 1;Z.lmi_variables = all_lmi_variables;Z.basis = [];

            % Awkward code due to bug in ML6.5
            Xbase = reshape(X.basis(:,1),X.dim(1),X.dim(2));
            Ybase = reshape(Y.basis(:,1),Y.dim(1),Y.dim(2));
            if x_isscalar
                Xbase = sparse(full(Xbase));
            end
            if y_isscalar
                Ybase = sparse(full(Ybase));
            end

            index_X = double(ismembc(all_lmi_variables,X.lmi_variables));
            index_Y = double(ismembc(all_lmi_variables,Y.lmi_variables));
            iX=find(index_X);
            iY=find(index_Y);
            index_X(iX)=1:length(iX);index_X=index_X(:);
            index_Y(iY)=1:length(iY);index_Y=index_Y(:);

            % Pre-allocate sufficiently long
            Z.lmi_variables = [Z.lmi_variables zeros(1,length(X.lmi_variables)*length(Y.lmi_variables))];

            % Pre-calc identity (used a lot
            speyemy = sparse(1:my,1:my,1,my,my);

            % Linear terms
            inner_vector_product = (X.dim(1)==1 & Y.dim(2)==1 & (X.dim(2) == Y.dim(1)));
            if inner_vector_product
                base1=Xbase*Y.basis;base1=base1(2:end);
                base2=Ybase.'*X.basis;base2=base2(2:end);
                [i1,j1,k1]=find(base1);
                [i2,j2,k2]=find(base2);
                base1 = sparse(i1,iY(j1),k1,1,length(all_lmi_variables));
                base2 = sparse(i2,iX(j2),k2,1,length(all_lmi_variables));
                Z.basis = [Xbase*Ybase base1+base2];
            else
                base0 = Xbase*Ybase;
                if x_isscalar
                    base1 = Xbase*Y.basis(:,2:end);
                    base2 = Ybase(:)*X.basis(:,2:end);
                elseif y_isscalar
                    base1 = Xbase(:)*Y.basis;base1=base1(:,2:end);
                    base2 = X.basis*Ybase;base2=base2(:,2:end);
                else
                    base1 = kron(speyemy,Xbase)*Y.basis(:,2:end);
                    base2 = kron(Ybase.',speye(nx))*X.basis(:,2:end);
                end
                [i1,j1,k1]=find(base1);
                [i2,j2,k2]=find(base2);
                base1 = sparse(i1,iY(j1),k1,size(base0(:),1),length(all_lmi_variables));
                base2 = sparse(i2,iX(j2),k2,size(base0(:),1),length(all_lmi_variables));
                Z.basis = [base0(:) base1+base2];
            end

            % Loop start for nonlinear terms
            i = length(all_lmi_variables)+1;

            %   [mt,oldvariabletype,mt_hash,hash] = yalmip('monomtable');

            % Check if problem is bilinear. We can exploit this later
            % to improve performance significantly...
            bilinearproduct = 0;
            candofastlocation  = 0;
            if all(oldvariabletype(X.lmi_variables)==0) & all(oldvariabletype(Y.lmi_variables)==0)
                % if isempty(intersect(X.lmi_variables,Y.lmi_variables))
                if ~any(ismembc(X.lmi_variables,Y.lmi_variables))
                    bilinearproduct = 1;
                    try
                        dummy = ismembc2(1,1); % Not available in all versions (needed in ismember)
                        candofastlocation = 1;
                    catch
                    end
                end
            end

            oldmt = mt;
            local_mt = mt(all_lmi_variables,:);
            used_variables = any(local_mt,1);
            local_mt = local_mt(:,used_variables);

            possibleOld = find(any(mt(:,used_variables),2));
            if all(oldvariabletype <=3)
                % All monomials have non-negative integer powers
                % no chance of x^2*x^-1, hence all products
                % are nonlinear
                possibleOld = possibleOld(find(oldvariabletype(possibleOld)));
                if size(possibleOld,1)==0
                    possibleOld = [];
                end
            end

            if bilinearproduct & ~isempty(possibleOld)
                if length(X.lmi_variables)<=length(Y.lmi_variables)
                    temp = mt(:,X.lmi_variables);
                    temp = temp(possibleOld,:);
                    possibleOld=possibleOld(find(any(temp,2)));
                else
                    temp = mt(:,Y.lmi_variables);
                    temp = temp(possibleOld,:);
                    possibleOld=possibleOld(find(any(temp,2)));
                end
            end

            theyvars = find(index_Y);
            thexvars = find(index_X);

            % We work with three sets of hashed data.
            % 1. The hashes that were available from the start. These are
            %    sorted
            possibleOldHash = mt_hash(possibleOld);
            [possibleOldHashSorted, sortedHashLocs] = sort(possibleOldHash);
            oldhash = hash;
            hash = hash(used_variables);

            % 2. The hashes that were introduced in the previous outer
            %    iteration, i.e. those generated when multiplying x(ix) with
            %    all y. These are sorted every iteration
            new_mt_hash = [];
            new_mt_hash_aux = spalloc(length(X.lmi_variables)*length(Y.lmi_variables),1,0);
            new_mt_hash_counter = 0;

            %             % 3. Those that are generated at the current iteration. These
            %             %    are not sorted
            %             currwent_new_mt_hash_aux = zeros(length(X.lmi_variables)*length(Y.lmi_variables),1);
            %             current_new_mt_hash_counter = 0;

            new_mt = [];
            changed_mt = 0;
            local_mt = local_mt';
            nvar = size(mt,1);
            old_new_mt_hash_counter = new_mt_hash_counter;
            possibleNewHashSorted = {};
            sortedNewHashLocs = {};



            possibleOldBlocked{1}    = possibleOld;
            sortedHashLocsBlocked{1} = sortedHashLocs;
            possibleOldHashSortedBlocked{1} = possibleOldHashSorted;
            possibleOldHashSortedBlockedFull{1} = full(possibleOldHashSorted);
            current_offset = size(mt_hash,1);

            for ix = thexvars(:)'

                mt_x = local_mt(:,ix);

                testthese = theyvars(:)';

                % Compute [vec(Xbasis*Ybasis1) vec(Xbasis*Ybasis2) ...]
                % in one shot using vectorization and Kronecker tricks
                % Optimized and treat special case scalar*matrix etc
                if x_isscalar
                    Xibase = X.basis(:,1+index_X(ix));
                    allprodbase = Xibase * Y.basis(:,1+index_Y(testthese));
                elseif y_isscalar
                    Xibase = X.basis(:,1+index_X(ix));
                    allprodbase =  Xibase * Y.basis(:,1+index_Y(testthese));
                elseif inner_vector_product
                    Xibase = X.basis(:,1+index_X(ix)).';
                    allprodbase = Xibase*Y.basis(:,1+index_Y(testthese));
                else
                    Xibase = reshape(X.basis(:,1+index_X(ix)),nx,mx);
                    temp = kron(speyemy,Xibase);
                    allprodbase = temp * Y.basis(:,1+index_Y(testthese));
                end

                % Keep non-zero matrices
                nonzeromatrices = find(sum(abs(allprodbase),1)>1e-12);
                testthese = testthese(nonzeromatrices);
                allprodbase = allprodbase(:,nonzeromatrices);

                % Some data for vectorization
                nyvars = length(testthese);
                if prod(size(mt_x))==1 % Bug in Solaris and Linux, ML 6.X
                    allmt_xplusy = local_mt(:,testthese) + sparse(repmat(full(mt_x),1,nyvars));
                else
                    allmt_xplusy = local_mt(:,testthese) + repmat(mt_x,1,nyvars);
                end
                allhash = allmt_xplusy'*hash;
                thesewhereactuallyused = zeros(1,nyvars);
                copytofrom  = ones(1,nyvars);
                acounter =  0;

                % Special case : x*inv(x) and similiar...
                sum_to_constant = abs(allhash)<eps;
                add_these = find(sum_to_constant);
                if ~isempty(add_these)
                    prodbase = allprodbase(:,add_these);
                    Z.basis(:,1) = Z.basis(:,1) + sum(prodbase,2);
                    copytofrom(add_these) = 0;
                end
                indicies = find(~sum_to_constant);
                indicies = indicies(:)';

                allbefore_in_old = 1;
                if bilinearproduct & candofastlocation
                    [dummy,allbefore_in_old] = ismember(allhash,possibleOldHash);
                end

                if bilinearproduct & candofastlocation & (nnz(allbefore_in_old)==0)
                    % All nonlinear variables are new, so we can create them at once
                    changed_mt=1;
                    thesewhereactuallyused = thesewhereactuallyused+1;
                    Z.lmi_variables(i:(i+length(indicies)-1)) = (nvar+1):(nvar+length(indicies));
                    nvar = nvar + length(indicies);
                    i = i + length(indicies);
                else

                    %isemptynew_mt_hash = new_mt_hash_counter == 0;
                    for acounter = indicies

                        current_hash = allhash(acounter);

                        % Ok, braze your self for some horrible special case
                        % treatment etc...
                        if (new_mt_hash_counter == 0) | bilinearproduct % only search among old monomials
                            if bilinearproduct & candofastlocation
                                before = allbefore_in_old(acounter);
                                if before==0
                                    before = [];
                                else
                                    before = possibleOld(before);
                                end
                            else
                                before = possibleOld(sortedHashLocs(findhashsorted(possibleOldHashSorted,current_hash)));
                            end
                        else
                            before = findhash(new_mt_hash_aux,current_hash,new_mt_hash_counter); % first among new monomials
                            if before
                                before=before+current_offset;
                            else
                                %before = possibleOld(sortedHashLocs(findhashsorted(possibleOldHashSorted,current_hash)));
                                sb = 1;
                                cth = full(current_hash);
                                while isempty(before) & sb <= length(possibleOldBlocked)
                                 %   testit = possibleOldHashSortedBlocked{sb};
                                    testitfull = possibleOldHashSortedBlockedFull{sb};
                                 %   testit = possibleOldHashSortedBlocked{sb};
                                 
                                 %    testit = possibleOldHashSortedBlocked{sb};
                                 %    testitfull = possibleOldHashSortedBlockedFull{sb};
                                 %   testitfull = possibleOldHashSortedBlockedFull{sb};
                                 %   mmm=findhashsorted(testit,cth);
                                 %   mmm=findhashsorted(testit,cth);
                                 %   mmm=findhashsorted(testitfull,cth);
                                 %   mmm=findhashsorted(testitfull,cth);
                                 %   mmm2=findhashsorted(testitfull,current_hash);
                                   mmm=findhashsorted(testitfull,cth);
                                 %   mmm=findhashsorted(testit,current_hash);
                                   % testit2 = full(possibleOldHashSortedBlocked{sb});
                                   % mmm2=findhashsorted(testit2,full(current_hash));
                                %    if ~isequal(mmm,mmm2)
                                %        1
                                %    end
                                    if mmm
                                        mmm=sortedHashLocsBlocked{sb}(mmm);
                                        before = possibleOldBlocked{sb}(mmm);
                                    end
                                    sb = sb+1;
                                end
                            end
                        end
                        if before
                            Z.lmi_variables(i) = before;
                        else
                            changed_mt=1;
                            %   isemptynew_mt_hash=0;
                            thesewhereactuallyused(acounter) = 1;
                            new_mt_hash_counter = new_mt_hash_counter + 1;
                            new_mt_hash_aux(new_mt_hash_counter) = current_hash;

                            nvar = nvar + 1;
                            Z.lmi_variables(i) = nvar;
                        end
                        i = i+1;
                    end
                end % End y-variables

                if all(copytofrom)
                    Z.basis = [Z.basis allprodbase];
                else
                    Z.basis = [Z.basis allprodbase(:,find(copytofrom))];
                end
                if all(thesewhereactuallyused)
                    new_mt = [new_mt allmt_xplusy];
                else
                    new_mt = [new_mt allmt_xplusy(:,find(thesewhereactuallyused))];
                end

                bsize = 1000;
                if new_mt_hash_counter > bsize
                    ship = new_mt_hash_aux(1:bsize);
                    mt_hash = [mt_hash;ship];
                    new_mt_hash_aux = new_mt_hash_aux(bsize+1:end);
                    new_mt_hash_counter = nnz(new_mt_hash_aux);
                    [newHashSorted, sortednewHashLocs] = sort(ship);
                    possibleOldBlocked{end+1}    = (1:bsize)+current_offset;
                    sortedHashLocsBlocked{end+1} = sortednewHashLocs;
                    possibleOldHashSortedBlocked{end+1} = (newHashSorted);
                    possibleOldHashSortedBlockedFull{end+1} = full(newHashSorted);
                    %  possibleOldHashSortedOffset{end+1} = current_offset;
                    current_offset = current_offset + bsize;
                end


            end % End x-variables

            if ~isempty(new_mt)
                [i1,j1,k1] = find(mt);
                [ii1,jj1,kk1] = find(new_mt');
                uv = find(used_variables);uv=uv(:);
                mt = sparse([i1(:);ii1(:)+size(mt,1)],[j1(:);uv(jj1(:))],[k1(:);kk1(:)],size(mt,1)+size(new_mt,2),size(mt,2));
            end

            % We pre-allocated a sufficiently long, now pick the ones we
            % actually filled with values
            Z.lmi_variables = Z.lmi_variables(1:i-1);

            % Fucked up order (lmi_variables should be sorted)
            Z = fix_variable_order(Z);

            if changed_mt%~isequal(mt,oldmt)
                newmt = mt(size(oldmt,1)+1:end,:);
                nonlinear = ~(sum(newmt,2)==1 & sum(newmt~=0,2)==1);
                newvariabletype = spalloc(size(newmt,1),1,nnz(nonlinear))';
                nonlinearvariables = find(nonlinear);
                newvariabletype = sparse(nonlinearvariables,ones(length(nonlinearvariables),1),3,size(newmt,1),1)';
                if ~isempty(nonlinear)
                    %mt = internal_sdpvarstate.monomtable;
                    %newvariabletype(nonlinear) = 3;
                    quadratic = sum(newmt,2)==2;
                    newvariabletype(quadratic) = 2;
                    bilinear = max(newmt,[],2)<=1;
                    newvariabletype(bilinear & quadratic) = 1;
                    sigmonial = any(0>newmt,2) | any(newmt-fix(newmt),2);
                    newvariabletype(sigmonial) = 4;
                end
                %                yalmip('setmonomtable',mt,[oldvariabletype newvariabletype],[mt_hash;new_mt_hash],oldhash);
                yalmip('setmonomtable',mt,[oldvariabletype newvariabletype],[mt_hash;new_mt_hash_aux(1:new_mt_hash_counter)],oldhash);
            end

            if ~(x_isscalar | y_isscalar)
                Z.dim(1) = X.dim(1);
                Z.dim(2) = Y.dim(2);
            else
                Z.dim(1) = max(X.dim(1),Y.dim(1));
                Z.dim(2) = max(X.dim(2),Y.dim(2));
            end

        catch
            error(lasterr)
        end
        % Reset info about conic terms
        Z.conicinfo = [0 0];
        Z.extra.opname='';
        Z = clean(Z);
    

    case 2

        n_X = X.dim(1);
        m_X = X.dim(2);
        [n_Y,m_Y] = size(Y);

        x_isscalar =  (n_X*m_X==1);
        y_isscalar =  (n_Y*m_Y==1);

        if ~x_isscalar
            if ((m_X~= n_Y & ~y_isscalar))
                error('Inner matrix dimensions must agree.')
            end
        end

        n = n_X;
        m = m_Y;
        Z = X;

        if x_isscalar
            if y_isscalar
                if Y==0
                    Z = 0;
                    return
                else
                    Z.basis = Z.basis*Y;
                    % Reset info about conic terms
                    Z.conicinfo = [0 0];
                    Z.extra.opname='';
                    Z = addrightfactor(Z,Y);
                    return
                end
            else
                Z.dim(1) = n_Y;
                Z.dim(2) = m_Y;
                Z.basis = kron(Z.basis,Y(:));
                Z.conicinfo = [0 0];
                Z.extra.opname='';
                Z = addrightfactor(Z,Y);
                Z = addleftfactor(Z,speye(size(Y,1)));
                Z = clean(Z);
                return
            end
        elseif y_isscalar
            Z.dim(1) = n_X;
            Z.dim(2) = m_X;
            Z.basis = Z.basis*Y;
            Z.conicinfo = [0 0];
            Z.extra.opname='';
            Z = addrightfactor(Z,Y);
            Z = addleftfactor(Z,speye(size(Y,1)));
            Z = clean(Z);
            return
        end

        Z.dim(1) = n;
        Z.dim(2) = m;
        if (n_X==1) & is(X,'lpcone') & (n_Y == m_Y) & (size(X.basis,1)==size(X.basis,2-1)) & isequal(X.basis*[0 1:size(X.basis,2)-1]',(1:size(X.basis,2)-1)')
            % special case to speed up x'*Q, Q square. typically
            % encountered in large-scale QPs
            Z.basis = [X.basis(:,1) Y.'];
        else
            Z.basis = kron(Y.',speye(n_X))*X.basis;
        end
        Z.conicinfo = [0 0];
        Z.extra.opname='';
        Z = addrightfactor(Z,Y);
        Z = clean(Z);

    case 1

        n_Y = Y.dim(1);
        m_Y = Y.dim(2);
        [n_X,m_X] = size(X);

        x_isscalar =  (n_X*m_X==1);
        y_isscalar =  (n_Y*m_Y==1);

        if ~x_isscalar
            if ((m_X~= n_Y & ~y_isscalar))
                error('Inner matrix dimensions must agree.')
            end
        end

        n = n_X;
        m = m_Y;
        Z = Y;

        % Special cases
        if x_isscalar
            if y_isscalar
                if X==0
                    Z = 0;
                    return
                else
                    Z.basis = Z.basis*X;
                    Z.conicinfo = [0 0];
                    Z.extra.opname='';
                    Z = addleftfactor(Z,X);
                    return
                end
            else
                Z.dim(1) = n_Y;
                Z.dim(2) = m_Y;
                try
                    Z.basis = sparse(X)*Y.basis;
                catch
                    % This works better when low on memory in some cases
                    [i,j,k] = find(Y.basis);
                    Z.basis = sparse(i,j,X*k,size(Y.basis,1),size(Y.basis,2));
                end
                Z.conicinfo = [0 0];
                Z.extra.opname='';
                Z = addleftfactor(Z,X);
                Z = clean(Z);
                return
            end
        elseif y_isscalar
            Z.dim(1) = n_X;
            Z.dim(2) = m_X;
            Z.basis = X(:)*Y.basis;
            Z = addleftfactor(Z,X);
            Z = addrightfactor(Z,speye(size(X,2)));
            Z = clean(Z);
            return
        end

        if m_Y==1
            if issparse(X)
                Z.basis = X*Y.basis;
            else
                if (size(X,1) > 100000) & isdiagonal(X)
                    try
                        Z.basis = bsxfun(@times,Y.basis,sparse(diag(X)));
                    catch
                        Z.basis = sparse(X)*Y.basis;
                    end
                else
                    Z.basis = sparse(X)*Y.basis;
                end
            end
        else
            try
                speyemy = speye(m_Y);
                kronX = kron(speyemy,X);
                Z.basis = kronX*Y.basis;
            catch
                disp('Multiplication of SDPVAR object caused memory error');
                disp('Continuing using unvectorized version which is extremely slow');
                Z.basis = [];
                for i = 1:size(Y.basis,2);
                    dummy = X*reshape(Y.basis(:,i),Y.dim(1),Y.dim(2));
                    Z.basis = [Z.basis dummy(:)];
                end
            end
        end
        Z.dim(1) = n;
        Z.dim(2) = m;
        Z.conicinfo = [0 0];
        Z.extra.opname='';
        Z = addleftfactor(Z,X);
        Z = clean(Z);

    otherwise
        error('Logical error in mtimes. Report bug')
end



function Z=clean(X)
temp = any(X.basis,1);
temp = temp(2:end);
index = find(temp);
if ~isempty(index)
    Z = X;
    if length(index)~=length(Z.lmi_variables)
        Z.basis = Z.basis(:,[1 1+index]);
        Z.lmi_variables = Z.lmi_variables(index);
    end
else
    Z = full(reshape(X.basis(:,1),X.dim(1),X.dim(2)));
end



function Z = fix_variable_order(Z)
% Fucked up order (lmi_variables should be sorted)
if any(diff(Z.lmi_variables)<0)
    [i,j]=sort(Z.lmi_variables);
    Z.basis = [Z.basis(:,1) Z.basis(:,j+1)];
    Z.lmi_variables = Z.lmi_variables(j);
end

[un_Z_vars2] = uniquestripped(Z.lmi_variables);
if length(un_Z_vars2) < length(Z.lmi_variables)
    [un_Z_vars,hh,jj] = unique(Z.lmi_variables);
    if length(Z.lmi_variables) ~=length(un_Z_vars)
        Z.basis = Z.basis*sparse([1 1+jj],[1 1+(1:length(jj))],ones(1,1+length(jj)))';
        Z.lmi_variables = un_Z_vars;
    end
end

function Z = super_fast_quadratic_multiplication(X,Y,mt,oldvariabletype,mt_hash,hash);

Q = X.basis(:,2:end);
R = Y.basis(:,2:end);

Q = (Q.')*R;
Q = Q + Q.' - diag(diag(Q));


if nnz(Q-diag(diag(Q)))==0
    % Special case, only quadratic terms
    % Exploit this!
    n = length(X.lmi_variables);
    new_mt = sparse(1:n,X.lmi_variables,2*ones(n,1),n,size(mt,2));
    newvariabletype = ones(n,1)*2;
    Q = diag(Q);Q = Q(:)';
else
    
    indicies = find(tril(ones(length(Q))));
    Q = Q(indicies);
    Q = Q(:).';
    
    n = length(X.lmi_variables);
    V = mt(X.lmi_variables,:);
    if 1
        m1 = kron((1:n)',ones(n,1));
        m2 = kron(ones(n,1),(1:n)');
        r = reshape(1:n^2,n,n);
        r = r(find(tril(r)));
        m1 = m1(r);
        m2 = m2(r);
        VV = V';
        VV = VV(:,m1) + VV(:,m2);
        new_mt = VV';
    else
        new_mt = kron(V,ones(n,1)) + kron(ones(n,1),V);
        r = reshape(1:n^2,n,n);
        new_mt = new_mt(r(find(tril(r))),:);
    end
    newvariabletype = max((new_mt),[],2);
end

yalmip('setmonomtable',[mt;new_mt],[oldvariabletype newvariabletype'],[mt_hash;new_mt*hash],hash);
Z = X;
varbase = [(X.basis(:,1).')*Y.basis(:,2:end)+(Y.basis(:,1).')*X.basis(:,2:end) Q];
Z.basis = [(X.basis(:,1).')*Y.basis(:,1) varbase(find(varbase))];
Z.lmi_variables = [X.lmi_variables size(mt,1) + (1:length(Q))];
Z.lmi_variables = Z.lmi_variables(find(varbase));
Z.dim(1) = 1;
Z.dim(2) = 1;
Z.conicinfo = [0 0];
Z.extra.opname='';


function Z = check_for_special_case(Y,X)
% X*Y = X*log(?)
args = yalmip('getarguments',Y);
args = args.arg{1};
if isequal(X,args)
    Z = -entropy(X);
    return
else
    if isequal(getbase(args),[0 1])
        mt = yalmip('monomtable');
        v = mt(getvariables(args),:);
        vb = v(find(v));
        if v(getvariables(X))==1 & min(vb)==-1 & max(vb)==1
            Z = plog([X;recover(find(v==-1))]);
        else
            Z = [];
        end
    else
        Z = [];
    end
end

function yes = isdiagonal(X)

yes = 0;
if size(X,1) == size(X,2)
    [i,j] = find(X);
    if all(i==j)
        yes = 1;
    end
end


