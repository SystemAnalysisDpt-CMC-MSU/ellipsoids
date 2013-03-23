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
            % old code will be here for some time
            %
            %Xtt0DerivFunc = @(t,x) reshape(self.AtDynamics.evaluate(t)*...
                %reshape(x,sizeAtVec),[numelAt 1]);
            %
            Rtt0DerivFunc = @(t,x) self.Rtt0DerivFunc_body(t, x);
            %            
            Rtt0InitialMat = eye(self.sizeAtVec);
            Rtt0InitialMat = normaliz(Rtt0InitialMat);
            %
            [timeRtt0Vec,data_Rtt0]=solverObj.solve(Rtt0DerivFunc,...
                self.timeVec,Rtt0InitialMat);
            %
            % the code here is control code (just calculates X(t, t0) and
            % then divide it by matrixnorm(X(t,t0))
            %
            %data_Rtt0 = normaliz(data_Rtt0);
            %
            self.Xtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',data_Rtt0,timeRtt0Vec);
        end
    end
    
    methods (Access = private)
        function dx = Rtt0DerivFunc_body(dyn_interp, t, x)
            %
            Rtt0Mat = reshape(x, dyn_interp.sizeAtVec);
            cachedMat = dyn_interp.AtDynamics.evaluate(t) * Rtt0Mat;
            %
            dRtt0Mat = cachedMat - Rtt0Mat * sum(Rtt0Mat(:) .* cachedMat(:));
            dx = reshape(dRtt0Mat, [dyn_interp.numelAt 1]);
            %
        end
        function dx = Xtt0DerivFunc_body(dyn_interp, t, x)
            %
            Xtt0 = reshape(x, dyn_interp.sizeAtVec);
            dXtt0 = dyn_interp.AtDynamics.evaluate(t) * Xtt0;
            dx = reshape(dXtt0, [dyn_interp.numelAt 1]);
            %
        end
    end
end

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



