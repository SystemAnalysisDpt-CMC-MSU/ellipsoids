function varargout=abs(varargin)
%ABS (overloaded)

% Author Johan L�fberg
% $Id: abs.m,v 1.28 2008-11-11 13:29:20 joloef Exp $

switch class(varargin{1})
    case 'double'
        error('Overloaded SDPVAR/ABS CALLED WITH DOUBLE. Report error')

    case 'sdpvar' % Overloaded operator for SDPVAR objects. Pass on args and save them.
        if isreal(varargin{1})
            varargout{1} = yalmip('define',mfilename,varargin{1});
        else
            % For complex args, abs(X) is defined [norm(X(i,j),2)] in MATLAB
            y = [];
            x = varargin{1};
            for i = 1:size(x,1)
                temp = [];
                for j = 1:size(x,2)
                    temp = [temp norm(extsubsref(x,i,j))];
                end
                y = [y;temp];
            end
            varargout{1} = y;
        end

    case 'char' % YALMIP send 'graph' when it wants the epigraph or hypograph
        switch varargin{1}
            case 'graph'
                % Description using epigraphs
                t = varargin{2};
                X = varargin{3};
              %  varargout{1} = set(-t <= X <= t);
                varargout{1} = [1 -1;-1 -1]*[X;t] <= [0;0];%-t <= X <= t);
                
                varargout{2} = struct('convexity','convex','monotonicity','none','definiteness','positive','model','graph');
                varargout{3} = X;

            case {'exact','integer','callback'}
                % Exact description using binary variables
                t = varargin{2};
                X = varargin{3};
                d = varargin{4};
                [M,m]=derivebounds(X);
                if m>=0
                    F = set(t == X);
                elseif M<=0
                    F = set(t == -X);
                else
                   % d = binvar(1,1);
                    maxABSX = max([abs(m) abs(M)],[],2);
                   % F = F + set(0<= t <= maxABSX);
                   % F = F + set(X <= M*d)     + set(0 <= t+X <= 2*maxABSX*d);
                   % F = F + set(X >= m*(1-d)) + set(0 <= t-X <= 2*maxABSX*(1-d));
                    F = [[0 1 0;
                     0 -1 0;   
                     1 0 -M;
                     1 1 -2*maxABSX;
                     -1 -1 0;
                     -1 0 -m;
                     -1 1 2*maxABSX;1 -1 0]*[X;t;d] <= [maxABSX;0;0;0;0;-m;2*maxABSX;0]];
                end
                varargout{1} = F;
                varargout{2} = struct('convexity','convex','monotonicity','none','definiteness','positive','model','integer');
                varargout{3} = X;

            otherwise
                error('SDPVAR/ABS called with CHAR argument?');
        end
    otherwise
        error('Strange type on first argument in SDPVAR/ABS');
end
