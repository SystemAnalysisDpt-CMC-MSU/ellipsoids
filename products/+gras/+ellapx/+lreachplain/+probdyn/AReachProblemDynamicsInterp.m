classdef AReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    methods
        function self=AReachProblemDynamicsInterp(problemDef,calcPrecision)          
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.ellapx.lreachplain.probdyn.LReachProblemDynamicsInterp;
            import gras.ode.MatrixODESolver;
            import gras.mat.MatrixOperationsFactory;
            %
            self.problemDef = problemDef;
            %
            % copy necessary data to local variables
            %
            AtDefCMat = problemDef.getAMatDef();
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            sizeAtVec = size(AtDefCMat);
            numelAt = numel(AtDefCMat);
            %
            self.timeVec = linspace(t0,t1,self.N_TIME_POINTS);
            %
            % create dynamics for A(t), B(t)P(t)B'(t) and B(t)p(t)
            %
            matOpFactory = MatrixOperationsFactory.create(self.timeVec);
            %
            self.AtDynamics = matOpFactory.fromSymbMatrix(AtDefCMat);
            BtDefCMat = problemDef.getBMatDef();
            self.BPBTransDynamics = matOpFactory.rSymbMultiply(...
                BtDefCMat, problemDef.getPCMat(), BtDefCMat.');
            self.BptDynamics = matOpFactory.rSymbMultiplyByVec(...
                BtDefCMat, problemDef.getpCVec());
            %
            % compute X(t,t0)
            %
            odeArgList=self.getOdePropList(calcPrecision);
            %
            % (temporary) setting algorithm:
            %   0 - X(t, t0)
            %   1 - X(t, t0) / matrixnorm(X(t, t0))
            %   2 - R(t, t0)
            %   3 - [R(t, t0); matrixnorm(X(t, t0))]
            %
            algorithm = 2;
            %
            % the code here is a control code
            %
            if (algorithm == 3)
                solverObj=MatrixODESolver([numelAt + 1, 1],@ode45,odeArgList{:});
            else
                solverObj=MatrixODESolver(sizeAtVec,@ode45,odeArgList{:});
            end            
            %
            % the code here is a control code
            %
            switch (algorithm)
                case 0
                    fRtt0DerivFunc = @(t,x) fXtt0DerivFunc(t, x, @(u) self.AtDynamics.evaluate(u));
                case 1
                    fRtt0DerivFunc = @(t,x) fXtt0DerivFunc(t, x, @(u) self.AtDynamics.evaluate(u));
                case 2
                    fRtt0DerivFunc = @(t,x) fRtt0SimDerivFunc(t, x, @(u) self.AtDynamics.evaluate(u));
                case 3
                    fRtt0DerivFunc = @(t,x) fRtt0ExtDerivFunc(t, x, @(u) self.AtDynamics.evaluate(u), sizeAtVec);
            end
            %
            % the code here is a control code
            %
            switch (algorithm)
                case 0
                    sRtt0InitialMat = eye(sizeAtVec);
                case 1
                    sRtt0InitialMat = eye(sizeAtVec);
                case 2
                    sRtt0InitialMat = eye(sizeAtVec);
                    sRtt0InitialMat = normaliz(sRtt0InitialMat);
                case 3
                    sRtt0InitialMat = eye(sizeAtVec);
                    norm = sqrt(sum(sum(sRtt0InitialMat, 2)));
                    sRtt0InitialMat = normaliz(sRtt0InitialMat);
                    sRtt0InitialMat = [sRtt0InitialMat(:); norm];
            end
            %
            [timeRtt0Vec,dataRtt0Array]=solverObj.solve(fRtt0DerivFunc,...
                self.timeVec,sRtt0InitialMat);
            %
            % the code here is a control code
            %
            switch (algorithm)
                case 1
                    dataRtt0Array = normaliz(dataRtt0Array);
                case 3
                    sz = size(dataRtt0Array);
                    normVec = dataRtt0Array(sz(1), sz(2), :);
                    normVec = repmat(normVec, [sizeAtVec, 1]);
                    dataRtt0Array = dataRtt0Array(1:(sz(1) - 1), :, :);
                    dataRtt0Array = reshape(dataRtt0Array, [sizeAtVec, self.N_TIME_POINTS]);
                    dataRtt0Array = dataRtt0Array .* normVec;
            end
            %
            self.Xtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',dataRtt0Array,timeRtt0Vec);
        end
    end
end

%
% new equation for R(t, t0) and matrixnorm(X(t, t0))
%
function dx = fRtt0ExtDerivFunc(t, x, fAt, sizeAtVec)
    norm = x(length(x)); x(length(x)) = [];
    sRtt0Mat = reshape(x, sizeAtVec);
    %
    cachedMat = fAt(t) * sRtt0Mat;
    scprod = sum(sRtt0Mat(:) .* cachedMat(:));
    %
    dnorm = scprod * norm;
    dsRtt0Mat = cachedMat - sRtt0Mat * scprod;
    %
    dx = [dsRtt0Mat(:); dnorm];
end
%
% new equation for R(t, t0)
%
function dx = fRtt0SimDerivFunc(t, x, fAt)
    cachedMat = fAt(t) * x;
    %
    dx = cachedMat - x * sum(x(:) .* cachedMat(:));
end
%
% old equation for X(t, t0)
%
function dx = fXtt0DerivFunc(t, x, fAt)
    dx = fAt(t) * x;
end

%
% normalizes matrix argMat (matrixnorm(normalizMat) = 1)
%
function normalizMat = normaliz(argMat)
    szVec = size(argMat);
    normMat = argMat .* argMat;
    normMat = sqrt(sum(sum(normMat, 2), 1));
    if (length(szVec) > 2)
        szVec(3:length(szVec)) = 1;
    end
    normMat = repmat(normMat, szVec);
    normalizMat = argMat ./ normMat;
end