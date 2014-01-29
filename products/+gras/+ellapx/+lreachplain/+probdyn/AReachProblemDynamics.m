classdef AReachProblemDynamics<...
        gras.ellapx.lreachplain.probdyn.IReachProblemDynamics
    properties (Access = protected)
        problemDef
        AtDynamics
        BptDynamics
        BPBTransDynamics
        timeVec
    end
    properties (Abstract, Access = protected)
        xtDynamics
    end
    properties (Constant, GetAccess = protected)
        ODE_NORM_CONTROL='on';
        CALC_PRECISION_FACTOR=0.001;
        N_TIME_POINTS=2000;
    end
    methods
        function self = AReachProblemDynamics(problemDef)
            if (nargin > 0)
                self.problemDef = problemDef;
                %
                t0 = problemDef.gett0();
                t1 = problemDef.gett1();
                self.timeVec = linspace(t0,t1,self.N_TIME_POINTS);
            end
        end
        function BPBTransDynamics=getBPBTransDynamics(self)
            BPBTransDynamics=self.BPBTransDynamics;
        end
        function AtDynamics=getAtDynamics(self)
            AtDynamics=self.AtDynamics;
        end
        function BptDynamics=getBptDynamics(self)
            BptDynamics=self.BptDynamics;
        end
        function xtDynamics=getxtDynamics(self)
            xtDynamics=self.xtDynamics;
        end
        function timeVec=getTimeVec(self)
            timeVec=self.timeVec;
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
        function sysDim=getDimensionality(self)
            sysDim=self.problemDef.getDimensionality();
        end
        function problemDef=getProblemDef(self)
            problemDef=self.problemDef;
        end
    end
    methods (Access = protected)
        function odePropList=getOdePropList(self,calcPrecision)
            odePropList={'NormControl',self.ODE_NORM_CONTROL,'RelTol',...
                calcPrecision*self.CALC_PRECISION_FACTOR,...
                'AbsTol',calcPrecision*self.CALC_PRECISION_FACTOR};
        end
    end
end