function y = eq(X,Y)
%EQ (overloaded)

% Author Johan L�fberg
% $Id: eq.m,v 1.1 2006-08-10 18:00:20 joloef Exp $

if isa(X,'blkvar')
    X = sdpvar(X);
end

if isa(Y,'blkvar')
    Y = sdpvar(Y);
end

try
    y = constraint(X,'==',Y);
catch
    error(lasterr)
end
