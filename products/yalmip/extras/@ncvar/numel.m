function N=numel(varargin)
%NUMEL (overloaded)

% Author Johan L�fberg 
% $Id: numel.m,v 1.1 2006-08-10 18:00:21 joloef Exp $   

X = varargin{1};
N = prod(size(X));
