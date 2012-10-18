function varargout = sqrtm_internal(varargin)
%SQRTM (overloaded)

% Author Johan L�fberg
% $Id: sqrtm_internal.m,v 1.12 2009-10-02 09:09:13 joloef Exp $
switch class(varargin{1})

    case 'double'
        varargout{1} = sqrt(varargin{1});

    case 'sdpvar'
          varargout{1} = InstantiateElementWise(mfilename,varargin{:});
%        if length(varargin{1}) == 1
%            varargout{1} = yalmip('define',mfilename,varargin{1});
%        else
%            error('SQRTM is only implemented for scalar argument')
%        end

    case 'char'

        X = varargin{3};
        F = set(X >= eps);

        varargout{1} = F;
        varargout{2} = struct('convexity','concave','monotonicity','increasing','definiteness','positive','convexhull',@convexhull,'bounds',@bounds,'model','callback','derivative',@(x) 1./(eps + 2*abs(x).^0.5));
        varargout{3} = X;

    otherwise
        error('SDPVAR/SQRTM called with CHAR argument?');
end

function [L,U] = bounds(xL,xU)
if xL < 0
    % The variable is not bounded enough yet
    L = 0;
else
    L = sqrt(xL);
end
if xU < 0
    % This is an infeasible problem
    L = inf;
    U = -inf;
else
    U = sqrt(xU);
end

function [Ax, Ay, b] = convexhull(xL,xU)
if xL < 0 | xU == 0
    Ax = []
    Ay = [];
    b = [];
else
    fL = sqrt(xL);
    fU = sqrt(xU);
    dfL = 1/(2*sqrt(xL));
    dfU = 1/(2*sqrt(xU));
    [Ax,Ay,b] = convexhullConcave(xL,xU,fL,fU,dfL,dfU);
    remove = isinf(b) | isinf(Ax) | isnan(b);
    if any(remove)
        remove = find(remove);
        Ax(remove)=[];
        b(remove)=[];
        Ay(remove)=[];
    end
end