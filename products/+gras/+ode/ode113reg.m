function [tout,yout,dyRegMat] = ode113reg(fOdeDeriv,fOdeReg,tspan,y0,...
    options,varargin)

import modgen.common.throwerror;
import modgen.common.type.simple.*;

solver_name = 'ode113reg';
% Constants
N_MAX_REG_STEPS_DEFAULT=3;
N_PROGRESS_DOTS_SHOWN=10;


if nargin < 4
    options = [];
    if nargin < 3
        throwerror('wrongInput','not enough input arguments');
    end
end

% Stats
nsteps  = 0;
nfailed = 0;
nfevals = 0;

[opts,~,regMaxStepTol,regAbsTol,nMaxRegSteps,isRegMaxStepTolSpec,...
    isRegAbsTolSpec]=modgen.common.parseparext(varargin,...
    {'regMaxStepTol','regAbsTol','nMaxRegSteps';...
    [],[],N_MAX_REG_STEPS_DEFAULT;...
    'isnumeric(x)','isnumeric(x)','isnumeric(x)'});
options=odeset(options,opts{:});

checkgen(fOdeDeriv,'isfunction(x)');
checkgen(fOdeReg,'isfunction(x)');
%checkvar!!!

sol = []; klastvec = []; phi3d = []; psi2d = [];

% Handle solver arguments
[neq, tspan, ntspan, next, t0, tfinal, y0, f0, ...
    options, threshold, rtol, normcontrol, normy, hmax, htry, htspan,...
    dataType,absTol] = ...
    odearguments(solver_name,fOdeDeriv, tspan, y0, options);
if ~isRegMaxStepTolSpec
    regMaxStepTol=absTol*10;
end
if ~isRegAbsTolSpec
    regAbsTol=256*eps(dataType);
end
nfevals = nfevals + 1;
prDispObj=gras.gen.ProgressCmdDisplayer(t0,tfinal,...
    N_PROGRESS_DOTS_SHOWN,modgen.common.getcallername());
prDispObj.start();

% Handle the output
refine = max(1,odeget(options,'Refine',4,'fast'));
if ntspan > 2
    outputAt = 'RequestedPoints';         % output only at tspan points
elseif refine <= 1
    outputAt = 'SolverSteps';             % computed points, no refinement
else
    outputAt = 'RefinedSteps';            % computed points, with refinement
    S = (1:refine-1) / refine;
end

t = t0;
y = y0;
yp = f0;

% Allocate memory if we're generating output.
nout = 0;
tout = []; yout = [];
if ntspan > 2                         % output only at tspan points
    tout = zeros(1,ntspan,dataType);
    yout = zeros(neq,ntspan,dataType);
    dyRegMat=yout;
else                                  % alloc in chunks
    chunk = min(max(100,50*refine), refine+floor((2^13)/neq));
    tout = zeros(1,chunk,dataType);
    yout = zeros(neq,chunk,dataType);
    dyRegMat=yout;
end
nout = 1;
tout(nout) = t;
yout(:,nout) = y;

% Initialize method parameters.
maxk = 12;
two = 2 .^ (1:13)';
gstar = [ 0.5000;  0.0833;  0.0417;  0.0264;  ...
    0.0188;  0.0143;  0.0114;  0.00936; ...
    0.00789;  0.00679; 0.00592; 0.00524; 0.00468];

hmin = 16*eps(t);
if isempty(htry)
    % Compute an initial step size h using y'(t).
    absh = min(hmax, htspan);
    if normcontrol
        rh = (norm(yp) / max(normy,threshold)) / (0.25 * realsqrt(rtol));
    else
        rh = norm(yp ./ max(abs(y),threshold),inf) / (0.25 * realsqrt(rtol));
    end
    if absh * rh > 1
        absh = 1 / rh;
    end
    absh = max(absh, hmin);
else
    absh = min(hmax, max(hmin, htry));
end

% Initialize.
k = 1;
K = 1;
phi = zeros(neq,14,dataType);
phi(:,1) = yp;
psi = zeros(12,1,dataType);
alpha = zeros(12,1,dataType);
beta = zeros(12,1,dataType);
sig = zeros(13,1,dataType);
sig(1) = 1;
w = zeros(12,1,dataType);
v = zeros(12,1,dataType);
g = zeros(13,1,dataType);
g(1) = 1;
g(2) = 0.5;

hlast = 0;
klast = 0;
phase1 = true;

% THE MAIN LOOP
dyNewCorrVec=zeros(neq,1,dataType);
isDone = false;
while ~isDone
    
    % By default, hmin is a small number such that t+hmin is only slightly
    % different than t.  It might be 0 if t is 0.
    hmin = 16*eps(t);
    absh = min(hmax, max(hmin, absh));    % couldn't limit absh until new hmin
    h = absh;
    
    % Stretch the step if within 10% of tfinal-t.
    if 1.1*absh >= abs(tfinal - t)
        h = tfinal - t;
        absh = abs(h);
        isDone = true;
    end
    
    % LOOP FOR ADVANCING ONE STEP.
    failed = 0;
    if normcontrol
        invwt = 1 / max(norm(y),threshold);
    else
        invwt = 1 ./ max(abs(y),threshold);
    end
    
    dpNewCorrVec=dyNewCorrVec;
    dyNewCorrVec=zeros(neq,1,dataType);
    iRegStep = 0;

    while true
        
        % Compute coefficients of formulas for this step.  Avoid computing
        % those quantities not changed when step size is not changed.
        
        % ns is the number of steps taken with h, including the
        % current one.  When k < ns, no coefficients change
        prDispObj.progress(t);
        if iRegStep==0
            dpNewCorrVec=dyNewCorrVec;
            dyNewCorrVec=zeros(neq,1,dataType);
        end
        isRejectedStep=false;
        if h ~= hlast
            ns = 0;
        end
        if ns <= klast
            ns = ns + 1;
        end
        if k >= ns
            beta(ns) = 1;
            alpha(ns) = 1 / ns;
            temp1 = h * ns;
            sig(ns+1) = 1;
            for i = ns+1:k
                temp2 = psi(i-1);
                psi(i-1) = temp1;
                temp1 = temp2 + h;
                
                beta(i) = beta(i-1) * psi(i-1) / temp2;
                alpha(i) = h / temp1;
                sig(i+1) = i * alpha(i) * sig(i);
            end
            psi(k) = temp1;
            
            % Compute coefficients g.
            if ns == 1                        % Initialize v and set w
                v = 1 ./ (K .* (K + 1));
                w = v;
            else
                % If order was raised, update diagonal part of v.
                if k > klast
                    v(k) = 1 / (k * (k+1));
                    for j = 1:ns-2
                        v(k-j) = v(k-j) - alpha(j+1) * v(k-j+1);
                    end
                end
                % Update v and set w.
                for iq = 1:k+1-ns
                    v(iq) = v(iq) - alpha(ns) * v(iq+1);
                    w(iq) = v(iq);
                end
                g(ns+1) = w(1);
            end
            
            % Compute g in the work vector w.
            for i = ns+2:k+1
                for iq = 1:k+2-i
                    w(iq) = w(iq) - alpha(i-1) * w(iq+1);
                end
                g(i) = w(1);
            end
        end
        % Change phi to phi star.
        phi(:, k) = phi(:, k) + dpNewCorrVec;
        i = ns+1:k;
        phi(:,i) = phi(:,i) * diag(beta(i));
        
        % Predict solution and differences.
        phi(:,k+2) = phi(:,k+1);
        phi(:,k+1) = zeros(neq,1,dataType);
        p = zeros(neq,1,dataType);
        
        for i = k:-1:1
            p = p + g(i) * phi(:,i);
            phi(:,i) = phi(:,i) + phi(:,i+1);
        end

        p = y + h * p;
        [isStrictViol, pRegNew] = fOdeReg(t, p);
        pCurCorrVec = pRegNew - p;
        errReg = max(abs(pCurCorrVec));
        isWeakViol=errReg>=regAbsTol;
        if isStrictViol
            isRejectedStep=true;
        elseif isWeakViol
            if errReg>regMaxStepTol
                isRejectedStep = true;
            end
            dpCurCorrVec=pCurCorrVec./(h*g(k)*beta(k)); 
        end
        
        tlast = t;
        t = tlast + h;
        if isDone
            t = tfinal;   % Hit end point exactly.
        end
        
        % Estimate errors at orders k, k-1, k-2.
        if ~isRejectedStep
            yp = feval(fOdeDeriv,t,p);
            nfevals = nfevals + 1;
  
            phikp1 = yp - phi(:,1) + dyNewCorrVec;
            if normcontrol
                temp3 = norm(phikp1) * invwt;
                err = absh * (g(k) - g(k+1)) * temp3;
                erk = absh * sig(k+1) * gstar(k) * temp3;
                if k >= 2
                    erkm1 = absh * sig(k) * gstar(k-1) * ...
                        (norm(phi(:,k)+phikp1) * invwt);
                else
                    erkm1 = 0.0;
                end
                if k >= 3
                    erkm2 = absh * sig(k-1) * gstar(k-2) * ...
                        (norm(phi(:,k-1)+phikp1) * invwt);
                else
                    erkm2 = 0.0;
                end
            else
                temp3 = norm(phikp1 .* invwt,inf);
                err = absh * (g(k) - g(k+1)) * temp3;
                erk = absh * sig(k+1) * gstar(k) * temp3;
                if k >= 2
                    erkm1 = absh * sig(k) * gstar(k-1) * ...
                        norm((phi(:,k)+phikp1) .* invwt,inf);
                else
                    erkm1 = 0.0;
                end
                if k >= 3
                    erkm2 = absh * sig(k-1) * gstar(k-2) * ...
                        norm((phi(:,k-1)+phikp1) .* invwt,inf);
                else
                    erkm2 = 0.0;
                end
            end
        end   
        % Test if order should be lowered
        knew = k;
        if (k == 2) && (erkm1 <= 0.5*erk)
            knew = k - 1;
        end
        if (k > 2) && (max(erkm1,erkm2) <= erk)
            knew = k - 1;
        end
        % Test if step successful
        isFailedStep = isRejectedStep||(err>rtol);
        if isFailedStep                      % Failed step
            nfailed = nfailed + 1;
            if absh <= hmin
                messageObj=message('MATLAB:ode45:IntegrationTolNotMet', ...
                    sprintf( '%e', t ), sprintf( '%e', hmin ));
                if isRejectedStep
                    error(messageObj);
                else
                    warning(messageObj);
                end
                shrinkResults();
                prDispObj.finish();
                return;
            end
            
            % Restore t, phi, and psi.
            iRegStep = 0;
            phase1 = false;
            t = tlast;
            for i = K
                phi(:,i) = (phi(:,i) - phi(:,i+1));
            end
    
            for i = K
                phi(:, i) = phi(:, i) ./ beta(i);
            end
            phi(:, k) = phi(:, k) - dpNewCorrVec;
            for i = 2:k
                psi(i-1) = psi(i) - h;
            end
            
            failed = failed + 1;
            reduce = 0.5;
            if failed == 3
                knew = 1;
            elseif failed > 3
                reduce = min(0.5, realsqrt(0.5*rtol/erk));
            end
            absh = max(reduce * absh, hmin);
            h = absh;
            k = knew;
            K = 1:k;
            isDone = false;
            
        else
            if isWeakViol
                t = tlast;
                for i = K
                    phi(:,i) = (phi(:,i) - phi(:,i+1));
                end
                
                for i = K
                    phi(:, i) = phi(:, i) ./ beta(i);
                end
                phi(:, k) = phi(:, k) - dpNewCorrVec;
                for i = 2:k
                    psi(i-1) = psi(i) - h;
                end
  
                iRegStep=iRegStep+1;
                dpNewCorrVec=dpNewCorrVec+dpCurCorrVec;
            else

            % Successful step
                ylast = y;
                y = p + h * g(k+1) * phikp1;
   
                [isStrictViol, yRegNew] = fOdeReg(t,y);
                yCurCorrVec = yRegNew - y;
                errReg = max(abs(yCurCorrVec));
                isWeakViol=errReg>=regAbsTol;

                if isStrictViol
                    isRejectedStep = true;
                elseif isWeakViol
                    if errReg>regMaxStepTol
                        isRejectedStep = true;
                    end
                    dyCurCorrVec=yCurCorrVec./(h*g(k+1));
                end

                
                if isRejectedStep
                    if absh <= hmin
                        warning(message('MATLAB:ode45:IntegrationTolNotMet', ...
                            sprintf( '%e', t ), sprintf( '%e', hmin )));
                        shrinkResults();
                        prDispObj.finish();
                        return;
                    end
                    % Restore t, phi, and psi.
                    iRegStep = 0;
                    phase1 = false;
                    y = ylast;
                    t = tlast;
                    for i = K
                        phi(:,i) = (phi(:,i) - phi(:,i+1));
                    end
                    
                    for i = K
                        phi(:, i) = phi(:, i) ./ beta(i);
                    end
                    phi(:, k) = phi(:, k) - dpNewCorrVec;
                    for i = 2:k
                        psi(i-1) = psi(i) - h;
                    end
                    dpNewCorrVec=zeros(neq,1,dataType);
                    failed = failed + 1;
                    reduce = 0.5;
                    if failed == 3
                        knew = 1;
                    elseif failed > 3
                        reduce = min(0.5, realsqrt(0.5*rtol/erk));
                    end
                    absh = max(reduce * absh, hmin);
                    h = absh;
                    k = knew;
                    K = 1:k;
                    isDone = false;

                else
                    if isWeakViol
                        t = tlast;
                        y = ylast;
                        for i = K
                            phi(:,i) = (phi(:,i) - phi(:,i+1));
                        end
                        
                        for i = K
                            phi(:, i) = phi(:, i) ./ beta(i);
                        end
                        phi(:, k) = phi(:, k) - dpNewCorrVec;
                        for i = 2:k
                            psi(i-1) = psi(i) - h;
                        end
                        
                        dyNewCorrVec=dyNewCorrVec+dyCurCorrVec;
                    else
                        break;
                    end
                end
            end  
        end
    end
    
    nsteps = nsteps + 1;
    
    klast = k;
    hlast = h;


    y = yRegNew;
    yp = feval(fOdeDeriv,t,y);%
    nfevals = nfevals + 1;

    % Update differences for next step.
    phi(:,k+1) = yp - phi(:,1);
 
    phi(:,k+2) = phi(:,k+1) - phi(:,k+2);
    for i = K
        phi(:,i) = phi(:,i) + phi(:,k+1);
    end
    
    if (knew == k-1) || (k == maxk)
        phase1 = false;
    end
    
    % Select a new order.
    kold = k;
    if phase1                             % Always raise the order in phase1
        k = k + 1;
    elseif knew == k-1                    % Already decided to lower the order
        k = k - 1;
        erk = erkm1;
    elseif k+1 <= ns                      % Estimate error at higher order
        if normcontrol
            erkp1 = absh * gstar(k+1) * (norm(phi(:,k+2)) * invwt);
        else
            erkp1 = absh * gstar(k+1) * norm(phi(:,k+2) .* invwt,inf);
        end
        if k == 1
            if erkp1 < 0.5*erk
                k = k + 1;
                erk = erkp1;
            end
        else
            if erkm1 <= min(erk,erkp1)
                k = k - 1;
                erk = erkm1;
            elseif (k < maxk) && (erkp1 < erk)
                k = k + 1;
                erk = erkp1;
            end
        end
    end
    if k ~= kold
        K = 1:k;
    end
    
    
    switch outputAt
        case 'SolverSteps'        % computed points, no refinement
            nout_new = 1;
            tout_new = t;
            yout_new = y;
        case 'RefinedSteps'       % computed points, with refinement
            tref = tlast + (t-tlast)*S;
            nout_new = refine;
            tout_new = [tref, t];
            % yout_new = [ntrp113(tref,t,y,klast,phi,psi, fOdeReg), y];
            yout_new = [ntrp113(tref,t,y,klast,phi,psi, fOdeReg), y];
            
        case 'RequestedPoints'    % output only at tspan points
            nout_new =  0;
            tout_new = [];
            yout_new = [];
            while next <= ntspan
                if (t - tspan(next)) < 0
                    break;
                end
                nout_new = nout_new + 1;
                tout_new = [tout_new, tspan(next)];
                if tspan(next) == t
                    yout_new = [yout_new, y];
                else
                    % yout_new = [yout_new, ntrp113(tspan(next),t,y,klast,phi,psi,...
                    %             fOdeReg)];
                    yout_new = [yout_new, ntrp113(tspan(next),t,y,klast,phi,psi, fOdeReg)];
                    
                end
                next = next + 1;
            end
    end
    
    
    if nout_new > 0
        oldnout = nout;
        nout = nout + nout_new;
        if nout > length(tout)
            tout = [tout, zeros(1,chunk,dataType)];  % requires chunk >= refine
            yout = [yout, zeros(neq,chunk,dataType)];
            dyRegMat = [dyRegMat, zeros(neq,chunk,dataType)];
        end
        idx = oldnout+1:nout;
        rind = oldnout+2:nout+1;
        tout(idx) = tout_new;
        yout(:,idx) = yout_new;

        dyRegMat(:,idx)=repmat(dyNewCorrVec ,1,nout_new);
    end
    
    if isDone
        break
    end
    
    % Select a new step size.
    if phase1
        absh = 2 * absh;
    elseif 0.5*rtol >= erk*two(k+1)
        absh = 2 * absh;
    elseif 0.5*rtol < erk
        reduce = (0.5 * rtol / erk)^(1 / (k+1));
        absh = absh * max(0.5, min(0.9, reduce));
    end
    
end

shrinkResults();
prDispObj.finish();
    function shrinkResults()
        tout = tout(1:nout).';
        yout = yout(:,1:nout).';
        dyRegMat = dyRegMat(:,1:nout).';
    end

end

function yinterp = ntrp113(tinterp,tnew,ynew,klast,phi,psi,fOdeReg)

yinterp = zeros(size(ynew,1),length(tinterp));
ki = klast + 1;
KI = 1:ki;
hinterp = tinterp - tnew;

for k = 1:length(tinterp)
    hi = hinterp(k);
    
    w = 1 ./ (1:13)';
    g = zeros(13,1);
    rho = zeros(13,1);
    g(1) = 1;
    rho(1) = 1;
    term = 0;
    for j = 2:ki
        gamma = (hi + term) / psi(j-1);
        eta = hi / psi(j-1);
        for i = 1:ki+1-j
            w(i) = gamma * w(i) - eta * w(i+1);
        end
        g(j) = w(1);
        rho(j) = gamma * rho(j-1);
        term = psi(j-1);
    end
    [~, yinterp(:,k)] = fOdeReg(tinterp, ynew + hi * phi(:,KI) * g(KI));
end

end