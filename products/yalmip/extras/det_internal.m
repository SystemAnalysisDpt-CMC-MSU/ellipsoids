function varargout = det_internal(varargin)

% Author Johan L�fberg
% $Id: det_internal.m,v 1.18 2007-08-02 19:17:36 joloef Exp $

switch class(varargin{1})

    case 'double'
        X = varargin{1};
        X = reshape(X,sqrt(length(X)),[]);
        varargout{1} = det(X);
    
    case 'char' % YALMIP send 'model' when it wants the epigraph or hypograph
      
        operator = struct('convexity','none','monotonicity','none','definiteness','none','model','callback');        
        operator.range = [-inf inf];

        varargout{1} = [];
        varargout{2} = operator;
        varargout{3} = varargin{3};

    otherwise
end
