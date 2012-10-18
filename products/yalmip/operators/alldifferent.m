function varargout=alldifferent(varargin)

switch class(varargin{1})

    case 'double'
        x = varargin{1};
        x = sort(x(:));
        varargout{1} = all(diff(x) > 0);

    case 'sdpvar'
        %varargout{1} = set(yalmip('define',mfilename,varargin{:}) == 1);
        varargout{1} = setupMeta(lmi([]), mfilename,varargin{:});

    case 'char'
        x = varargin{3};
        [nx,mx] = size(x);
        x = reshape(x,nx*mx,1);

        [M,m] = derivebounds(x);
        
        % Add constraint |x(i)-x(j)| > 1
        pairs = nchoosek(1:nx*mx,2);
        d = binvar(length(pairs),1);
        x1 = x(pairs(:,1));
        x2 = x(pairs(:,2));

        % d(i) = 0  ==> x1>x2
        % d(i) = 1  ==> x2>x1

        F =     set(x1 - x2 >= 1-(1+M(pairs(:,2))-m(pairs(:,1))).*d);
        F = F + set(x2 - x1 >= 1-(1+M(pairs(:,1))-m(pairs(:,2))).*(1-d));

        varargout{1} = F;
        varargout{2} = struct('convexity','none','monotonicity','none','definiteness','none','extra','marker','model','integer');
        varargout{3} = varargin{3};
end