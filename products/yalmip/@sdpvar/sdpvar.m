function sys = sdpvar(varargin)
%SDPVAR Create symbolic decision variable
%
%   You can create a sdpvar variable by:
%     X = SDPVAR(n)               Symmetric nxn matrix
%     X = SDPVAR(n,n)             Symmetric nxn matrix
%     X = SDPVAR(n,m)             Full nxm matrix (n~=m)
%
%   Definition of multiple scalars can be simplified
%     SDPVAR x y z w
%
%   The parametrizations supported are
%     X = SDPVAR(n,n,'full')      Full nxn matrix
%     X = SDPVAR(n,n,'symmetric') Symmetric nxn matrix
%     X = SDPVAR(n,n,'diagonal')  Diagonal matrix
%     X = SDPVAR(n,n,'toeplitz')  Symmetric Toeplitz
%     X = SDPVAR(n,n,'hankel')    Unsymmetric Hankel (zero below the first anti-diagonal)
%     X = SDPVAR(n,n,'rhankel')   Symmetric Hankel
%     X = SDPVAR(n,n,'skew')      Skew-symmetric
%     X = SDPVAR(n,n,'diagonal')  Diagonal
%
%   The letters 'sy','f','ha', 't' and 'sk' are searched for in the third argument
%   hence sdpvar(n,n,'toeplitz') gives the same result as sdpvar(n,n,'t')
%
%   Only square Toeplitz and Hankel matries are supported
%
%   A scalar is defined as a 1x1 matrix
%
%   Higher-dimensional matrices are also supported, although this currently
%   is an experimental feature with limited use. The type flag applies to
%   the lowest level slice.
%
%     X = SDPVAR(n,n,n,'full')      Full nxnxn matrix
%
%   In addition to the matrix type, a fourth argument
%   can be used to obtain a complex matrix. All the
%   matrix types above apply to a complex matrix, and
%   in addition a Hermitian type is added
%
%     X = SDPVAR(n,n,'hermitian','complex') Complex Hermitian nxn matrix (X=X'=conj(X.'))
%
%   The other types are obtained as above
%     X = SDPVAR(n,n,'symmetric','complex') Complex symmetric nxn matrix (X=X.')
%     X = SDPVAR(n,n,'full','complex')      Complex full nxn matrix
%     ... and the same for Toeplitz, Hankel and skew-symmetric
%
%   See also INTVAR, BINVAR, methods('sdpvar'), SEE

% Author Johan L�fberg
% $Id: sdpvar.m,v 1.58 2010-02-25 11:00:23 joloef Exp $

superiorto('double');
try
    superiorto('intval');
catch
end
if nargin==0
    sys = sdpvar(1,1);
    return
end

if isstruct(varargin{1})
    sys = class(varargin{1},'sdpvar');
    return
end

%if nargin == 1

% To speed up dualization, we keep track of primal SDP cones
% [0 0] :  Nothing known (cleared in some operator, or none-cone to start with)
% [1 0] :  Primal cone
% [1 1] :  Primal cone + DOUBLE
% [1 2 x] :  Primal cone + SDPVAR
% [-1 1] : -Primal cone + DOUBLE
% [-1 2 x] : -Primal cone + SDPVAR

conicinfo = [0 0];

if ischar(varargin{1})
    switch varargin{1}
        case 'clear'
            disp('Obsolete comand');
            return
        case 'nvars'
            sys = yalmip('nvars');%THIS IS OBSAOLETE AND SHOULD NOT BE USED
            return
        otherwise
            n = length(varargin);
            varnames = varargin;
            for k = 1:n
                varcmd{k}='(1,1)';
                lp=findstr(varargin{k},'(');
                rp=findstr(varargin{k},')');
                if isempty(lp) & isempty(rp)
                    if ~isvarname(varargin{k})
                        error('Not a valid variable name.')
                    end
                else
                    if (~isempty(lp))&(~isempty(rp))
                        if min(lp)<max(rp)
                            varnames{k} = varargin{k}(1:lp-1);
                            varcmd{k}=varargin{k}(lp:rp);
                        else
                            error('Not a valid variable name.')
                        end
                    else
                        error('Not a valid variable name.')
                    end
                end
            end
            for k = 1:n
                if isequal(varnames{k},'i') | isequal(varnames{k},'j')
                    if length(dbstack) == 1
                        assignin('caller',varnames{k},eval(['sdpvar' varcmd{k}]));
                    else
                        error(['Due to a bug in MATLAB, use ' varnames{k} ' = sdpvar' varcmd{k} ' instead.']);
                    end
                else
                    assignin('caller',varnames{k},eval(['sdpvar' varcmd{k}]));
                end
            end
            return
    end
end

% *************************************************************************
% Maybe new NDSDPVAR syntax
% *************************************************************************
if nargin > 2 & isa(varargin{3},'double') & ~isempty(varargin{3})
    sys = ndsdpvar(varargin{:});
    return
end


% Supported matrix types
% - symm
% - full
% - skew
% - hank
% - toep
switch nargin
    case 1 %Bug in MATLAB 5.3!! sdpvar called from horzcat!!!!????
        if isempty(varargin{1})
            sys = varargin{1};
            return
        end
        if isa(varargin{1},'sdpvar')
            sys = varargin{1};
            sys.typeflag = 0;
            return
        end
        n = varargin{1};
        m = varargin{1};
        if sum(n.*m)==0
            sys = zeros(n,m);
            return
        end
        if (n==m)
            matrix_type = 'symmetric';
            nvar = sum(n.*(n+1)/2);
            conicinfo = [1 0];
        else
            matrix_type = 'full';
            nvar = sum(n.*m);
        end
    case 2
        n = varargin{1};
        m = varargin{2};
        if length(n)~=length(m)
            error('The dimensions must have the same lengths')
        end
        if sum(n.*m)==0
            sys = zeros(n,m);
            return
        end
        if (n==m)
            matrix_type = 'symmetric';
            nvar = sum(n.*(n+1)/2);
            conicinfo = [1 0];
        else
            matrix_type = 'full';
            nvar = sum(n.*m);
        end
    case {3,4}
        n = varargin{1};
        m = varargin{2};
        if sum(n.*m)==0
            sys = zeros(n,m);
            return
        end

        % Check for complex or real
        if (nargin == 4)
            if isempty(varargin{4})
                varargin{4} = 'real';
            else
                if ~ischar(varargin{4})
                    help sdpvar
                    error('Fourth argument should be ''complex'' or ''real''')
                end
            end
            index_cmrl = strmatch(varargin{4},{'real','complex'});
            if isempty(index_cmrl)
                error('Fourth argument should be ''complex'' or ''real''. See help above')
            end
        else
            if ~ischar(varargin{3})
                help sdpvar
                error('Third argument should be ''symmetric'', ''full'', ''hermitian'',...See help above')
            end
            index_cmrl = 1;
        end;

        if isempty(varargin{3})
            if n==m
                index_type = 7; %Default symmetric
            else
                index_type = 4;
            end
        else
            if ~isempty(strmatch(varargin{3},{'complex','real'}))
                % User had third argument as complex or real
                error(['Third argument should be ''symmetric'', ''full'', ''toeplitz''... Maybe you meant sdpvar(n,n,''full'',''' varargin{3} ''')'])
            end
            index_type = strmatch(varargin{3},{'toeplitz','hankel','symmetric','full','rhankel','skew','hermitian','diagonal'});
        end

        if isempty(index_type)
            error(['Matrix type "' varargin{3} '" not supported'])
        else
            switch index_type+100*(index_cmrl-1)
                case 1
                    if n~=m
                        error('Toeplitz matrix must be square')
                    else
                        matrix_type = 'toeplitz';
                        nvar = n;
                    end

                case 2
                    if n~=m
                        error('Hankel matrix must be square')
                    else
                        matrix_type = 'hankel';
                        nvar = n;
                    end

                case 3
                    if n~=m
                        error('Symmetric matrix must be square')
                    else
                        matrix_type = 'symmetric';
                        nvar = sum(n.*(n+1)/2);
                    end

                case 4
                    matrix_type = 'full';
                    nvar = sum(n.*m);
                    if nvar==1
                        matrix_type = 'symmetric';
                    end

                case 5
                    if n~=m
                        error('Hankel matrix must be square')
                    else
                        matrix_type = 'rhankel';
                        nvar = 2*n-1;
                    end

                case 6
                    if n~=m
                        error('Skew symmetric matrix must be square')
                    else
                        matrix_type = 'skew';
                        nvar = (n*(n+1)/2)-n;
                    end

                case 7
                    if n~=m
                        error('Symmetric matrix must be square')
                    else
                        matrix_type = 'symmetric';
                        nvar = n*(n+1)/2;
                    end

                    
                case 8
                    if n~=m
                        error('Diagonal matrix must be square')
                    else
                        matrix_type = 'diagonal';
                        nvar = n;
                    end

                case 101
                    if n~=m
                        error('Toeplitz matrix must be square')
                    else
                        matrix_type = 'toeplitz complex';
                        nvar = 2*n;
                    end

                case 102
                    if n~=m
                        error('Hankel matrix must be square')
                    else
                        matrix_type = 'hankel complex';
                        nvar = (2*n);
                    end

                case 103
                    if n~=m
                        error('Symmetric matrix must be square')
                    else
                        matrix_type = 'symm complex';
                        nvar = 2*n*(n+1)/2;
                    end

                case 104
                    matrix_type = 'full complex';
                    nvar = 2*n*m;
                    if nvar==1
                        matrix_type = 'symm complex';
                    end

                case 105
                    if n~=m
                        error('Hankel matrix must be square')
                    else
                        matrix_type = 'rhankel complex';
                        nvar = 2*(2*n-1);
                    end

                case 106
                    if n~=m
                        error('Skew symmetric matrix must be square')
                    else
                        matrix_type = 'skew complex';
                        nvar = 2*((n*(n+1)/2)-n);
                    end

                case 107
                    if n~=m
                        error('Hermitian matrix must be square')
                    else
                        matrix_type = 'hermitian complex';
                        nvar = n*(n+1)/2+(n*(n+1)/2-n);
                    end

                otherwise
                    error('Bug! Report!');
            end

        end

    case 5 % Fast version for internal use
        sys.basis = varargin{5};
        sys.lmi_variables=varargin{4};
        sys.dim(1) = varargin{1};
        sys.dim(2) = varargin{2};
        sys.typeflag = 0;
        sys.savedata = [];
        sys.extra = [];
        sys.extra.expanded = [];
        sys.extra.opname = '';
        sys.conicinfo = 0;
        sys.originalbasis = 'unknown';
        sys.leftfactors{1} = speye(sys.dim(1));
        sys.rightfactors{1} = speye(sys.dim(2));
        sys.midfactors = [];
        % Find zero-variables
        constants = find(sys.lmi_variables==0);
        if ~isempty(constants);
            sys.lmi_variables(constants)=[];
            sys.basis(:,1) = sys.basis(:,1) + sum(sys.basis(:,1+constants),2);
            sys.basis(:,1+constants)=[];
        end
        if isempty(sys.lmi_variables)
            sys = full(reshape(sys.basis(:,1),sys.dim(1),sys.dim(2)));
        else
            sys = class(sys,'sdpvar');
        end
        sys.midfactors{1} = sys;
        return
    case 6 % Fast version for internal use
        sys.basis = varargin{5};
        sys.lmi_variables=varargin{4};
        sys.dim(1) = varargin{1};
        sys.dim(2) = varargin{2};
        sys.typeflag = varargin{6};
        sys.savedata = [];
        sys.extra = [];
        sys.extra.expanded = [];
        sys.extra.opname = '';
        sys.conicinfo = 0;
        sys.originalbasis = 'unknown';
        sys.leftfactors{1} = speye(sys.dim(1));
        sys.rightfactors{1} = speye(sys.dim(2));
        sys.midfactors = [];
        % Find zero-variables
        constants = find(sys.lmi_variables==0);
        if ~isempty(constants);
            sys.lmi_variables(constants)=[];
            sys.basis(:,1) = sys.basis(:,1) + sum(sys.basis(:,1+constants),2);
            sys.basis(:,1+constants)=[];
        end
        if isempty(sys.lmi_variables)
            sys = full(reshape(sys.basis(:,1),sys.dim(1),sys.dim(2)));
        else
            sys = class(sys,'sdpvar');
        end
        sys.midfactors{1} = sys;
        return
    case 7 % Fast version for internal use
        sys.basis = varargin{5};
        sys.lmi_variables=varargin{4};
        sys.dim(1) = varargin{1};
        sys.dim(2) = varargin{2};
        sys.typeflag = varargin{6};
        sys.savedata = [];
        sys.extra = varargin{7};
        sys.extra.expanded = [];
        sys.extra.opname = '';
        sys.conicinfo = varargin{7};
        sys.originalbasis = 'unknown';
        sys.leftfactors{1} =  speye(sys.dim(2));
        sys.rightfactors{1} =  speye(sys.dim(2));
        sys.midfactors = [];
        % Find zero-variables
        constants = find(sys.lmi_variables==0);
        if ~isempty(constants);
            sys.lmi_variables(constants)=[];
            sys.basis(:,1) = sys.basis(:,1) + sum(sys.basis(:,1+constants),2);
            sys.basis(:,1+constants)=[];
        end
        if isempty(sys.lmi_variables)
            sys = full(reshape(sys.basis(:,1),sys.dim(1),sys.dim(2)));
        else
            sys = class(sys,'sdpvar');
        end
        sys.midfactors{1} = sys;
        return

    otherwise
        error('Wrong number of arguments in sdpvar creation');
end

if isempty(n) | isempty(m)
    error('Size must be integer valued')
end;
if ~((abs((n-ceil(n)))+ abs((m-ceil(m))))==0)
    error('Size must be integer valued')
end

[mt,variabletype,hashed_monoms,current_hash] = yalmip('monomtable');
lmi_variables = (1:nvar)+size(mt,1);

for blk = 1:length(n)
    switch matrix_type

        case 'full'
            basis{blk} = [spalloc(n(blk)*m(blk),1,0) speye(n(blk)*m(blk))];%speye(nvar)];

        case 'full complex'
            basis = [spalloc(n*m,1,0) speye(nvar/2) speye(nvar/2)*sqrt(-1)];

        case 'symmetric'
            if 0
                basis = spalloc(n^2,1+nvar,n^2);
                l = 2;
                an_empty = spalloc(n,n,2);
                for i=1:n
                    temp = an_empty;
                    temp(i,i)=1;
                    basis(:,l)=temp(:);
                    l = l+1;
                    for j=i+1:n,
                        temp = an_empty;
                        temp(i,j)=1;
                        temp(j,i)=1;
                        basis(:,l)=temp(:);
                        l = l+1;
                    end
                end
            else
                % Hrm...fast but completely f*d up

                Y = reshape(1:n(blk)^2,n(blk),n(blk));
                Y = tril(Y);
                Y = (Y+Y')-diag(sparse(diag(Y)));
                [uu,oo,pp] = unique(Y(:));
                if 1
                    basis{blk} = sparse(1:n(blk)^2,pp+1,1);
                else
                    basis{blk} = lazybasis(n^2,1+(n*(n+1)/2),1:n(blk)^2,pp+1,ones(n(blk)^2,1));
                end

            end

        case 'symm complex'
            basis = spalloc(n^2,1+nvar,2);
            l = 2;
            an_empty = spalloc(n,n,2);
            for i=1:n
                temp = an_empty;
                temp(i,i)=1;
                basis(:,l)=temp(:);
                l = l+1;
                for j=i+1:n,
                    temp = an_empty;
                    temp(i,j)=1;
                    temp(j,i)=1;
                    basis(:,l)=temp(:);
                    l = l+1;
                end
            end
            for i=1:n
                temp = an_empty;
                temp(i,i)=sqrt(-1);
                basis(:,l)=temp(:);
                l = l+1;
                for j=i+1:n,
                    temp = an_empty;
                    temp(i,j)=sqrt(-1);
                    temp(j,i)=sqrt(-1);
                    basis(:,l)=temp(:);
                    l = l+1;
                end
            end

        case 'hermitian complex'
            basis = spalloc(n^2,1+nvar,2);
            l = 2;
            an_empty = spalloc(n,n,2);
            for i=1:n
                temp = an_empty;
                temp(i,i)=1;
                basis(:,l)=temp(:);
                l = l+1;
                for j=i+1:n,
                    temp = an_empty;
                    temp(i,j)=1;
                    temp(j,i)=1;
                    basis(:,l)=temp(:);
                    l = l+1;
                end
            end
            for i=1:n
                for j=i+1:n,
                    temp = an_empty;
                    temp(i,j)=sqrt(-1);
                    temp(j,i)=-sqrt(-1);
                    basis(:,l)=temp(:);
                    l = l+1;
                end
            end

        case 'skew'
            basis = spalloc(n^2,1+nvar,2);
            l = 2;
            an_empty = spalloc(n,n,2);
            for i=1:n
                for j=i+1:n,
                    temp = an_empty;
                    temp(i,j)=1;
                    temp(j,i)=-1;
                    basis(:,l)=temp(:);
                    l = l+1;
                end
            end

        case 'skew complex'
            basis = spalloc(n^2,1+nvar,2);
            l = 2;
            an_empty = spalloc(n,n,2);
            for i=1:n
                for j=i+1:n,
                    temp = an_empty;
                    temp(i,j)=1;
                    temp(j,i)=-1;
                    basis(:,l)=temp(:);
                    l = l+1;
                end
            end
            for i=1:n
                for j=i+1:n,
                    temp = an_empty;
                    temp(i,j)=sqrt(-1);
                    temp(j,i)=-sqrt(-1);
                    basis(:,l)=temp(:);
                    l = l+1;
                end
            end

        case 'toeplitz'
            basis = [spalloc(n(blk)*1,1,0) speye(n(blk)*1)];
%            basis = spalloc(n^2,1+nvar,2);
%            an_empty = spalloc(n,1,1);
%            for i=1:n,
%                v = an_empty;
%                v(i)=1;
%                temp = sparse(toeplitz(v));
%                basis(:,i+1) = temp(:);
%            end

            % Notice, complex Toeplitz not Hermitian
        case 'toeplitz complex'
            basis = spalloc(n^2,1+nvar,2);
            an_empty = spalloc(n,1,1);
            for i=1:n,
                v = an_empty;
                v(i)=1;
                temp = sparse(toeplitz(v));
                basis(:,i+1) = temp(:);
            end
            for i=1:n,
                v = an_empty;
                v(i)=sqrt(-1);
                temp = sparse(toeplitz(v));
                basis(:,n+i+1) = temp(:);
            end

        case 'hankel'
            % Create a vector. We will hankelize it later
            basis = [spalloc(n(blk)*1,1,0) speye(n(blk)*1)];
%            basis = spalloc(n^2,1+nvar,2);
%            an_empty = spalloc(n,1,1);
%            for i=1:n,
%               v = an_empty;
%               v(i)=1;
%               temp = sparse(hankel(v));
%               basis(:,i+1) = temp(:);
%           end

        case 'diagonal'
            j = 2:n+1;
            i = 1:n+1:n^2;
            basis = sparse(i,j,ones(length(i),1),n^2,1+n);

        case 'hankel complex'
            basis = spalloc(n^2,1+nvar,2);
            an_empty = spalloc(n,1,1);
            for i=1:n,
                v = an_empty;
                v(i)=1;
                temp = sparse(hankel(v));
                basis(:,i+1) = temp(:);
            end
            for i=1:n,
                v = an_empty;
                v(i)=sqrt(-1);
                temp = sparse(hankel(v));
                basis(:,n+i+1) = temp(:);
            end

        case 'rhankel'
            basis = spalloc(n^2,1+nvar,2);
            an_empty = spalloc(2*n-1,1,1);
            for i=1:nvar,
                v = an_empty;
                v(i)=1;
                temp = sparse(hankel(v(1:n),[v(n);v(n+1:2*n-1)]));
                basis(:,i+1) = temp(:);
            end

        case 'rhankel complex'
            basis = spalloc(n^2,1+nvar,2);
            an_empty = spalloc(2*n-1,1,1);
            for i=1:nvar/2,
                v = an_empty;
                v(i)=1;
                temp = sparse(hankel(v(1:n),[v(n);v(n+1:2*n-1)]));
                basis(:,i+1) = temp(:);
            end
            for i=1:nvar/2,
                v = an_empty;
                v(i)=sqrt(-1);
                temp = sparse(hankel(v(1:n),[v(n);v(n+1:2*n-1)]));
                basis(:,nvar/2+i+1) = temp(:);
            end

        otherwise
            error('Bug! Report')
    end

end

% Update monomtable and pre-calculated variable type
n_mt = size(mt,1);
m_mt = size(mt,2);
newmt = [];
if min(lmi_variables)>m_mt % New variables
    if size(mt,1)~=size(mt,2)
        mt(size(mt,1),size(mt,1))=0;
    end
    % This was faster before. However in recent versions of matlab, there
    % is a compiled version of blkdiag available
    % fill=spalloc(size(mt,1),length(lmi_variables),0);   
    % mt=[mt fill;fill' speye(length(lmi_variables))]; 
    if isempty(mt)        
        mt = speye(length(lmi_variables));
        newmt = mt;
    else
        newmt = speye(length(lmi_variables));
        mt=blkdiag(mt,speye(length(lmi_variables)));
    end
else
    mt(lmi_variables,lmi_variables) = speye(length(lmi_variables));
end
variabletype(1,size(mt,1)) = 0;
if ~isempty(newmt)
    new_hash = 3*rand_hash(size(mt,2),size(newmt,2),1);
    hashed_monoms = [hashed_monoms;newmt*new_hash];
    current_hash = [current_hash;new_hash];
    yalmip('setmonomtable',mt,variabletype,hashed_monoms,current_hash);
else 
    yalmip('setmonomtable',mt,variabletype);
end
% Create an object
if isa(basis,'cell')
    top = 1;
    for blk = 1:length(n)
        sys{blk}.basis=basis{blk};
        nn = size(sys{blk}.basis,2)-1;
        sys{blk}.lmi_variables = lmi_variables(top:top+nn-1);
        top = top + nn;
        sys{blk}.dim(1) = n(blk);
        sys{blk}.dim(2) = m(blk);
        sys{blk}.typeflag = 0;
        sys{blk}.savedata = [];
        sys{blk}.extra = [];
        sys{blk}.extra.expanded = [];
        sys{blk}.extra.opname = '';
        sys{blk}.conicinfo = conicinfo;
        sys{blk}.originalbasis = matrix_type;
        sys{blk}.leftfactors{1} = speye(n(blk));
        sys{blk}.rightfactors{1} = speye(m(blk));
        sys{blk}.midfactors{1} = [];
        sys{blk} = class(sys{blk},'sdpvar');
        sys{blk}.midfactors{1} = sys{blk};
    end
    if length(n)==1
        sys = sys{1};
    end
else
    sys.basis=basis;
    sys.lmi_variables = lmi_variables;
    sys.dim(1) = n;
    sys.dim(2) = m;
    sys.typeflag = 0;
    sys.savedata = [];
    sys.extra = [];
    sys.extra.expanded = [];
    sys.extra.opname = '';
    sys.conicinfo = conicinfo;
    sys.originalbasis = matrix_type;
    sys.leftfactors{1} = speye(n);
    sys.rightfactors{1} = speye(m);
    sys.midfactors{1} = [];
    sys = class(sys,'sdpvar');
    sys.midfactors{1} = sys;
    if ~isreal(basis)
        % Add internal information about complex pairs
        complex_elements = find(any(imag(basis),2));
        complex_pairs = [];
        for i = 1:length(complex_elements)
            complex_pairs = [complex_pairs;lmi_variables(find(basis(complex_elements(i),:))-1)];
        end
        complex_pairs = uniquesafe(complex_pairs,'rows');
        yalmip('addcomplexpair',complex_pairs);
    end
    if isequal(matrix_type,'hankel')
        % To speed up generation, we have just created a vector, and now
        % hankelize it
        sys.dim(2) = 1;
        sys = hankel(sys);
        sys.leftfactors{1} = eye(sys.dim(1));
        sys.midfactors{1} = sys;
        sys.rightfactors{1} = eye(sys.dim(1));
    elseif isequal(matrix_type,'toeplitz')
        sys.dim(2) = 1;
        sys = toeplitz(sys);
        sys.leftfactors{1} = eye(sys.dim(1));
        sys.midfactors{1} = sys;
        sys.rightfactors{1} = eye(sys.dim(1));
    end
end

% Typeflags
% 0 Standard variable
% 1 Inequality (LMI)
% 2 Inequality (element)
% 3 Equality
% 4 Cone
% 5 norm object (osbolete)
% 6 logdet object
% 8 KYP object

function r = rand_hash(k,n,m);
try
    s = rng;
    rng(k);
   % rand('state',k)
    r = rand(n,m);
    rng(s);
catch
    s = rand('state');
    rand('state',k)
    r = rand(n,m);
    rand('state',s);
end