function [sys,values] = double(X,allextended,allevaluators,allStruct,mt,variabletype,solution,values)
%DOUBLE Returns current numerical value
%
% After solving an optimization problem, we can extract the current
% solution by applying double on a variable of interest
%
% xvalue = double(x) 
%
% If you have solved a multiple problems simultaneously by using a
% non-scalar objective function, you can select the solution by using a
% second argument
%
% xvalue = double(x,i)

% Author Johan L�fberg
% $Id: double.m,v 1.63 2008-06-10 14:47:59 joloef Exp $

% Normal users might use the second arguement in order to select solution
if nargin == 2 
    if prod(size(allextended))==1
        try
            selectsolution(allextended);
            sys = double(X);
            selectsolution(1);
            return
        catch            
            error(['Solution ' num2str(allextended) ' not available']);
        end
    else
            error(['Solution number should be a positive scalar']);
    end
end

% Definition of nonlinear variables
if nargin == 1
    [mt,variabletype] = yalmip('monomtable');
    solution = yalmip('getsolution');
end

lmi_variables = X.lmi_variables;
opt_variables = solution.variables;

nonlinears = lmi_variables(find(variabletype(X.lmi_variables)));

% FIXME: This code does not work
% if ~isempty(solution.values)
%     if max(lmi_variables) <= length(solution.values) & isempty(nonlinears)
%         if ~any(isnan(solution.values(lmi_variables(:))))
%             % Yihoo, we can do this really fast by
%             % re-using the old values
%             sys = X.basis*[1;solution.values(lmi_variables(:))];
%             if X.typeflag==10
%                 sys = eig(full(reshape(sys,X.dim(1),X.dim(2))));
%             else
%                 sys = full(reshape(sys,X.dim(1),X.dim(2)));
%             end
%             return
%         end
%     end
% end

% Okey, we could not do it really fast...

if nargin == 1
    % Definition of nonlinear variables
    allextended   = yalmip('extvariables');
    allevaluators = [];
    allStruct = yalmip('extstruct');
end

if isempty(nonlinears) & isempty(allextended) & all(ismembc(lmi_variables,solution.variables))

    % speed up code for simple linear case
    values = solution.values;
    if isempty(solution.values)
        values = sparse(solution.variables,ones(length(solution.variables),1),solution.optvar,size(mt,1),1);        
        yalmip('setvalues',values);
    else
        if any(isnan(solution.values(lmi_variables(:))))
            values = sparse(solution.variables,ones(length(solution.variables),1),solution.optvar,size(mt,1),1);
            yalmip('setvalues',values);
        end
    end

    sys = X.basis*[1;values(lmi_variables(:))];
    if X.typeflag==10
        sys = eig(full(reshape(sys,X.dim(1),X.dim(2))));
    else
        sys = full(reshape(sys,X.dim(1),X.dim(2)));
    end

    return
end

if nargin == 1
    % All double values
    values(size(mt,1),1)=nan;values(:)=nan;
    values(solution.variables) = solution.optvar;
    clear_these = allextended;
    if ~isempty(allStruct)
    if ~isempty(strfind([allStruct.fcn],'semivar'))
        for i = 1:length(allStruct)
            if strcmp(allStruct(i).fcn,'semivar')%isequal(allStruct(i).fcn,'semivar')
                clear_these = setdiff(clear_these,allextended(i));
            end
        end
    end
    end
    values(clear_these) = nan;    
end

% Evaluate the extended operators
if ~isempty(allextended)
    extended_variables = find(ismembc(X.lmi_variables,allextended));
    if ~isempty(extended_variables)
        for i = 1:length(extended_variables)
            extvar = lmi_variables(extended_variables(i));
            if isnan(values(extvar))
                extstruct = allStruct(find(X.lmi_variables(extended_variables(i)) == allextended));

                for k = 1:length(extstruct.arg)
                    if isa(extstruct.arg{k},'sdpvar')
                        [extstruct.arg{k},values] = double(extstruct.arg{k},allextended,allevaluators,allStruct,mt,variabletype,solution,values);                        
                    elseif  isa(extstruct.arg{k},'constraint')
                        extstruct.arg{k} = double(extstruct.arg{k});
                    end
                end

                switch extstruct.fcn

                    case 'sort'
                        [w,loc] = sort(extstruct.arg{1});
                        if extstruct.arg{2}.isthisloc
                            val = loc(extstruct.arg{2}.i);
                        else
                            val = w(extstruct.arg{2}.i);
                        end

                    case 'semivar'
                        % A bit messy, since it not really is a nonlinear
                        % operator. semivar(1) does not return 1, but a new
                        % semivar variable...
                        val = values(getvariables(extstruct.var));

                    case 'geomean' % Not 100% MATLAB consistent (Hermitian case differ)
                        val = extstruct.arg{1};
                        if ~any(any(isnan(val)))
                            [n,m] = size(val);
                            if n == m
                                if ishermitian(val)
                                    val = max(0,real(det(val)))^(1/n);
                                else
                                    val = geomean(val);
                                end
                            else
                                val = geomean(val);
                            end
                        else
                            val = nan;
                        end

                    case 'pwf'
                        % Has to be placed here due to the case when
                        % all functions are double, since in this case,
                        % we cannot determine in pwf if we want the double or
                        % create a pw constant function...
                        n = length(extstruct.arg-1)/2;
                        i = 1;
                        val = nan;
                        while i<=n
                            if min(checkset(extstruct.arg{2*i}))>=0
                                val = extstruct.arg{2*i-1};
                                break
                            end
                            i = i + 1;
                        end
                
                    case 'or'
                        val = any([extstruct.arg{1:end-1}]);
                    case 'and'
                        val = all([extstruct.arg{1:end-1}]);
                    case 'xor'
                        val = nnz([extstruct.arg{1:end-1}]) == 1;
                    case 'abs'
                        try
                            % ABS has predefined binary appended to
                            % argument list
                            val = feval(extstruct.fcn,extstruct.arg{1:end-2});
                        catch
                            val = nan;
                        end

                    otherwise
                        try
                            val = feval(extstruct.fcn,extstruct.arg{1:end-1});
                        catch
                            val = nan;
                        end
                end
                values(extstruct.computes) = full(val);
            end
        end
    end
end

if ~isempty(nonlinears)
    mt_t = mt'; %Working columnwise is faster
    use_these = find(ismember(lmi_variables,nonlinears));
    all_extended_variables  = yalmip('extvariables');

    for i = use_these
        monom_i = mt_t(:,lmi_variables(i));
        used_in_monom = find(monom_i);
        
        if ~isempty(all_extended_variables)
            extended_variables = find(ismembc(used_in_monom,all_extended_variables));
            if ~isempty(extended_variables)
                for ii = 1:length(extended_variables)
                    extvar = used_in_monom(extended_variables(ii));
                    %extstruct = yalmip('extstruct',extvar);
                    %extstruct = getExtStruct(allStruct,extvar);
                    extstruct = allStruct(find([allStruct.computes] == extvar));
                    for k = 1:length(extstruct.arg)
                        if isa(extstruct.arg{k},'sdpvar')
                            extstruct.arg{k} = double(extstruct.arg{k});
                        end
                    end
                    
                    switch extstruct.fcn

                        case 'sort'
                            w = sort(extstruct.arg{1});
                            val = w(extstruct.arg{2});

                        case 'semivar'
                            val = values(getvariables(extstruct.var));

                        case 'geomean' % Not 100% MATLAB consistent (Hermitian case differ)
                            val = extstruct.arg{1};
                            if ~any(any(isnan(val)))
                                [n,m] = size(val);
                                if n == m
                                    if issymmetric(val)
                                        val = max(0,real(det(val)))^(1/n);
                                    else
                                        val = geomean(val);
                                    end
                                else
                                    val = geomean(val);
                                end
                            else
                                val = nan;
                            end

                        otherwise
                            val = feval(extstruct.fcn,extstruct.arg{1:end-1});

                    end
                    values(extstruct.computes) = full(val);
                end
            end
        end
        % This code is a bit shaky due to the 0^0 bug in linux 6.5
        %the_product = prod(values(used_in_monom).^monom_i(used_in_monom));
        the_product = 1;
        for j = 1:length(used_in_monom)
            the_product = the_product*values(used_in_monom(j))^monom_i(used_in_monom(j));
        end
        values(lmi_variables(i)) = the_product;
    end
end
sys = X.basis*[1;values(lmi_variables(:))];

if X.typeflag==10
    sys = eig(full(reshape(sys,X.dim(1),X.dim(2))));
else
    sys = full(reshape(sys,X.dim(1),X.dim(2)));
end


function extstruct = getExtStruct(allStruct,extvar)
found = 0;
extstruct = [];
i = 1;
while ~found & i <=length(allStruct)
    if extvar == getvariables(allStruct(i).var)
        found = 1;
        extstruct = allStruct(i);
    end
    i = i + 1;
end
