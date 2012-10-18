function sys = gkyp(K,S,P,M)
%KYP Create generalized KYP matrix variable
%
%   X = KYP(K,S,P,M)       
%
% KYP is used to generate the matrix
%
% K'*(kron(S,P))*K + M;
%
% Note, Information is stored internally to inform YALMIP that this is a
% object defined from a KYP structure. Hence, the objects KYP(K,S,P,M) and
% the manually generated SDPVAR K'*(kron(S,P))*K + M are not equivalent.
%
% The knowledge about the underlying KYP structure can be exploited by some
% solvers.

% Author Johan L�fberg
% $Id: gkyp.m,v 1.2 2009-05-29 08:05:11 joloef Exp $

if nargin<4
    M = 0;
elseif isempty(M)
    M = 0;
end

kyp_part = K'*kron(S,P)*K;
if isempty(M)
    sys = kyp_part;
else
    sys = kyp_part+M;
end
sys.typeflag = 40;
sys.extra.K{1} = K;
sys.extra.Phi{1} = S;
sys.extra.P{1} = P;
if isempty(M)
    M = 0;
end
sys.extra.M = M;
sys.extra.negated = 0;