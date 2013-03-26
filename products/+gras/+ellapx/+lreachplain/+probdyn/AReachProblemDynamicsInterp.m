classdef AReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    properties (Access = private)
        sizeAtVec = [0 0];
        numelAt = 0;
    end
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
            self.sizeAtVec = size(AtDefCMat);
            self.numelAt = numel(AtDefCMat);
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
            solverObj=MatrixODESolver(self.sizeAtVec,@ode45,odeArgList{:});
            %
            % (temporary) setting algorithm:
            %   0 - X(t, t0) / matrixnorm(X(t, t0))
            %   1 - R(t, t0)
            %   2 - [R(t, t0); matrixnorm(X(t, t0))]
            %
            algorithm = 2;            
            %
            % we can just change Rtt0DerivFunc_body to Xtt0DerivFunc_body
            %
            switch (algorithm)
                case 0
                    Rtt0DerivFunc = @(t,x) self.Xtt0DerivFunc_body(t, x);
                case 1
                    Rtt0DerivFunc = @(t,x) self.Rtt0DerivFunc_body(t, x);
                case 2
                    Rtt0DerivFunc = @(t,x) self.Rtt0ExtDerivFunc_body(t, x);
            end
            %
            switch (algorithm)
                case 0
                    Rtt0InitialMat = eye(self.sizeAtVec);
                case 1
                    Rtt0InitialMat = eye(self.sizeAtVec);
                    Rtt0InitialMat = normaliz(Rtt0InitialMat);
                case 2
                    Rtt0InitialMat = eye(self.sizeAtVec);
                    norm = sqrt(sum(sum(Rtt0InitialMat, 2)));
                    Rtt0InitialMat = normaliz(Rtt0InitialMat);
                    Rtt0InitialMat = [Rtt0InitialMat(:); norm];
            end
            
            %
            [timeRtt0Vec,data_Rtt0]=solverObj.solve(Rtt0DerivFunc,...
                self.timeVec,Rtt0InitialMat);
            %
            % the code here is control code (just calculates X(t, t0) and
            % then divide it by matrixnorm(X(t,t0))
            %
            switch (algorithm)
                case 0
                    data_Rtt0 = normaliz(data_Rtt0);
                case 2
                    sz = size(data_Rtt0);
                    normVec = data_Rtt0(sz(1), :);
                    data_Rtt0(sz(1), :) = [];
                    data_Rtt0 = reshape(data_Rtt0, [dyn_interp.sizeAtVec, dyn_interp.sizeAtVec, self.N_TIME_POINTS]);
            end
            %
            self.Xtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',data_Rtt0,timeRtt0Vec);
        end
    end
    
    methods (Access = private)
        %
        % new equation for R(t, t0) and norm(X(t, t0))(t)
        %
        function dx = Rtt0ExtDerivFunc_body(dyn_interp, t, x)
            norm = x(length(x)); x(length(x)) = [];
            Rtt0Mat = reshape(x, dyn_interp.sizeAtVec);
            %
            cachedMat = dyn_interp.AtDynamics.evaluate(t) * Rtt0Mat;
            %
            dnorm = sum(Rtt0Mat(:) .* cachedMat(:)) * norm;
            dRtt0Mat = cachedMat - Rtt0Mat * sum(Rtt0Mat(:) .* cachedMat(:));
            dx = reshape(dRtt0Mat, [dyn_interp.numelAt 1]);
            %
            dx = [dx; dnorm];
            %
        end
        %
        % new equation for R(t, t0)
        %
        function dx = Rtt0DerivFunc_body(dyn_interp, t, x)
            %
            Rtt0Mat = reshape(x, dyn_interp.sizeAtVec);
            cachedMat = dyn_interp.AtDynamics.evaluate(t) * Rtt0Mat;
            %
            dRtt0Mat = cachedMat - Rtt0Mat * sum(Rtt0Mat(:) .* cachedMat(:));
            dx = reshape(dRtt0Mat, [dyn_interp.numelAt 1]);
            %
        end
        %
        % old equation for X(t, t0)
        %
        function dx = Xtt0DerivFunc_body(dyn_interp, t, x)
            %
            Xtt0 = reshape(x, dyn_interp.sizeAtVec);
            dXtt0 = dyn_interp.AtDynamics.evaluate(t) * Xtt0;
            dx = reshape(dXtt0, [dyn_interp.numelAt 1]);
            %
        end
    end
end

%
% normalizes matrix A (matrixnorm(nA) = 1)
%
function nA = normaliz(A)
    szVec = size(A);
    normMat = A .* A;
    normMat = sum(normMat, 2);
    normMat = sum(normMat, 1);
    normMat = sqrt(normMat);
    switch (length(szVec))
        case 2
            nA = A / normMat;
        case 3
            normMat = repmat(normMat, [szVec(1), szVec(2), 1]);
            nA = A ./ normMat;
    end
end



