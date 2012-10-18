function varargout=median(varargin)
%VAR (overloaded)
%
% V = var(x)

% Author Johan L�fberg
% $Id: var.m,v 1.1 2006-08-10 18:00:23 joloef Exp $

x = varargin{1};

if nargin > 1 | min(size(x))>1
    error('SDPVAR/VAR only supports simple 1-D variance'),
end

switch length(x)
    case 1
        varargout{1} = x;
    otherwise
        x = reshape(x,length(x),1);
        m = sum(x)/length(x);
        varargout{1} = ((x-m)'*(x-m)) / (length(x) - 1);
end
