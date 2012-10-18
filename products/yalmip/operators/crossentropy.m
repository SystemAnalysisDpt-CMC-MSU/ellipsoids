function varargout = crossentropy(varargin)
% CROSSENTROPY
%
% y = CROSSENTROPY(x,y)
%
% Computes/declares cross entropy -sum(x.*log(y))

% Author Johan L�fberg

switch class(varargin{1})

    case 'double'    
        if nargin == 1
            % YALMIP flattens internally to [x(:);y(:)]
            z = varargin{1};
            z = reshape(z,[],2);
            x = z(:,1);
            y = z(:,2);
        else
            x = varargin{1}(:);
            y = varargin{2}(:);
        end
        ce = x(:).*log(y(:));
        ce(x==0) = 0;
        ce = real(ce);
        varargout{1} = -sum(ce);
        

    case 'sdpvar'
        
            varargin{1} = reshape(varargin{1},[],1);
            varargin{2} = reshape(varargin{2},[],1);
            varargout{1} = yalmip('define',mfilename,[varargin{1};varargin{2}]);
        

    case 'char'

        X = varargin{3};
        F = [X >= 0];

        operator = struct('convexity','none','monotonicity','none','definiteness','none','model','callback');
        operator.range = [-inf inf];
        operator.domain = [0 inf];       
        operator.derivative = @derivative;

        varargout{1} = F;
        varargout{2} = operator;
        varargout{3} = X;

    otherwise
        error('SDPVAR/LOG called with CHAR argument?');
end

function df = derivative(x)

z = reshape(x,[],2);
x = z(:,1);
y = z(:,2);

df = [-log(y);-x./y];


