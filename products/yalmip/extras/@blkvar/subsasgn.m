function X = subsasgn(X,I,Y)
%SUBASGN (overloaded)

% Author Johan L�fberg 
% $Id: subsasgn.m,v 1.1 2005-05-25 12:15:04 joloef Exp $   

try
    if strcmp('()',I.type)
        X_is_spdvar = isa(X,'sdpvar');
        Y_is_spdvar = isa(Y,'sdpvar');
        if any(I.subs{1} <=0)
            error('Index into matrix is negative or zero.');
        end
        i = I.subs{1};
        j = I.subs{2};
        X.blocks{i,j} = Y;
        
    else
        error('Reference type not supported');
    end
    
catch
    error(lasterr)
end

