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
            % create dynamics for A(t), B(t)P(t)B'(t) and B(t)p(t)
            %
            self.timeVec = linspace(t0,t1,self.N_TIME_POINTS);
            matOpFactory = MatrixOperationsFactory.create(self.timeVec);
            %
            self.AtDynamics = matOpFactory.fromSymbMatrix(AtDefCMat);
            BtDynamics = matOpFactory.fromSymbMatrix(...
                problemDef.getBMatDef());
            PtDynamics = matOpFactory.fromSymbMatrix(...
                problemDef.getPCMat());
            ptDynamics = matOpFactory.fromSymbMatrix(...
                problemDef.getpCVec());
            self.BPBTransDynamics = matOpFactory.lrMultiply(PtDynamics,...
                BtDynamics, 'L');
            self.BptDynamics = matOpFactory.rMultiplyByVec(BtDynamics,...
                ptDynamics);
            %
            % compute X(t,t0)
            %
            odeArgList=self.getOdePropList(calcPrecision);
            solverObj=MatrixODESolver(sizeAtVec,@ode45,odeArgList{:});
            %
            Xtt0DerivFunc = @(t,x) reshape(...
                self.AtDynamics.evaluate(t)*...
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