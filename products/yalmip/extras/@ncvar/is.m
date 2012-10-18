function YESNO = is(X,property,additional)
%IS Check property of variable.
%   d = IS(x,property) returns 1 if 'property' holds
%
%   Properties possible to test are: 'real', 'symmetric', 'hermitian',
%   'scalar', 'linear', 'bilinear','quadratic','sigmonial', 'homogeneous', 'integer', 'binary'

% Author Johan L�fberg 
% $Id: is.m,v 1.2 2009-09-29 12:02:40 joloef Exp $   

switch property
    case 'logic'
        YESNO = X.typeflag==12;
    case 'binary'
        YESNO = any(ismember(depends(X),yalmip('binvariables')));
    case 'integer'
        YESNO = any(ismember(depends(X),yalmip('intvariables')));
    case 'real'
        YESNO = isreal(X);
    case 'complex'
        YESNO = ~isreal(X.basis);
    case 'symmetric'
        YESNO = issymmetric(X);
    case 'hermitian'
        YESNO = ishermitian(X);
    case 'scalar'
        YESNO = prod(X.dim)==1;
    case 'compound'
        YESNO = any(ismember(getvariables(X),yalmip('extvariables')));       
    case 'linear'
        variabletype = yalmip('variabletype');
        variabletype = variabletype(X.lmi_variables);       
        YESNO = ~any(variabletype);              
    case 'bilinear'
        variabletype = yalmip('variabletype');
        variabletype = variabletype(X.lmi_variables);                
        YESNO  = all(variabletype<=1);
     case 'quadratic'
         variabletype = yalmip('variabletype');
         variabletype = variabletype(X.lmi_variables);
         YESNO = all(variabletype<=2);
         
    case 'LBQS'
        % Fast code for use in display etc.
        % Checks linearity, bilinearity etc in one call.
        quadratic = 0;
        bilinear  = 0;
        linear    = 0;
        sigmonial = 0;
              
        variabletype = yalmip('variabletype');
        variabletype = variabletype(X.lmi_variables);
        
        linear    = all(variabletype==0);        
        bilinear  = all(variabletype<=1) & ~linear;        
        quadratic = all(variabletype<=2) & ~bilinear;
        sigmonial = any(variabletype==4);
        
        YESNO = full([linear bilinear quadratic sigmonial]);
         
         
         
    case 'lpcone'
          base = X.basis;
          YESNO = all(base(:,1)==0); % No constant
          base = base(:,2:end);
          YESNO = YESNO & all(sum(base,2)==1); 
          YESNO = YESNO & all(sum(base,1)==1);
          YESNO = YESNO & all(sum(base~=0,2)==1);
          YESNO = YESNO & all(sum(base~=0,1)==1);
          YESNO = full(YESNO);

    case 'shiftlpcone'
          base = X.basis;          
          base = base(:,2:end);
          YESNO = all(sum(base,2)==1); 
          YESNO = YESNO & all(sum(base,1)==1);
          YESNO = YESNO & all(sum(base~=0,2)==1);
          YESNO = YESNO & all(sum(base~=0,1)==1);
          YESNO = full(YESNO);
                    
    case 'sdpcone'
        if isequal(X.conicinfo,[1 0])
            YESNO = 1;
            return
        end
        base = X.basis;
        n = X.dim(1);
        YESNO = full(issymmetric(X) & nnz(base)==n*n & all(sum(base,2)==1) & all(base(:,1)==0)) & length(X.lmi_variables)==n*(n+1)/2 & isreal(base); 
        
    case 'shiftsdpcone'
        
        if isequal(X.conicinfo,[1 0])
            YESNO = 1;
            return
        elseif isequal(X.conicinfo,[1 1])
            YESNO = 1;
            return
        end
        
        
        base = X.basis;
        n = X.dim(1);
        base(:,1)=0;
        YESNO = full(issymmetric(X) & nnz(base)==n*n & all(sum(base,2)==1)) & length(X.lmi_variables)==n*(n+1)/2 & isreal(X);
        if YESNO
            % Possible case
            % FIX : Stupidly slow and complex
            [i,j,k] = find(base');
            Y = reshape(1:n^2,n,n);
            Y = tril(Y);
            Y = (Y+Y')-diag(sparse(diag(Y)));
            [uu,oo,pp] = unique(Y(:));
            YESNO = isequal(i,pp+1);
            %             YESNO = isequal(base,getbase(sdpvar(n,n)));
        end
        
    case 'socone'
        base = X.basis;
        n = X.dim(1);
        YESNO = X.dim(1)>1 & X.dim(2)==1 & length(X.lmi_variables)==n;
        if YESNO
            cb = base(:,1);
            vb = base(:,2:end);            
            YESNO = YESNO & (nnz(cb)==0) & (nnz(vb-speye(n))==0);
        end   
        
    case 'sigmonial'
          monomtable = yalmip('monomtable');
          monomtable = monomtable(getvariables(X),:);
          YESNO = any(find(any(0>monomtable,2) | any(monomtable-fix(monomtable),2)));   
          
    case 'general'
        evalvariables = yalmip('evalVariables');
        YESNO = ~isempty(intersect(getvariables(X),evalvariables));
        
    case 'nonlinear'
        YESNO = ~islinear(X);   
        
    case 'homogeneous'    
        [sqrList,CompressedList] = yalmip('nonlinearvariables');
        [LinearTerms,NonlinearVariables] = getvariables(X,'both');
        if isempty(NonlinearVariables)
            YESNO = nnz(getbasematrix(X,0))==0;
        else
            % No linear terms
            YESNO = isempty(LinearTerms);
            % No constant terms
            YESNO = YESNO & (nnz(getbasematrix(X,0))==0);
            % Largest degree+1
            maxdegree = sum(any(CompressedList(find(ismember(CompressedList,NonlinearVariables)),:),1));
            % All same degree
            YESNO = YESNO & all(all(CompressedList(find(ismember(CompressedList,NonlinearVariables)),2:maxdegree)>0));
        end
        
    case 'sos'
        YESNO = (X.typeflag==11);  
        
    case 'kyp'
        YESNO = (X.typeflag==9);
    case 'gkyp'
        YESNO = (X.typeflag==40);
        
    otherwise
        error('Wrong input argument.');
end

YESNO = full(YESNO);


