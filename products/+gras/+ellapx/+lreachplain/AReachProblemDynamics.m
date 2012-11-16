classdef AReachProblemDynamics<...
        gras.ellapx.lreachplain.IReachProblemDynamics
    properties (Access=protected)
        problemDef
        AtDynamics
        BptDynamics
        BPBTransDynamics
        Xtt0Dynamics
        timeVec
    end
    properties (Abstract,Access=protected)
        xtDynamics
    end
    properties (Constant,GetAccess=protected)
        N_TIME_POINTS=1000;
        ODE_NORM_CONTROL='on';
    end
    methods
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
        function Xtt0Dynamics=getXtt0Dynamics(self)
            Xtt0Dynamics=self.Xtt0Dynamics;
        end
        function timeVec=getTimeVec(self)
            timeVec=self.timeVec;
        end
        function problemDef=getProblemDef(self)
            problemDef=self.problemDef;
        end        
    end
end