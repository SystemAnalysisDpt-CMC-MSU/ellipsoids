classdef AReachProblemDynamicsInterp<...
        gras.ellapx.lreachplain.probdyn.AReachProblemDynamics
    methods
        function self=AReachProblemDynamicsInterp(problemDef,calcPrecision)
            % that isn't good
            global global_AtDyn global_sizeAtVec global_numelAt;
            
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
            solverObj=MatrixODESolver(sizeAtVec,@ode45,odeArgList{:});
            %
            % old code will be here for some time
            %
            %Xtt0DerivFunc = @(t,x) reshape(self.AtDynamics.evaluate(t)*...
                %reshape(x,sizeAtVec),[numelAt 1]);
            %
            % set global variables
            %
            global_AtDyn = @(t) self.AtDynamics.evaluate(t);
            global_sizeAtVec = sizeAtVec;
            global_numelAt = numelAt;
            %
            Rtt0DerivFunc = @(t,x) Rtt0DerivFunc_body(t, x);
            %            
            Rtt0InitialMat = eye(sizeAtVec);
            Rtt0InitialMat = Rtt0InitialMat / sqrt(sum(Rtt0InitialMat(:)));
            %
            [timeRtt0Vec,data_Rtt0]=solverObj.solve(Rtt0DerivFunc,...
                self.timeVec,Rtt0InitialMat);
            %
            self.Xtt0Dynamics=MatrixInterpolantFactory.createInstance(...
                'column',data_Rtt0,timeRtt0Vec);
        end
    end
end

function dx = Rtt0DerivFunc_body(t, x)
    global global_AtDyn global_sizeAtVec global_numelAt;
    %
    Rtt0Mat = reshape(x, global_sizeAtVec);
    cachedMat = global_AtDyn(t) * Rtt0Mat;
    %
    dRtt0Mat = cachedMat - Rtt0Mat * sum(Rtt0Mat(:) .* cachedMat(:));
    dx = reshape(dRtt0Mat, [global_numelAt 1]);
    
    %Xtt0 = reshape(x, global_sizeAtVec);
    %dXtt0 = global_AtDyn(t) * Xtt0;
    %dx = reshape(dXtt0, [global_numelAt 1]);
end