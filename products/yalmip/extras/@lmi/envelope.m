function [E,P] = envelope(C,x)
%ENVELOPE Create linear approximation of envelope of nonlinear constraint
%
%     [E,P] = envelope(C,x)
%
% C: Constraint object involving nonlinear expresions
% x: Optional: The linear variables of interest (projection onto these will be performed)
% E: Constraint object representing the envelope approximation
% P: Optional: Polyhedral object representing E (MPT Toolbox object)
%
% Examples
%
% In order to derive the outer approximation in the original linear
% variables, the model has to be projected onto the linear variables
% This projetion based format requires MPT3
%   sdpvar x u
%   E = envelope([-1 <= x <= 1, u == x^3],[x;u]);
%   plot(E)
%   xx = (-1:0.01:1);hold on;plot(xx,xx.^3)
%
%   E = envelope([-1 <= x <= 1,x+sin(pi*x) <= u <= 4-x^2],[x;u]);
%   plot(E)
%   xx = (-1:0.01:1);hold on;plot(xx,xx+sin(pi*xx),xx,4-xx.^2)
%
% Alternatively, we can create a model which adds the outer approximation
% cuts for the envelopes of the nonlinear variables, but keep the nonlinear
% variables, and then plot the projection of the outer approximation,
% keeping in mind that we now have to relax the nonlinear variables (this
% is the model which thus would be used in a branch&bound scheme)
%   E = envelope([-1 <= x <= 1,x+sin(pi*x) <= u <= 4-x^2]);
%   plot(E,[x;u],[],[],sdpsettings('relax',1))
%   xx = (-1:0.01:1);hold on;plot(xx,xx+sin(pi*xx),xx,4-xx.^2)

% Author Johan L�fberg

[aux1,aux2,aux3,p] = export(C,[],sdpsettings('solver','bmibnb'));

if isempty(p)
    if ~isempty(aux3)
        aux3.info
    end
    error('Failed to export a model')
end

% Copied from bmibnb
p.high_monom_model=[];
p.originalModel = p;
p = presolveOneMagicRound(p);   
p = convert_sigmonial_to_sdpfun(p);
[p,changed] = convert_polynomial_to_quadratic(p);
p = presolveOneMagicRound(p);  
p = compile_nonlinear_table(p);

% Copied from solvelower
p_cut = addBilinearVariableCuts(p);
p_cut = addEvalVariableCuts(p_cut);
p_cut = addMonomialCuts(p_cut);

p_cut = mergeBoundsToModel(p_cut);
if nargin > 1
    % Now project onto the variables of interest
    for i = 1:length(x)
        xi(i) = find(getvariables(x(i)) == p.used_variables);
    end
    A = -p_cut.F_struc(:,2:end);
    b = p_cut.F_struc(:,1);
    
    Akeep = A(:,xi);
    A(:,xi)=[];
    
    A = [Akeep A];
    
    Ae = A(1:p_cut.K.f,:);
    be = b(1:p_cut.K.f,:);
    A = A(1+p_cut.K.f:end,:);
    b = b(1+p_cut.K.f:end,:);
    P = Polyhedron('A',A,'b',b,'Ae',Ae,'be',be);
    P = projection(P,1:length(xi));
    E = ismember(x,P);
else
    z = recover(p_cut.used_variables);
    % We might have introduced some local modelling variables here
    m = size(p.F_struc,2)-1-length(z);
    if m>0
        z = [z;sdpvar(m,1)];
    end
    E = p_cut.F_struc*[1;z]>=0;
end

function p = mergeBoundsToModel(p);

A = [];
b = [];
if ~isempty(p.lb)
    A = [eye(length(p.c))];
    b = p.ub;
end
if ~isempty(p.ub)
    A = [A;-eye(length(p.c))];
    b = [b;-p.lb];
end
infbounds = find(isinf(b));
A(infbounds,:)=[];
b(infbounds)=[];
if length(b)>0
    p.F_struc = [p.F_struc(1:p.K.f,:);[b -A];p.F_struc(p.K.f+1:end,:)];
    p.K.l = p.K.l + length(b);
end







