function [X, FVAL] = ell_nlfnlc(objf, x0, nlcf, Options, varargin)
%
% ELL_NLFNLC - computes minimum of nonlinear function with 
%              nonlinear constraints.
%
%
% Description:
% ------------
%
%  [X, FVAL] = ELL_NLFNLC(OBJFUN, X0, NLCF)  Find minimum 
%                of the function specified by OBJFUN 
%                (inline or function handler) with 
%                nonlinear constraints specified by NLCF
%                (inline or function handler) using
%                gradient optimization method starting at
%                initial vector X0.
%  [X, FVAL] = ELL_NLFNLC(OBJFUN,X0,NLCF,OPTIONS,P1,P2,...)
%                In OPTIONS parameter the user can specify 
%                if he wants to provide his own gradient 
%                values by setting
%                           OPTIONS.fungrad = 1,
%                and/or
%                           OPTIONS.congrad = 1
%                P1, P2, ... are optional parameters that 
%                are passed to the objective function OBJFUN
%                and to the constraint function NLCF.
%                
%
%    Function OBJFUN takes X as input parameter and returns 
%    value of the nonlinear objective function at that 
%    point. If OPTIONS.fungrad is set to 1, it also returns 
%    the value  of the gradient of this function  at that
%    point.
%    Function NLCF takes vector X as input and returns a
%    pair of matrices  [A, B], that describes nonlinear 
%    constraints on X in the form
%                          A X <= 0,
%                          B X  = 0.
%    Either A or B (but not both) can be empty. 
%    If OPTIONS.congrad is set to 1,
%    then NLCF returns [A, B, C, D] where C is partial
%    derivatives of the constraint vector of 
%    inequalities A, and D - partial derivatives of 
%    constraint vector of equalities B.
%
%    Example of how ELL_NLFNLC function is used can be 
%    found in ELLIPSOID/DISTANCE.
%
%
% Output:
% -------
%
%    X    - vector at which the minimum is achieved,
%    FVAL - value of objective function at minimum.
%
%
% See also:
% ---------
%
%    YALMIP, SEDUMI.
%

%
% Author:
% -------
%
%    Alex Kurzhanskiy <akurzhan@eecs.berkeley.edu>
%

  import elltool.conf.Properties;
  import elltool.logging.Log4jConfigurator;
  
  persistent logger;

  if nargin < 3
    error('ELL_NLFNLC: function requires at least four input arguments.');
  end
  
  if (nargin < 4) | ~(isstruct(Options))
    Options = [];
  end

  lenVarIn          = length(varargin);
  XOUT              = x0(:);
  X                 = x0;
  numberOfVariables = length(XOUT);

  if ~(isfield(Options, 'fungrad')) 
    Options.fungrad = 0;
  end
  if ~(isfield(Options, 'congrad')) 
    Options.congrad = 0;
  end

  % Convert to inline function as needed
  if ~isempty(objf)
    [funfcn, msg] = fcnchk(objf, length(varargin));
    if ~(isempty(msg))
      error(msg);
    end
  else
    error('ELL_NLFNLC: first argument must be a function or inline object.');
  end

  if Options.fungrad > 0
    funfcn = {'fungrad', 'ell_nlfnlc', funfcn, funfcn, []};
  else
    funfcn = {'fun', 'ell_nlfnlc', funfcn, funfcn, []};
  end

  if ~isempty(nlcf)
    [confcn, msg] = fcnchk(nlcf, length(varargin));
    if ~(isempty(msg))
      error(msg);
    end
  else
    error('ELL_NLFNLC: third argument must be a function or inline object.');
  end

  if Options.congrad > 0
    confcn = {'fungrad', 'ell_nlfnlc', confcn, confcn, []};
  else
    confcn = {'fun', 'ell_nlfnlc', confcn, confcn, []};
  end

  CHG              = 1e-7*abs(XOUT)+1e-7*ones(numberOfVariables, 1);
  X(:)             = XOUT;

  % Evaluate function
  GRAD = zeros(numberOfVariables, 1);

  switch funfcn{1}
    case 'fungrad',
      try
        [f, GRAD(:)] = feval(funfcn{3}, X, varargin{:});
      catch
        error(sprintf('ELL_NLFNLC: error in the objective function: %s', lasterr));
      end

    otherwise, 
      try
        f = feval(funfcn{3}, X, varargin{:});
      catch
        error(sprintf('ELL_NLFNLC: error in the objective function: %s', lasterr));
      end

  end

  % Evaluate constraints
  switch confcn{1}
    case 'fungrad',
      try
        [ctmp, ceqtmp, cGRAD, ceqGRAD]  = feval(confcn{3}, X, varargin{:});
        c                               = ctmp(:);
        ceq                             = ceqtmp(:);
      catch
        error(sprintf('ELL_NLFNLC: error in the constraint function: %s', lasterr));
      end

    otherwise,
      try 
        [ctmp, ceqtmp] = feval(confcn{3}, X, varargin{:});
        c              = ctmp(:);
        ceq            = ceqtmp(:);
        cGRAD          = zeros(numberOfVariables, length(c));
        ceqGRAD        = zeros(numberOfVariables, length(ceq));
      catch
        error(sprintf('ELL_NLFNLC: error in the constraint function: %s', lasterr));
      end

  end

  [cgrow, cgcol]     = size(cGRAD);
  [ceqgrow, ceqgcol] = size(ceqGRAD);
  ineq               = length(c);
  eq                 = length(ceq);

  if (cgrow ~= numberOfVariables) & (cgcol ~= ineq)
    error('ELL_NLFNLC: gradient of the nonlinear inequality constraints is the wrong size.')
  end
  if (ceqgrow ~= numberOfVariables) & (ceqgcol ~= eq)
    error('ELL_NLFNLC: gradient of the nonlinear equality constraints is the wrong size.')
  end

  [X, FVAL, status] = nlcp_solve(funfcn, X, confcn, Options, 0, ...
                                 CHG, f, GRAD, c, ceq, cGRAD, ceqGRAD, varargin{:});

  if status < 0
    if isempty(logger)
      logger=Log4jConfigurator.getLogger();
    end
    if Properties.getIsVerbose()
      logger.info('ELL_NLFNLC: Warning! NLCP solver cannot compute the minimum.');
    end
  elseif status == 0
    if Properties.getIsVerbose()
      logger.info('ELL_NLFNLC: Warning! Maximum of function evaluations exceeded.');
    end
  end

  return;
