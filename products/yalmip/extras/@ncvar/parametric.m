function x = integer(x)
%PARAMETRIC Defines a variable as parametric
%
%   F = PARAMETRIC(x) is used to describe the set of parametric variables
%   in a multi-parametric program, as an alternative to using the 4th input
%   in SOLVEMP
%
%
%   INPUT
%    x : SDPVAR object
%
%   OUTPUT
%    F : SET object
%
%   EXAMPLE
%    F = set(prametric(x));           % Full verbose notation
%    F = parametric(x);               % Short notation
%
%   See also SOLVEMP, SDPVAR

% Author Johan L�fberg
% $Id: parametric.m,v 1.1 2006-08-10 18:00:21 joloef Exp $

x.typeflag = 13;
x = lmi(x);