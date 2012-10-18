function [Fdual,objdual,y,X] = primalize(F,obj)
% PRIMALIZE Create the dual of an SDP given in dual form
%
% [Fd,objd,y] = primalize(F,obj)
%
% Input
%  F   : Primal constraint in form C-Ay > 0, Fy = g
%  obj : Primal cost maximize b'y
%
% Output
%  Fd  : Dual constraints in form X>0, Trace(AiX)==bi+dt
%  obj : Dual cost trace(CX)
%  y   : The detected primal free variables
%
% Example
%  See the HTML help.
%
% See also DUAL, SOLVESDP, SDPVAR, DUALIZE

% Author Johan L�fberg
% $Id: primalize.m,v 1.7 2008-05-04 13:26:31 joloef Exp $

err = 0;

if isa(F,'constraint')
    F = set(F);
end

% It's general, but not insanely general...
if ~(islinear(F) & islinear(obj))
    if nargout == 6
        Fdual = set([]);objdual = [];y = []; err = 1;
    else
        error('Can only primalize linear problems');
    end
end
if any(is(F,'socc'))
    if nargout == 6
        Fdual = set([]);objdual = [];y = []; err = 1;
    else
        error('Cannot primalize second order cone constraints');
    end
end
if isa(obj,'sdpvar')
    if any(is(F,'complex')) | is(obj,'complex')
    if nargout == 6
        Fdual = set([]);objdual = [];y = []; X = []; t = []; err = 1;
    else
        error('Cannot primalize complex-valued problems');
    end
    end
end
if any(is(F,'integer')) | any(is(F,'binary'))
    if nargout == 6
        Fdual = set([]);objdual = [];y = []; err = 1;
    else
        error('Cannot primalize discrete problems');
    end
end

% Create model using the standard code
model = export(F,obj,sdpsettings('solver','sedumi'),[],[],1);

Fdual = set([]);
xvec = [];
if model.K.f > 0
    t = sdpvar(model.K.f,1);
    xvec = [xvec;t];
end

if model.K.l > 0
    x = sdpvar(model.K.l,1);
    xvec = [xvec;x];
    Fdual = Fdual + set(x>=0);
end

if model.K.q(1) > 0
    for i = 1:length(model.K.q)
        x = sdpvar(model.K.q(i),1);
        xvec = [xvec;x];
        Fdual = Fdual + set(cone(x(2:end),x(1)));
    end
end

if model.K.s(1)>0
    for i = 1:length(model.K.s)
        X{i} = sdpvar(model.K.s(i),model.K.s(i));
        xvec = [xvec;X{i}(:)];
        Fdual = Fdual + set(X{i}>=0);       
    end
end

objdual = model.C(:)'*xvec;
Fdual = Fdual + set(-model.b == model.A'*xvec);

yvars = union(getvariables(F),getvariables(obj));
y = recover(yvars);

yalmip('associatedual',getlmiid(Fdual(end)),y);