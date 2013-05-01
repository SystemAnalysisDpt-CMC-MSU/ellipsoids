function [x, FVAL, EXITFLAG] = ...
         nlcp_solve(funfcn, x, confcn, OPTIONS, meritFunctionType, ...
                    CHG, fval, gval, ncineqval, nceqval, gncval, gnceqval, varargin);
%
% NLCP_SOLVE - nonlinear function minimizer under nonlinear
%              constraints.
%

  status            = 0; 
  EXITFLAG          = 1;
  iter              = 0;
  XOUT              = x(:);
  gradflag          = OPTIONS.fungrad;
  gradconstflag     = OPTIONS.congrad;
  numberOfVariables = length(XOUT);
  bestf             = Inf;
  FVAL              = [];
  lambda            = [];
  lambdaNLP         = [];
  lb                = -Inf*ones(numberOfVariables, 1);
  lenlb             = numberOfVariables;
  arglb             = ~isinf(lb);
  ub                = Inf*ones(numberOfVariables, 1);
  lenub             = numberOfVariables;
  argub             = ~isinf(ub);
  Ain               = [];
  Aeq               = [];
  Bin               = [];
  Beq               = [];
  stepsize          = 1;
  HESS              = eye(numberOfVariables);
  tolX              = 1e-7;
  tolFun            = 1e-7;
  tolCon            = 1e-7;
  DiffMinChange     = 1e-8;
  DiffMaxChange     = 1e-1;
  DerivativeCheck   = 0;
  maxFunEvals       = 200 * numberOfVariables;
  maxIter           = 400;

  %if  strcmp(funfcn{2}, 'fminimax') |  strcmp(funfcn{2}, 'fgoalattain')
  %  lb(end + 1) = -Inf;
  %  ub(end + 1) = Inf;
  %end

  A                = zeros(0, numberOfVariables);
  B                = zeros(0, 1);
  Aeq              = zeros(0, numberOfVariables);
  Beq              = zeros(0, 1);
  NEWLAMBDA        = [];
  LAMBDA           = [];
  OLDLAMBDA        = [];
  x(:)             = XOUT;
  f                = fval;
  nceq             = nceqval;
  ncineq           = ncineqval;
  nc               = [nceq; ncineq];
  c                = [Aeq*XOUT-Beq; nceq; A*XOUT-B; ncineq];
  non_eq           = length(nceq);
  non_ineq         = length(ncineq);
  [lin_eq, Aeqcol] = size(Aeq);
  [lin_ineq, Acol] = size(A);
  eq               = non_eq + lin_eq;
  ineq             = non_ineq + lin_ineq;
  ncstr            = ineq + eq;
  ga               = [abs(c((1:eq)')); c((eq+1:ncstr)')];

  if ~isempty(c)
    mg = max(ga);
  else
    mg = 0;
  end

  % Evaluate initial analytic gradients and check size
  if gradflag | gradconstflag
    if gradflag
      gf_user = gval;
    end
    if gradconstflag
      gnc_user = [gnceqval, gncval];
    else
      gnc_user = [];
    end
    if isempty(gnc_user) & isempty(nc)
      gnc      = nc';
      gnc_user = nc';
    end
  end

  OLDX         = XOUT;
  OLDC         = c; 
  OLDNC        = nc;
  OLDgf        = zeros(numberOfVariables, 1);
  gf           = zeros(numberOfVariables, 1);
  OLDAN        = zeros(ncstr, numberOfVariables);
  LAMBDA       = zeros(ncstr, 1);
  lambdaNLP    = zeros(ncstr, 1);
  numFunEvals  = 1;
  numGradEvals = 1;
  GNEW         = 1e8*CHG;

  % Main loop
  while status ~= 1
    % Gradients
    if ~gradconstflag | ~gradflag | DerivativeCheck
      oldf   = f;
      oldnc  = nc;
      len_nc = length(nc);
      ncstr  =  lin_eq + lin_ineq + len_nc;     
      gnc    = zeros(numberOfVariables, len_nc);
      CHG    = -1e-8./(GNEW + eps);
      CHG    = sign(CHG + eps).*min(max(abs(CHG), DiffMinChange), DiffMaxChange);
      for gcnt = 1:numberOfVariables
        temp       = XOUT(gcnt);
        XOUT(gcnt) = temp + CHG(gcnt);
        x(:)       = XOUT; 
        if ~gradflag | DerivativeCheck
          f           = feval(funfcn{3}, x, varargin{:});
          gf(gcnt, 1) = (f - oldf)/CHG(gcnt);
        end
        if ~gradconstflag | DerivativeCheck
          [nctmp, nceqtmp] = feval(confcn{3}, x, varargin{:});
          nc               = [nceqtmp(:); nctmp(:)];
          if ~isempty(nc)
            gnc(gcnt, :) = (nc - oldnc)'/CHG(gcnt); 
          end
        end
        XOUT(gcnt) = temp;
      end
      
      % Gradient check
      if DerivativeCheck == 1 & (gradflag | gradconstflag) % analytic exists
        if gradflag
          gfFD = gf;
          gf   = gf_user;
          if isa(funfcn{4}, 'inline')
            graderr(gfFD, gf, formula(funfcn{4}));
          else
            graderr(gfFD, gf, funfcn{4});
          end
        end
        if gradconstflag
          gncFD = gnc; 
          gnc   = gnc_user;
          if isa(confcn{4}, 'inline')
            graderr(gncFD, gnc, formula(confcn{4}));
          else
            graderr(gncFD, gnc, confcn{4});
          end
        end         
        DerivativeCheck = 0;
      elseif gradflag | gradconstflag
        if gradflag
          gf = gf_user;
        end
        if gradconstflag
          gnc = gnc_user;
        end
      end
      numFunEvals = numFunEvals + numberOfVariables;
      f           = oldf;
      nc          = oldnc;
    else
      gnc = gnc_user;
      gf  = gf_user;
    end  
   
   % Add in Aeq and A
   if ~isempty(gnc)
     gc = [Aeq', gnc(:, 1:non_eq), A', gnc(:, non_eq+1:non_ineq+non_eq)];
   elseif ~isempty(Aeq) | ~isempty(A)
     gc = [Aeq', A'];
   else
     gc = zeros(numberOfVariables, 0);
   end
   AN       = gc';

   if iter > 0
     if meritFunctionType == 1 
         optimError = inf;
     else
       normgradLag = norm(gf + AN'*lambdaNLP, inf);
       normcomp    = norm(lambdaNLP(eq+1:ncstr).*c(eq+1:ncstr), inf);
       if isfinite(normgradLag) & isfinite(normcomp)
         optimError = max(normgradLag, normcomp);
       else
         optimError = inf;
       end
     end
     feasError  = mg;
     optimScal  = 1;
     feasScal   = 1; 

     % Test convergence
     if (optimError < tolFun*optimScal) & (feasError < tolCon*feasScal)
       EXITFLAG     = 1;
       status       = 1;
       active_const = find(LAMBDA > 0);
     elseif ((max(abs(SD)) < 2*tolX) | (abs(gf'*SD) < 2*tolFun)) & ...
             ((mg < tolCon) | (strncmp(howqp,'i',1) & (mg > 0)))
       if ~strncmp(howqp, 'i', 1) 
         if meritFunctionType == 1
                 optimError = inf;
         else
           lambdaNLP(:, 1)       = 0;
           [Q, R]                = qr(AN(ACTIND, :)');
           ws                    = warning('off');
           lambdaNLP(ACTIND)     = -R\Q'*gf;
           warning(ws);
           lambdaNLP(eq+1:ncstr) = max(0,lambdaNLP(eq+1:ncstr));
           normgradLag           = norm(gf + AN'*lambdaNLP, inf);
           normcomp              = norm(lambdaNLP(eq+1:ncstr).*c(eq+1:ncstr), inf);
           if isfinite(normgradLag) & isfinite(normcomp)
             optimError = max(normgradLag, normcomp);
           else
             optimError = inf;
           end
         end
         optimScal    = 1;
	 EXITFLAG     = 1;
         active_const = find(LAMBDA > 0);
       end
       if strncmp(howqp, 'i', 1) & (mg > 0)
         EXITFLAG = -1;   
       end
       status = 1;
     else
       if (numFunEvals > maxFunEvals) | (iter > maxIter)
         XOUT     = MATX;
         f        = OLDF;
         EXITFLAG = 0;
         status   = 1;
       end
     end 
   end
   if status ~= 1
     iter = iter + 1;
     for i = 1:eq 
       schg = AN(i, :)*gf;
       if schg > 0
         AN(i, :) = -AN(i, :);
         c(i)     = -c(i);
       end
     end
     if numGradEvals > 1
       NEWLAMBDA = LAMBDA; 
       [ma, na]  = size(AN);
       GNEW      = gf + AN'*NEWLAMBDA;
       GOLD      = OLDgf + OLDAN'*LAMBDA;
       YL        = GNEW - GOLD;
       sdiff     = XOUT - OLDX;
       if YL'*sdiff < stepsize^2*1e-3
         while YL'*sdiff < -1e-5
           [YMAX, YIND] = min(YL.*sdiff);
           YL(YIND)     = YL(YIND)/2;
         end
         if YL'*sdiff < (eps*norm(HESS, 'fro'));
           FACTOR = AN'*c - OLDAN'*OLDC;
           FACTOR = FACTOR.*(sdiff.*FACTOR > 0).*(YL.*sdiff <= eps);
           WT     = 1e-2;
           if max(abs(FACTOR)) == 0
             FACTOR = 1e-5*sign(sdiff);
           end
           while (YL'*sdiff < (eps*norm(HESS, 'fro'))) & (WT < 1/eps)
             YL = YL + WT*FACTOR;
             WT = WT*2;
           end
         end
       end
       if YL'*sdiff > eps
         HESS = HESS + (YL*YL')/(YL'*sdiff) - ((HESS*sdiff)*(sdiff'*HESS'))/(sdiff'*HESS*sdiff);
       end
     else
       OLDLAMBDA = (eps + gf'*gf)*ones(ncstr, 1)./(sum(AN'.*AN')' + eps);
       ACTIND    = 1:eq;     
     end

     numGradEvals = numGradEvals + 1;
     LOLD         = LAMBDA;
     OLDAN        = AN;
     OLDgf        = gf;
     OLDC         = c;
     OLDF         = f;
     OLDX         = XOUT;
     XN           = zeros(numberOfVariables, 1);

     %if (meritFunctionType > 0) & (meritFunctionType < 5)
     %  HESS(numberOfVariables, 1:numberOfVariables) = ...
     %     zeros(1, numberOfVariables);
     %  HESS(1:numberOfVariables, numberOfVariables) = ...
     %     zeros(numberOfVariables, 1);
     %  HESS(numberOfVariables, numberOfVariables) = 1e-8*norm(HESS, 'inf');
     %  XN(numberOfVariables)                      = max(c);
     %end
   
     HESS = 0.5*(HESS + HESS');
   
     [SD, lambda, exitflagqp, outqp, howqp, ACTIND] = ...
        qps(HESS, gf, AN, -c, [], [], XN, eq, ...
            'nlc', size(AN, 1), numberOfVariables, ACTIND);
    
     lambdaNLP(:, 1)   = 0;
     lambdaNLP(ACTIND) = lambda(ACTIND);
     lambda((1:eq)')   = abs(lambda((1:eq)'));
     ga                = [abs(c((1:eq)')); c((eq+1:ncstr)') ];
     if ~isempty(c)
       mg = max(ga);
     else
       mg = 0;
     end

     if strncmp(howqp, 'ok', 2); 
       howqp = ''; 
     end

     LAMBDA    = lambda((1:ncstr)');
     OLDLAMBDA = max([LAMBDA'; 0.5*(LAMBDA + OLDLAMBDA)'])';
     MATX      = XOUT;
     MATL      = f + sum(OLDLAMBDA.*(ga>0).*ga) + 1e-30;
     infeas    = strncmp(howqp, 'i', 1);

     if meritFunctionType == 0
       if mg > 0
         MATL2 = mg;
       elseif f >= 0 
         MATL2 = -1/(f+1);
       else 
         MATL2 = 0;
       end
       if ~infeas & (f < 0)
         MATL2 = MATL2 + f - 1;
       end
     else
       MATL2 = mg + f;
     end
     if (mg < eps) & (f < bestf)
       bestf      = f;
       bestx      = XOUT;
       bestHess   = HESS;
       bestgrad   = gf;
       bestlambda = lambda;
     end
     MERIT    = MATL + 1;
     MERIT2   = MATL2 + 1; 
     stepsize = 2;
     while (MERIT2 > MATL2) & (MERIT > MATL) & ...
           (numFunEvals < maxFunEvals)
       stepsize = stepsize/2;
       if stepsize < 1e-4,  
         stepsize = -stepsize; 
       end

       XOUT            = MATX + stepsize*SD;
       x(:)            = XOUT; 
       f               = feval(funfcn{3}, x, varargin{:});
       [nctmp,nceqtmp] = feval(confcn{3}, x, varargin{:});
       nctmp           = nctmp(:);
       nceqtmp         = nceqtmp(:);
       nc              = [nceqtmp(:); nctmp(:)];
       c               = [Aeq*XOUT-Beq; nceqtmp(:); A*XOUT-B; nctmp(:)];  
       numFunEvals     = numFunEvals + 1;
       ga              = [abs(c((1:eq)')); c((eq+1:length(c))')];

       if ~isempty(c)
         mg = max(ga);
       else
         mg = 0;
       end
       MERIT = f + sum(OLDLAMBDA.*(ga>0).*ga);
       if meritFunctionType == 0
         if mg > 0
           MERIT2 = mg;
         elseif f >= 0 
           MERIT2 = -1/(f + 1);
         else 
           MERIT2 = 0;
         end
         if ~infeas & (f < 0)
           MERIT2 = MERIT2 + f - 1;
         end
       else
         MERIT2 = mg + f;
       end
     end
     mf     = abs(stepsize);
     LAMBDA = mf*LAMBDA + (1 - mf)*LOLD;
     x(:)   = XOUT;

     switch funfcn{1}
      case 'fungrad',
         [f, gf_user] = feval(funfcn{3}, x, varargin{:});
         gf_user      = gf_user(:);
         numGradEvals = numGradEvals + 1;
       otherwise,
         ;
     end
     numFunEvals = numFunEvals + 1;
   
     switch confcn{1}
       case 'fungrad',
         [nctmp, nceqtmp, gncineq, gnceq] = feval(confcn{3}, x, varargin{:});
         nctmp                            = nctmp(:);
         nceqtmp                          = nceqtmp(:);
         numGradEvals                     = numGradEvals + 1;
       otherwise,
         gnceq   = [];
         gncineq = [];
     end
     gnc_user = [gnceq, gncineq];
     gc       = [Aeq', gnceq, A', gncineq];
   
   end
  end % Main loop

  numConstrEvals = numGradEvals;
  if f > bestf 
    XOUT     = bestx;
    f        = bestf;
  end
  FVAL = f;
  x(:) = XOUT;

  return;
