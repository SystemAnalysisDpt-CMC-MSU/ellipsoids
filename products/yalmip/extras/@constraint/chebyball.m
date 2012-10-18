function varargout = chebyball(F)
%CHEBYBALL Computes Chebyshev ball of a constraint object
%
% If two outputs are requested, the numerical data is returned
% [xc,R] = chebyball(F)
%
% If three outputs are requrested, the symbolic model (x-xc)'(x-xc)<R^2 is
% appended
% [xc,R,C] = chebyball(F)
%
% If only one output is requested, only the symbolic constraint is returned
% C = chebyball(F)

% Author Johan L�fberg
% $Id: chebyball.m,v 1.1 2004-12-08 00:07:15 johanl Exp $

switch nargout
    case 0
        f = chebyball(set(F))
    case 1
        [f] = chebyball(set(F));
        varargout{1} = f;
    case 2
        [xc,R] = chebyball(set(F));
        varargout{1} = xc;
        varargout{2} = R;
    case 3
        [xc,R,f] = chebyball(set(F));
        varargout{1} = xc;
        varargout{2} = R;
        varargout{3} = f;
    otherwise
end