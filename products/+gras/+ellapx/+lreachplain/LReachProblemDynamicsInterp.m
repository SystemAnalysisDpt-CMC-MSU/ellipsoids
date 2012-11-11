classdef LReachProblemDynamicsInterp<gras.ellapx.lreachplain.IReachProblemDynamics
    properties (Access=private)
        problemDef
        AtSpline
        BptSpline
        xtSpline
        BPBTransSpline
        Xtt0Spline
        timeVec
    end
    properties (Constant,GetAccess=private)
        N_TIME_POINTS=1000;
    end    
    methods
        function BPBTransDynamics=getBPBTransDynamics(self)
            BPBTransDynamics=self.BPBTransSpline;
        end
        function AtDynamics=getAtDynamics(self)
            AtDynamics=self.AtSpline;
        end
        function BptDynamics=getBptDynamics(self)
            BptDynamics=self.BptSpline;
        end        
        function xtDynamics=getxtDynamics(self)
            xtDynamics=self.xtSpline;
        end
        function Xtt0Dynamics=getXtt0Dynamics(self)
            Xtt0Dynamics=self.Xtt0Spline;
        end
        function timeVec=getTimeVec(self)
            timeVec=self.timeVec;
        end             
        function sysDim=getDimensionality(self)
            sysDim=self.problemDef.getDimensionality();
        end           
        function X0Mat=getX0Mat(self)
            X0Mat=self.problemDef.getX0Mat();
        end
        function x0Vec=getx0Vec(self)
            x0Vec=self.problemDef.getx0Vec();
        end
        function tLims=getTimeLimsVec(self)
            tLims=self.problemDef.getTimeLimsVec();
        end
        function t0=gett0(self)
            t0=self.problemDef.gett0();
        end
        function t1=gett1(self)
            t1=self.problemDef.gett1();
        end
    end
    methods (Static,Access=private)
        function res=R_Xtt0(At,t,x)
            import gras.gen.SquareMatVector;
            res=reshape(SquareMatVector.fromFormulaMat(At,t)*...
                reshape(x,size(At)),[numel(At) 1]);
        end
        function res=R_xt(AtSpline,BptSpline,t,y)
            res=AtSpline.evaluate(t)*y+BptSpline.evaluate(t);
        end
    end
    methods
        function self=LReachProblemDynamicsInterp(problemDef,calcPrecision)      
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.interp.MatrixSymbInterpFactory;
            %
            import gras.gen.SquareMatVector;
            import gras.ellapx.lreachplain.LReachProblemDynamicsInterp;
            import gras.ode.MatrixODESolver;
            %
            if ~isa(problemDef, 'IReachContProblemDef') 
                modgen.common.throwerror('LReachProblemDynamicsInterp:WrongInput', 'Incorrect system definition');
            end        
            self.problemDef = problemDef;
            %            
            ODE_NORM_CONTROL='on';
            %
            nTimePoints=LReachProblemDynamicsInterp.N_TIME_POINTS;
            odeArgList={'NormControl',ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            %
            AtDefMat = problemDef.getAMatDef();
            BtDefMat = problemDef.getBMatDef();
            PtDefMat = problemDef.getPCMat();
            ptDefVec = problemDef.getpCVec();
            x0DefVec = problemDef.getx0Vec();
            t0 = problemDef.gett0();
            t1 = problemDef.gett1();
            %
            sysDim = size(AtDefMat, 1);
            tVec = linspace(t0,t1,nTimePoints);
            %
            %% Creating Xtt0Spline
            %
            solverObj=MatrixODESolver([sysDim,sysDim],@ode45,...
                odeArgList{:});
            fHandleR_Xtt0=@(t,x)LReachProblemDynamicsInterp.R_Xtt0(AtDefMat,t,x);
            [timeXtt0Vec,data_Xtt0]=solverObj.solve(fHandleR_Xtt0,tVec,...
                eye(sysDim));
            %
            self.Xtt0Spline=MatrixInterpolantFactory.createInstance(...
                'column',data_Xtt0,timeXtt0Vec);
            %% Creating AtSpline BPBTransSpline BptSpline
            self.AtSpline=MatrixSymbInterpFactory.single(AtDefMat);
            %
            self.BPBTransSpline=MatrixSymbInterpFactory.rMultiply(...
                BtDefMat,PtDefMat,BtDefMat.');
            self.BptSpline=MatrixSymbInterpFactory.rMultiplyByVec(...
                BtDefMat,ptDefVec);
            %
            %% Creating xtSpline
            solverObj=MatrixODESolver(sysDim,@ode45,odeArgList{:});
            fHandleR_xt=@(t,x)LReachProblemDynamicsInterp.R_xt(...
                self.AtSpline,...
                self.BptSpline,t,x);
            [timeXtVec,xtArray]=solverObj.solve(fHandleR_xt,tVec,x0DefVec);
            %
            self.xtSpline=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end