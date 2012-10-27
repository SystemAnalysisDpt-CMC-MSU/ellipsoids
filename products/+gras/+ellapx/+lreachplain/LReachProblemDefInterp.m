classdef LReachProblemDefInterp<handle
    properties (Access=private)
        AtSpline
        BptSpline
        xtSpline
        BPBTransSpline
        Xtt0Spline
        X0Mat
        x0Vec
        t0
        t1
        timeVec
        sysDim
    end
    properties (Constant,GetAccess=private)
        N_TIME_POINTS=1000;
    end    
    methods
        function sysDim=getDimensionality(self)
            sysDim=self.sysDim;
        end
        function BPBTransSpline=getBPBTransSpline(self)
            BPBTransSpline=self.BPBTransSpline;
        end
        function timeVec=getTimeVec(self)
            timeVec=self.timeVec;
        end
        function AtSpline=getAtSpline(self)
            AtSpline=self.AtSpline;
        end
        function BptSpline=getBptSpline(self)
            BptSpline=self.BptSpline;
        end        
        function xtSpline=getxtSpline(self)
            xtSpline=self.xtSpline;
        end
        function Xtt0Spline=getXtt0Spline(self)
            Xtt0Spline=self.Xtt0Spline;
        end
        function X0Mat=getX0Mat(self)
            X0Mat=self.X0Mat;
        end
        function x0Vec=getx0Vec(self)
            x0Vec=self.x0Vec;
        end
        function tLims=getTimeLimsVec(self)
            tLims=[self.t0,self.t1];
        end
        function t0=gett0(self)
            t0=self.t0;
        end
        function t1=gett1(self)
            t1=self.t1;
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
        function self=LReachProblemDefInterp(AtDefMat,BtDefMat,...
                PtDefMat,ptDefVec,X0DefMat,x0DefVec,tLims,calcPrecision)
            import gras.ellapx.common.*;
            import gras.interp.MatrixInterpolantFactory;
            import gras.interp.MatrixSymbInterpFactory;
            %
            import gras.gen.SquareMatVector;
            import gras.ellapx.lreachplain.LReachProblemDefInterp;
            import gras.ode.MatrixODESolver;
            %
            ODE_NORM_CONTROL='on';
            %
            nTimePoints=LReachProblemDefInterp.N_TIME_POINTS;
            odeArgList={'NormControl',ODE_NORM_CONTROL,'RelTol',...
                calcPrecision,'AbsTol',calcPrecision};
            %
            self.X0Mat=X0DefMat;
            self.x0Vec=x0DefVec;
            self.t0=tLims(1);
            self.t1=tLims(2);
            %
            sysDim=size(AtDefMat,1);
            self.sysDim=sysDim;
            tVec=linspace(tLims(1),tLims(2),nTimePoints);
            %
            self.timeVec=tVec;
            %
            %% Creating Xtt0Spline
            %
            solverObj=MatrixODESolver([sysDim,sysDim],@ode45,...
                odeArgList{:});
            fHandleR_Xtt0=@(t,x)LReachProblemDefInterp.R_Xtt0(AtDefMat,t,x);
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
            fHandleR_xt=@(t,x)LReachProblemDefInterp.R_xt(...
                self.AtSpline,...
                self.BptSpline,t,x);
            [timeXtVec,xtArray]=solverObj.solve(fHandleR_xt,tVec,x0DefVec);
            %
            self.xtSpline=MatrixInterpolantFactory.createInstance(...
                'column',xtArray,timeXtVec);
        end
    end
end
    
    
    
    