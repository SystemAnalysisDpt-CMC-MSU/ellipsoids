function varargout = recover(lmi_variables)
%RECOVER Create SDPVAR object using variable indicies

% Author Johan L�fberg
% $Id: recover.m,v 1.10 2009-10-13 10:52:39 joloef Exp $

if isempty(lmi_variables)
    varargout{1} = [];
else
    if isa(lmi_variables,'sdpvar') | isa(lmi_variables,'lmi') | isa(lmi_variables,'constraint')
        varargout{1} = flush(recover(depends(lmi_variables)));
    else
        n = length(lmi_variables);
        i=1:n;
        if nargout <= 1

            lmi_variables = lmi_variables(:)';
            basis = sparse(i,i+1,ones(n,1),n,n+1);
            if any(diff(lmi_variables)<0)
                [i,j]=sort(lmi_variables);
                basis = [basis(:,1) basis(:,j+1)];
                lmi_variables = lmi_variables(j);
            end

            [un_Z_vars2] = uniquestripped(lmi_variables);
            if length(un_Z_vars2) < length(lmi_variables)
                [un_Z_vars,hh,jj] = unique(lmi_variables);
                if length(lmi_variables) ~= length(un_Z_vars)
                    basis = basis*sparse([1 1+jj],[1 1+(1:length(jj))],ones(1,1+length(jj)))';
                    lmi_variables = un_Z_vars;
                end
            end

            varargout{1} = sdpvar(n,1,[],lmi_variables(:)',basis,0);
        else
            x = sdpvar(n,1,[],lmi_variables(:)',sparse(i,i+1,ones(n,1),n,n+1),0);
            for i = 1:length(lmi_variables)
                varargout{i} = flush(x(i));
            end
        end
    end
end