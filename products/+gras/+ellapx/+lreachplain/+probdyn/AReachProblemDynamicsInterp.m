classdef AReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    methods
        function self=AReachProblemDynamicsInterp(problemDef,calcPrecision)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.ellapx.lreachplain.probdyn.LReachProblemDynamicsInterp;
            import gras.ode.MatrixODESolver;
            import gras.ellapx.uncertcalc.MatrixOperationsFactory;
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
            solverObj=MatrixODESolver(sizeAtVec,@ode45,odeArgList{:});
            %
            Xtt0DerivFunc = @(t,x) reshape(self.AtDynamics.evaluate(t)*...
                reshape(x,sizeAtVec),[numelAt 1]);
            Xtt0InitialMat = eye(sizeAtVec);
            %
            [timeXtt0Vec,data_Xtt0]=solverObj.solve(Xtt0DerivFunc,...
                self.timeVec,Xtt0InitialMat);
            %
            self.Xtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',data_Xtt0,timeXtt0Vec);
        end
    end
end