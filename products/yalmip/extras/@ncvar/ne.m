function F = ne(X,Y)
%NE (overloaded)
%
%    F = set(ne(x,y))
%
%   See also SDPVAR/AND, SDPVAR/OR, BINVAR, BINARY

% Author Johan L�fberg
% $Id: ne.m,v 1.1 2006-08-10 18:00:21 joloef Exp $

% Models NE using logic constraints

% bin1 = isa(X,'sdpvar') | isa(X,'double');
% bin2 = isa(Y,'sdpvar') | isa(Y,'double');
%
% if ~(bin1 & bin2)
%     error('Not equal can only be applied to integer data')
% end

if is(X,'binary') &  isa(Y,'double') & all((Y == round(Y)))
    zv = find((Y == 0));
    ov = find((Y == 1));
    lhs = 0;
    if ~isempty(zv)
        lhs = lhs + sum(extsubsref(X,zv));
    end
    if ~isempty(ov)
        lhs = lhs + sum(1-extsubsref(X,ov));
    end
    F = set(lhs >=1);
else
    F = set((X<=Y-0.5) | (X>=Y+0.5));
end