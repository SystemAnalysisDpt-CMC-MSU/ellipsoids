function varargout = expexpintinv(varargin)
%EXPINT (overloaded)

% Author Johan L�fberg
switch class(varargin{1})

    case 'double'
        z = varargin{1};
%         if z < .01
%             varargout{1} = .95*z;
%         else           
            varargout{1} = exp(1./z).*expint(1./z);
%        end
        
    case 'sdpvar'
        varargout{1} = InstantiateElementWise(mfilename,varargin{:});

    case 'char'
        
        varargout{1} = [];
        varargout{2} = createOperator;
        varargout{3} = varargin{3};

    otherwise
        error('SDPVAR/EXPINTINV called with CHAR argument?');
end

function operator = createOperator

operator = struct('convexity','concave','monotonicity','increasing','definiteness','positive','model','callback');
operator.derivative = @derivative;
operator.range = [0 inf];
operator.domain = [1e-8 inf];

function d = derivative(z);
%if z < .01
%    d = 0.9;
%else
d = (-1./z.^2).*exp(1./z).*expint(1./z)+exp(1./z).*(-z.*exp(-1./z)).*(-1./z.^2);
%end