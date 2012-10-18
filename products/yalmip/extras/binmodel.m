function varargout = binmodel(varargin)
%BINMODEL  Converts nonlinear mixed binary expression to linear model
%
% [plinear1,..,plinearN,F] = BINMODEL(p1,...,pN,D) is used to convert
% nonlinear expressions involving a mixture of continuous and binary
% variables to the correponding linear model, using auxilliary variables
% and constraints to model nonlinearities
%
% The input arguments p are polynomial SDPVAR objects. If all involved
% variables are binary (defined using BINVAR), arbitrary polynomials can be
% linearized. 
%
% If an input p contains continuous variables, the continuous variables
% may only enter linearly (i.e. degree w.r.t continuous variables should
% be at most 1). More over, all continuous variables must be explicitly
% bounded in the SET object D.
%
% Example
%  binvar a b
%  sdpvar x y
%  [plinear1,plinear2,F] = binmodel(a^3+b,a*b);
%  [plinear1,plinear2,F] = binmodel(a^3*x+b*y,a*b*x, set(-2 <=[x y] <=2));
%
% See also BINARY, BINVAR, SOLVESDP

% Author Johan L�fberg
% $Id: binmodel.m,v 1.5 2007-06-16 10:33:41 joloef Exp $

all_linear = 1;
p = [];
n_var = 0;
Foriginal = set([]);
for i = 1:nargin
    switch class(varargin{i})
        case 'sdpvar'
            [n(i),m(i)] = size(varargin{i});
            p = [p;varargin{i}(:)];
            if degree(varargin{i}) > 1
                all_linear = 0;
            end
            n_var = n_var + 1;
        case 'lmi'  
            Foriginal = Foriginal + varargin{i};
          %  LU = getbounds(varargin{i});
          %  LU = extract_bounds_from_abs_operator(LU,yalmip('extstruct'),yalmip('extvariables'));    
          %  yalmip('setbounds',1:nv,LU(:,1),LU(:,2));
        otherwise
            error('Arguments should be SDPVAR or SET objects')
    end
end

if length(Foriginal)>0
    nv = yalmip('nvars');
    yalmip('setbounds',1:nv,repmat(-inf,nv,1),repmat(inf,nv,1));    
    LU = getbounds(Foriginal);    
    LU = extract_bounds_from_abs_operator(LU,yalmip('extstruct'),yalmip('extvariables'));               
    yalmip('setbounds',1:nv,LU(:,1),LU(:,2));
end

if all_linear
    varargout = varargin;
    return
end

plinear = p;
F = Foriginal;

% Get stuff
vars  = getvariables(p);
basis = getbase(p);
[mt,vt] = yalmip('monomtable');
allbinary = yalmip('binvariables');

% Fix data (monom table not guaranteed to be square)
if size(mt,1) > size(mt,2)
    mt(end,size(mt,1)) = 0;
end

non_binary = setdiff(1:size(mt,2),allbinary);
if any(sum(mt(vars,non_binary),2) >1)
    error('Expression has to be linear in the continuous variables')
end

% These are the original monomials
vecvar = recover(vars);

linear = find(vt(vars) == 0);
quadratic = find(vt(vars) == 2);
bilinear  = find(vt(vars) == 1);
polynomial  = find(vt(vars) == 3);

% replace x^2 with x (can only be binary expression, since we check for
% continuous nonlinearities above)
if ~isempty(quadratic)
    [ii,jj] = find(mt(vars(quadratic),:));
    z_quadratic = recover(jj);
else
    quadratic = [];
    z_quadratic = [];
end

% replace x*y with z, x>z, x>z, 1+z>x+y
if ~isempty(bilinear)
    z_bilinear = sdpvar(length(bilinear),1);
    [jj,ii] = find(mt(vars(bilinear),:)');
    xi = jj(1:2:end);
    yi = jj(2:2:end);
    x = recover(xi);
    y = recover(yi);

    if all(ismember(xi,allbinary)) & all(ismember(yi,allbinary))
        % fast case for binary*binary
        F = F + set(binary(z_bilinear)) + set(x >= z_bilinear) + set(y >= z_bilinear) + set(1+z_bilinear >= x + y) + set(0 <= z_bilinear <= 1);
    else
        for i = 1:length(bilinear)
            if ismember(xi(i),allbinary) & ismember(yi(i),allbinary)
                F = F + set(x(i) >= z_bilinear(i)) + set(y(i) >= z_bilinear(i)) + set(1+z_bilinear(i) >= x(i) + y(i)) + set(0 <= z_bilinear(i) <= 1);
            elseif ismember(xi(i),allbinary)
                F = F + binary_times_cont(x(i),y(i), z_bilinear(i));
            else
                F = F + binary_times_cont(y(i),x(i), z_bilinear(i));
            end
        end
    end
else
    bilinear = [];
    z_bilinear = [];
end

%general case a bit slower
if ~isempty(polynomial)
    z_polynomial = sdpvar(length(polynomial),1);
    xvar = [];
    yvar = [];
    for i = 1:length(z_polynomial)
        % Get the monomial powers, clear out the
        the_monom = mt(vars(polynomial(i)),:);
        if any(the_monom(non_binary))
            % Tricky case, x*polynomial(binary)
            % Start by first modeling the binary part
            the_binary_monom = the_monom;the_binary_monom(non_binary) = 0;
            [ii,jj] = find(the_binary_monom);
            x = recover(jj);
            F = F + set(x >= z_polynomial(i)) + set(length(x)-1+z_polynomial(i) > sum(x)) + set(0 <= z_polynomial(i) <= 1);
            % Now define the actual variable
            temp =  z_polynomial(i);z_polynomial(i) = sdpvar(1,1);
            the_real_monom = the_monom;the_real_monom(allbinary)=0;
            [ii,jj] = find(the_real_monom);
            x = recover(jj);
            F = F + binary_times_cont(temp,x,z_polynomial(i));
        else
            % simple case, just binary terms
            [ii,jj] = find(the_monom);
            x = recover(jj);
            F = F + set(x >= z_polynomial(i)) + set(length(x)-1+z_polynomial(i) >= sum(x)) + set(0 <= z_polynomial(i) <= 1);
        end
    end
else
    z_polynomial = [];
    polynomial = [];
end

% ii = [linear quadratic bilinear polynomial];
% jj = ones(length(ii),1);
% kk = [recover(vars(linear));z_quadratic;z_bilinear;z_polynomial];
% sparse([linear quadratic bilinear polynomial],1,[recover(vars(linear));z_quadratic;z_bilinear;z_polynomial])

ii = [linear quadratic bilinear polynomial];
jj = ones(length(ii),1);
kk = [recover(vars(linear));z_quadratic;z_bilinear;z_polynomial];
vecvar = sparse(ii(:),jj(:),kk(:));

% Recover the whole thing
plinear = basis*[1;vecvar];

% And now get the original sizes
top = 1;
for i = 1:n_var
    varargout{i} = reshape(plinear(top:top+n(i)*m(i)-1),n(i),m(i));
    top = top + n(i)*m(i);
end
varargout{end+1} = F;



function F = binary_times_cont(d,y, z)
[M,m,infbound] = derivebounds(y);
if infbound
    error('Some of your continuous variables are not explicitly bounded.')
end
F = set((1-d)*M >= y - z >= m*(1-d)) + set(d*m <= z <= d*M);
                
