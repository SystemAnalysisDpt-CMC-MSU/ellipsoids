function X=sos1(X,weights)
%SOS1 Declare special ordered set of type 1
%
% F = sos(p,w)
%
% Input
%  p : SDPVAR object
%  w : Priority weights
% Output
%  F : CONSTRAINT object

% Author Johan L�fberg 
% $Id: sos2.m,v 1.8 2009-10-08 11:11:06 joloef Exp $  

X.typeflag = 51;
if nargin == 1
    X.extra.sosweights = 1:length(X);
else
    X.extra.sosweights = findOutWeights(X,weights)       
end
X = set(X);
