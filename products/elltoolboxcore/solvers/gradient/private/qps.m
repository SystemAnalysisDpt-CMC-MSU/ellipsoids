function [X, lambda, output, exitflag, how, ACTIND] = ...
            qps(H, f, A, B, lb, ub, X, neqcstr, caller, ncstr, ...
                numberOfVariables, ACTIND)
%
% QPS - Quadratic programming problem.
%
%            min 0.5*x'Hx + f'x   subject to:  Ax <= b 
%             x    
%

  NewtonStep   = 1;
  NegCurv      = 2;
  SteepDescent = 3;
  ZeroStep     = 4;
  Conls        = 'lsqlin';
  Lp           = 'linprog';
  Qp           = 'quadprog';
  Qpsub        = 'qps';
  Nlconst      = 'nlc';
  how          = 'ok'; 
  exitflag     = 1;
  output       = [];
  iterations   = 0;

  if nargin < 12
    ACTIND = [];
  end

  lb  = lb(:);
  ub  = ub(:);
  msg = nargchk(12, 12, nargin);
  if isempty(neqcstr)
    neqcstr = 0;
  end

  LLS = 0;
  if strcmp(caller, Conls)
    LLS               = 1;
    [rowH, colH]      = size(H);
    numberOfVariables = colH;
  end
  if strcmp(caller, Qpsub)
    normalize = -1;
  else
    normalize = 1;
  end

  simplex_iter = 0;
  if (norm(H, 'inf') == 0) | isempty(H)
    is_qp = 0;
  else
    is_qp = 1;
  end

  if LLS==1
    is_qp = 0;
  end

  normf = 1;
  if normalize > 0
    if ~is_qp & ~LLS
      normf = norm(f);
      if normf > 0
        f = f./normf;
      end
    end
  end

  arglb = ~eq(lb, -inf);
  lenlb = length(lb);
  if nnz(arglb) > 0     
    lbmatrix = -eye(lenlb, numberOfVariables);
    A        = [A; lbmatrix(arglb, 1:numberOfVariables)];
    B        = [B; -lb(arglb)];
  end

  argub = ~eq(ub, inf);
  lenub = length(ub);
  if nnz(argub) > 0
    ubmatrix = eye(lenub,numberOfVariables);
    A        = [A; ubmatrix(argub, 1:numberOfVariables)];
    B        = [B; ub(argub)];
  end 
  ncstr = ncstr + nnz(arglb) + nnz(argub);

  if isequal(caller, Nlconst)
    maxiter = Inf;
  else
    maxiter = 400;
  end

  normA = ones(ncstr, 1);
  if normalize > 0 
    for i=1:ncstr
      n = norm(A(i, :));
      if (n ~= 0)
        A(i, :)     = A(i, :)/n;
        B(i)        = B(i)/n;
        normA(i, 1) = n;
      end
    end
  else 
    normA = ones(ncstr, 1);
  end
  errnorm = 0.01*realsqrt(eps); 

  tolDep = 100*numberOfVariables*eps;      
  lambda = zeros(ncstr, 1);
  eqix   = 1:neqcstr;

  ACTCNT = length(ACTIND);
  if isempty(ACTIND)
    ACTIND = eqix;
  elseif neqcstr > 0
    i = max(find(ACTIND <= neqcstr));
    if isempty(i) | (i > neqcstr)
      ACTIND = eqix;
    elseif i < neqcstr
      numremoved                          = neqcstr - i;
      ACTIND(neqcstr+1:ACTCNT+numremoved) = ACTIND(i+1:ACTCNT);
      ACTIND(1:neqcstr)                   = eqix;
    end
  end
  aix         = zeros(ncstr, 1);
  aix(ACTIND) = 1;
  ACTCNT      = length(ACTIND);
  ACTSET      = A(ACTIND, :);

  indepInd = 1:ncstr;
  remove   = [];
  if ACTCNT > 0 & (normalize ~= -1)
    [Q, R, A, B, X, Z, how, ACTSET, ACTIND, ACTCNT, aix, eqix, ...
     neqcstr, ncstr, remove, exitflag] = ...
       consolve(A, B, eqix, neqcstr, ncstr, numberOfVariables, LLS, H, X, f, ...
                normf, normA, aix, ACTSET, ACTIND, ACTCNT, how, exitflag); 
    
    if ~isempty(remove)
      indepInd(remove) = [];
      normA            = normA(indepInd);
    end
    
    if strcmp(how, 'infeasible')
      ACTIND            = indepInd(ACTIND);
      output.iterations = iterations;
      exitflag          = -1;
      return;
    end
    
    err = 0;
    if neqcstr >= numberOfVariables
      err = max(abs(A(eqix, :)*X-B(eqix)));
      if (err > 1e-8)
        how               = 'infeasible';
        exitflag          = -1;
        ACTIND            = indepInd(ACTIND);
        output.iterations = iterations;
        return;
      else
        if (max(A*X-B) > 1e-8)
          how      = 'infeasible';
          exitflag = -1;
        end
      end
      if is_qp
        actlambda = -R\(Q'*(H*X+f));
      elseif LLS
        actlambda = -R\(Q'*(H'*(H*X-f)));
      else
        actlambda = -R\(Q'*f);
      end
      lambda(indepInd(ACTIND)) = normf * (actlambda ./normA(ACTIND));
      ACTIND                   = indepInd(ACTIND);
      output.iterations        = iterations;
      return;
    end
    
    cstr = A*X-B; 
    mc   = max(cstr(neqcstr+1:ncstr));
    if (mc > 0)
      X(numberOfVariables) = mc + 1;
    end
  else 
    if ACTCNT == 0
      Q = eye(numberOfVariables);
      R = [];
      Z = 1;
    else
      [Q, R] = qr(ACTSET');
      Z      = Q(:, ACTCNT+1:numberOfVariables);
    end   
  end

  cstr = A*X-B;
  if ncstr > neqcstr
    mc = max(cstr(neqcstr+1:ncstr));
  else
    mc = 0;
  end
  if mc > eps
    quiet   = -2;
    ACTIND2 = [1:neqcstr];
    A2      = [[A; zeros(1, numberOfVariables)], [zeros(neqcstr, 1); -ones(ncstr+1-neqcstr, 1)]];
    [XS, lambdaS, exitflagS, outputS, howS, ACTIND2] = ...
       qps([], [zeros(numberOfVariables,1); 1], A2, [B;1e-5], [], [], ...
           [X;mc+1], neqcstr, Qpsub, size(A2, 1), numberOfVariables+1, ACTIND2);
    slack = XS(numberOfVariables + 1);
    X     = XS(1:numberOfVariables);
    cstr  = A*X - B;
    if slack > eps 
      if slack > 1e-8 
        how      = 'infeasible';
        exitflag = -1;
      else
        how      = 'overly constrained';
        exitflag = -1;
      end
      lambda(indepInd)  = normf * (lambdaS((1:ncstr)')./normA);
      ACTIND            = 1:neqcstr;
      ACTIND            = indepInd(ACTIND);
      output.iterations = iterations;
      return;
    else
      ACTIND      = 1:neqcstr;
      ACTSET      = A(ACTIND, :);
      ACTCNT      = length(ACTIND);
      aix         = zeros(ncstr, 1);
      aix(ACTIND) = 1;
      if ACTCNT == 0
        Q = zeros(numberOfVariables, numberOfVariables);
        R = [];
        Z = 1;
      else
        [Q, R] = qr(ACTSET');
        Z      = Q(:, ACTCNT+1:numberOfVariables);
      end
    end
  end

  if ACTCNT >= numberOfVariables - 1  
    simplex_iter = 1; 
  end
  
  [m, n] = size(ACTSET);

  if (is_qp)
    gf            = H*X + f;
    [SD, dirType] = compute_direction(Z, H, gf, numberOfVariables, f);
  elseif (LLS)
    HXf      = H*X - f;
    gf       = H'*(HXf);
    HZ       = H*Z;
    [mm, nn] = size(HZ);
    if mm >= nn
      [QHZ, RHZ] = qr(HZ, 0);
      Pd         = QHZ'*HXf;
      if min(size(RHZ)) == 1
        depInd = find(abs(RHZ(1,1)) < tolDep);
      else
        depInd = find(abs(diag(RHZ)) < tolDep);
      end  
    end
    if mm >= nn & isempty(depInd)
      SD      = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn, :));
      dirType = NewtonStep;
    else
      SD      = -Z*(Z'*gf);
      dirType = SteepDescent;
    end
  else
    gf      = f;
    SD      = -Z*Z'*gf;
    dirType = SteepDescent; 
    if (norm(SD) < 1e-10) & neqcstr
      actlambda                = -R\(Q'*(gf));
      lambda(indepInd(ACTIND)) = normf * (actlambda ./ normA(ACTIND));
      ACTIND                   = indepInd(ACTIND);
      output.iterations        = iterations;
      return;
    end
  end

  oldind = 0; 

  % Main loop
  while iterations < maxiter
    iterations = iterations + 1;
    GSD        = A*SD;
    indf       = find((GSD > errnorm * norm(SD))  &  ~aix);
    
    if isempty(indf)
      STEPMIN = 1e16;
      dist    = [];
      ind2    = [];
      ind     = [];
    else
      dist           = abs(cstr(indf)./GSD(indf));
      [STEPMIN,ind2] = min(dist);
      ind2           = find(dist == STEPMIN);
      ind            = indf(min(ind2));
    end
    
    delete_constr = 0;   
    
    if ~isempty(indf) & isfinite(STEPMIN)
      if dirType == NewtonStep
        if STEPMIN > 1
          STEPMIN       = 1;
          delete_constr = 1;
        end
        X = X + STEPMIN*SD;
      else
        X = X + STEPMIN*SD;  
      end              
    else
      if dirType == NewtonStep
        STEPMIN       = 1;
        X             = X + SD;
        delete_constr = 1;
      else
        if (~is_qp & ~LLS) | (dirType == NegCurv)
          if norm(SD) > errnorm
            if normalize < 0
              STEPMIN = abs((X(numberOfVariables)+1e-5)/(SD(numberOfVariables)+eps));
            else 
              STEPMIN = 1e16;
            end
            X        = X+STEPMIN*SD;
            how      = 'unbounded'; 
            exitflag = -1;
          else
            how      = 'ill posed';
            exitflag = -1;
          end
          ACTIND            = indepInd(ACTIND);
          output.iterations = iterations;
          return;
        else
          if is_qp
            projH  = Z'*H*Z; 
            Zgf    = Z'*gf;
            projSD = pinv(projH)*(-Zgf);
          else
            projH  = HZ'*HZ; 
            Zgf    = Z'*gf;
            projSD = pinv(projH)*(-Zgf);
          end
                
          if norm(projH*projSD+Zgf) > 10*eps*(norm(projH) + norm(Zgf))
            if norm(SD) > errnorm
              if normalize < 0
                STEPMIN = abs((X(numberOfVariables)+1e-5)/(SD(numberOfVariables)+eps));
              else 
                STEPMIN = 1e16;
              end
              X        = X + STEPMIN*SD;
              how      = 'unbounded'; 
              exitflag = -1;
            else
              how      = 'ill posed';
              exitflag = -1;
            end
            ACTIND            = indepInd(ACTIND);
            output.iterations = iterations;
            return;
          else
            SD = Z * projSD;
            if gf'*SD > 0
              SD = -SD;
            end
            dirType = 5; % singular
            GSD     = A * SD;
            indf    = find((GSD > errnorm * norm(SD))  &  ~aix);
            if isempty(indf)
              STEPMIN=1;
              delete_constr = 1;
              dist          = [];
              ind2          = [];
              ind           = [];
            else
              dist            = abs(cstr(indf)./GSD(indf));
              [STEPMIN, ind2] = min(dist);
              ind2            = find(dist == STEPMIN);
              ind             = indf(min(ind2));
            end
            if STEPMIN > 1
              STEPMIN       = 1;
              delete_constr = 1;
            end
            X = X + STEPMIN*SD; 
          end
        end
      end
    end
    
    if mod(iterations, 2) == 1
      if iterations > 2
        if max(abs(Xold-X)./(abs(Xold)+1)) < eps
          if length(ACTIND) == length(ACTINDold)
            if norm((ACTIND - ACTINDold), inf) == 0
              actlambda                = -R\(Q'*(gf));
              lambda(indepInd(ACTIND)) = normf * (actlambda ./normA(ACTIND));
              ACTIND                   = indepInd(ACTIND);
              output.iterations        = iterations;
              exitflag                 = -1; 
              return;
            end
          end
        end
      end
      ACTINDold = ACTIND;
      Xold      = X;
    end
    
    if delete_constr
      if ACTCNT>0
        if is_qp
          rlambda = -R\(Q'*(H*X+f));
        elseif LLS
          rlambda = -R\(Q'*(H'*(H*X-f)));
        end
        actlambda       = rlambda;
        actlambda(eqix) = abs(rlambda(eqix));
        indlam          = find(actlambda < 0);
        if (~length(indlam)) 
          lambda(indepInd(ACTIND)) = normf * (rlambda./normA(ACTIND));
          ACTIND                   = indepInd(ACTIND);
          output.iterations        = iterations;
          return;
        end
        lind              = find(ACTIND == min(ACTIND(indlam)));
        lind              = lind(1);
        ACTSET(lind, :)   = [];
        aix(ACTIND(lind)) = 0;
        [Q, R]            = qrdelete(Q, R, lind);
        ACTIND(lind)      = [];
        ACTCNT            = length(ACTIND);
        simplex_iter      = 0;
        ind               = 0;
      else
        output.iterations = iterations;
        return;
      end
      delete_constr = 0;
    end
    
    if normalize < 0
      if X(numberOfVariables, 1) < eps
        ACTIND            = indepInd(ACTIND);
        output.iterations = iterations;
        return;
      end
    end   
    
    if is_qp
      gf = H*X + f;
    elseif LLS
      gf = H'*(H*X - f);
    end
    
    cstr       = A*X - B;
    cstr(eqix) = abs(cstr(eqix));
    if max(cstr) > 1e5 * errnorm
      if max(cstr) > norm(X) * errnorm 
        how      = 'unreliable'; 
        exitflag = -1;
      end
    end
    
    if ind
      aix(ind)        = 1;
      CIND            = length(ACTIND) + 1;
      ACTSET(CIND, :) = A(ind, :);
      ACTIND(CIND)    = ind;
      [m, n]          = size(ACTSET);
      [Q, R]          = qrinsert(Q, R, CIND, A(ind, :)');
      ACTCNT          = length(ACTIND);
    end
    if ~simplex_iter
      [m, n] = size(ACTSET);
      Z      = Q(:, m+1:n);
      if ACTCNT == numberOfVariables - 1
        simplex_iter = 1;
      end
      oldind = 0; 
    else
      rlambda = -R\(Q'*gf);
      if isinf(rlambda(1)) & (rlambda(1) < 0)
        [m, n]  = size(ACTSET);
        rlambda = -(ACTSET + realsqrt(eps)*randn(m,n))'\gf;
      end
      actlambda       = rlambda;
      actlambda(eqix) = abs(actlambda(eqix));
      indlam          = find(actlambda < 0);
      if length(indlam)
        if STEPMIN > errnorm
          [minl, lind] = min(actlambda);
        else
          lind = find(ACTIND == min(ACTIND(indlam)));
        end
        lind              = lind(1);
        ACTSET(lind, :)   = [];
        aix(ACTIND(lind)) = 0;
        [Q, R]            = qrdelete(Q, R, lind);
        Z                 = Q(:, numberOfVariables);
        oldind            = ACTIND(lind);
        ACTIND(lind)      = [];
        ACTCNT            = length(ACTIND);
      else
        lambda(indepInd(ACTIND)) = normf * (rlambda./normA(ACTIND));
        ACTIND                   = indepInd(ACTIND);
        output.iterations        = iterations;
        return;
      end
    end
    
    if (is_qp)
      Zgf = Z'*gf; 
      if ~isempty(Zgf) & (norm(Zgf) < 1e-15)
        SD      = zeros(numberOfVariables,1); 
        dirType = ZeroStep;
      else
        [SD, dirType] = compute_direction(Z, H, gf, numberOfVariables, f);
      end
    elseif LLS
      Zgf = Z' * gf;
      HZ  = H * Z;
      if (norm(Zgf) < 1e-15)
        SD      = zeros(numberOfVariables, 1);
        dirType = ZeroStep;
      else
        HXf      = H*X - f;
        gf       = H' * (HXf);
        [mm, nn] = size(HZ);
        if mm >= nn
          [QHZ, RHZ] = qr(HZ, 0);
          Pd         = QHZ' * HXf;
          if min(size(RHZ))==1
            depInd = find(abs(RHZ(1, 1)) < tolDep);
          else
            depInd = find(abs(diag(RHZ)) < tolDep);
          end  
        end
        if (mm >= nn) & isempty(depInd)
          SD      = - Z*(RHZ(1:nn, 1:nn) \ Pd(1:nn,:));
          dirType = NewtonStep;
        else
          SD      = -Z*(Z'*gf);
          dirType = SteepDescent;
        end
      end
    else
      if ~simplex_iter
        SD     = -Z*(Z'*gf);
        gradsd = norm(SD);
      else
        gradsd = Z'*gf;
        if  gradsd > 0
          SD = -Z;
        else
          SD = Z;
        end
      end
      if abs(gradsd) < 1e-10
        if ~oldind
          rlambda   = -R\(Q'*gf);
          ACTINDtmp = ACTIND;
          Qtmp      = Q;
          Rtmp      = R;
        else
          ACTINDtmp                  = ACTIND;
          ACTINDtmp(lind+1:ACTCNT+1) = ACTIND(lind:ACTCNT);
          ACTINDtmp(lind)            = oldind;
          [Qtmp, Rtmp]               = qrinsert(Q, R, lind, A(oldind, :)');
        end
        actlambda                   = rlambda;
        actlambda(1:neqcstr)        = abs(actlambda(1:neqcstr));
        indlam                      = find(actlambda < errnorm);
        lambda(indepInd(ACTINDtmp)) = normf * (rlambda./normA(ACTINDtmp));
        if ~length(indlam)
          ACTIND            = indepInd(ACTIND);
          output.iterations = iterations;
          return;
        end
        cindmax = length(indlam);
        cindcnt = 0;
        m       = length(ACTINDtmp);
        while (abs(gradsd) < 1e-10) & (cindcnt < cindmax)
          cindcnt = cindcnt + 1;
          lind    = indlam(cindcnt);
          [Q, R]  = qrdelete(Qtmp, Rtmp, lind);
          Z       = Q(:, m:numberOfVariables);
          if m ~= numberOfVariables
            SD     = -Z * Z' *gf;
            gradsd = norm(SD);
          else
            gradsd = Z' * gf;
            if  gradsd > 0
              SD = -Z;
            else
              SD = Z;
            end
          end
        end
        if abs(gradsd) < 1e-10
          ACTIND            = indepInd(ACTIND);
          output.iterations = iterations;
          return;
        else
          ACTIND       = ACTINDtmp;
          ACTIND(lind) = [];
          aix          = zeros(ncstr, 1);
          aix(ACTIND)  = 1;
          ACTCNT       = length(ACTIND);
          ACTSET       = A(ACTIND, :);
        end
        lambda = zeros(ncstr, 1);
      end
    end
  end % Main loop

  if iterations >= maxiter
    exitflag = 0;
    how      = 'ill-conditioned';   
  end

  output.iterations = iterations;

  return;





%%%%%%%%

function [Q, R, A, B, X, Z, how, ACTSET, ACTIND, ACTCNT, aix, eqix, neqcstr, ...
          ncstr, remove, exitflag] = ...
            consolve(A, B, eqix, neqcstr, ncstr, numberOfVariables, LLS, H, ...
                     X, f, normf, normA, aix, ACTSET, ACTIND, ACTCNT, how, exitflag)
%
% CONSOLVE - remove redundant constraints, find feasible point.
%

  tolDep       = 100 * numberOfVariables * eps;      
  tolCons      = 1e-10;
  Z            = [];
  remove       = [];
  [Qa, Ra, Ea] = qr(A(eqix, :));

  if min(size(Ra)) == 1
    depInd = find(abs(Ra(1, 1)) < tolDep);
  else
    depInd = find(abs(diag(Ra)) < tolDep );
  end
  if neqcstr > numberOfVariables
    depInd = [depInd; ((numberOfVariables + 1):neqcstr)'];
  end      

  if ~isempty(depInd)
    how      = 'dependent';
    exitflag = 1;
    bdepInd  =  abs(Qa(:, depInd)'*B(eqix)) >= tolDep ;
    
    if any(bdepInd)
      how      = 'infeasible';   
      exitflag = -1;
    else
      [Qat, Rat, Eat]     = qr(A(eqix, :)');        
      [i,j]               = find(Eat);
      remove              = i(depInd);
      numDepend           = nnz(remove);
      A(eqix(remove), :)  = [];
      B(eqix(remove))     = [];
      neqcstr             = neqcstr - numDepend;
      ncstr               = ncstr - numDepend;
      eqix                = 1:neqcstr;
      aix(remove)         = [];
      ACTIND(1:numDepend) = [];
      ACTIND              = ACTIND - numDepend;      
      ACTSET              = A(ACTIND, :);
      ACTCNT              = ACTCNT - numDepend;
    end
  end

  if ACTCNT >= numberOfVariables
    ACTCNT      = max(neqcstr, numberOfVariables-1);
    ACTIND      = ACTIND(1:ACTCNT);
    ACTSET      = A(ACTIND, :);
    aix         = zeros(ncstr, 1);
    aix(ACTIND) = 1;
  end

  if ACTCNT > neqcstr
    [Qat, Rat, Eat] = qr(ACTSET');
    
    if min(size(Rat)) == 1
      depInd = find(abs(Rat(1,1)) < tolDep);
    else
      depInd = find(abs(diag(Rat)) < tolDep );
    end
    
    if ~isempty(depInd)
      [i, j]     = find(Eat);
      remove2    = i(depInd);
      removeEq   = remove2(find(remove2 <= neqcstr));
      removeIneq = remove2(find(remove2 > neqcstr));
      if ~isempty(removeEq)
        ACTIND = 1:neqcstr; 
      else
        ACTIND(removeIneq) = [];
      end
      aix         = zeros(ncstr, 1);
      aix(ACTIND) = 1;
      ACTSET      = A(ACTIND, :);
      ACTCNT      = length(ACTIND);
    end  
  end

  [Q, R] = qr(ACTSET');
  Z      = Q(:, ACTCNT+1:numberOfVariables);

  if ~strcmp(how, 'infeasible') & (ACTCNT > 0)
    minnormstep = Q(:, 1:ACTCNT) * ((R(1:ACTCNT,1:ACTCNT)') \ (B(ACTIND) - ACTSET*X));
    X           = X + minnormstep; 
    err         = A*X - B;
    err(eqix)   = abs(err(eqix));
    if any(err > eps)
      Xbasic         = ACTSET\B(ACTIND);
      errbasic       = A*Xbasic - B;
      errbasic(eqix) = abs(errbasic(eqix));
      if max(errbasic) < max(err) 
        X = Xbasic;
      end
    end
  end

  return;
