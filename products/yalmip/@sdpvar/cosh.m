function varargout = cosh(varargin)
%COSH (overloaded)

% Author Johan L�fberg
% $Id: cosh.m,v 1.4 2007-08-02 18:16:26 joloef Exp $
switch class(varargin{1})

    case 'double'
        error('Overloaded SDPVAR/COSH CALLED WITH DOUBLE. Report error')

    case 'sdpvar'
        varargout{1} = InstantiateElementWise(mfilename,varargin{:});

    case 'char'

        operator = struct('convexity','none','monotonicity','none','definiteness','positive','model','callback');
        operator.convexhull = [];
        operator.bounds = @bounds;
        operator.derivative = @(x)(sinh(x));

        varargout{1} = [];
        varargout{2} = operator;
        varargout{3} = varargin{3};

    otherwise
        error('SDPVAR/COSH called with CHAR argument?');
end

function [L,U] = bounds(xL,xU)
if xL<0 & xU>0
    L = 0;
    U = max([cosh(xL) cosh(xU)]);
elseif xL<0
    L = cosh(xU);
    U = cosh(xL);
else
    L = cosh(xL);
    U = cosh(xU);
end
