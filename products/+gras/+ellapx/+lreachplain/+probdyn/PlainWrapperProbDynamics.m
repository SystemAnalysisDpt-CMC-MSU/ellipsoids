classdef PlainWrapperProbDynamics <...
        gras.ellapx.lreachplain.probdyn.IReachProblemDynamics
    properties (Access = protected)
        pDynObj
    end
    methods
        function self = PlainWrapperProbDynamics(pDynObj)
            self.pDynObj = pDynObj;
        end
        function BPBTransDynamics = getBPBTransDynamics(self)
            BPBTransDynamics=self.pDynObj.getBPBTransDynamics();
        end
        function AtDynamics = getAtDynamics(self)
            AtDynamics = self.pDynObj.getAtDynamics();
        end
        function BptDynamics = getBptDynamics(self)
            BptDynamics = self.pDynObj.getBptDynamics();
        end
        function xtDynamics = getxtDynamics(self)
            xtDynamics = self.pDynObj.getxtDynamics();
        end
        function Xtt0Dynamics = getXtt0Dynamics(self)
            Xtt0Dynamics = self.pDynObj.getXtt0Dynamics();
        end
        function problemDef = getProblemDef(self)
            problemDef = self.pDynObj.getProblemDef();
        end
        function timeVec=getTimeVec(self)
            timeVec = self.pDynObj.getTimeVec();
        end
        function X0Mat=getX0Mat(self)
            X0Mat=self.pDynObj.getX0Mat();
        end
        function x0Vec=getx0Vec(self)
            x0Vec = self.pDynObj.getx0Vec();
        end
        function timeLimsVec=getTimeLimsVec(self)
            timeLimsVec = self.pDynObj.getTimeLimsVec();
        end
        function t0=gett0(self)
            t0 = self.pDynObj.gett0();
        end
        function t1=gett1(self)
            t1 = self.pDynObj.gett1();
        end
        function sysDim=getDimensionality(self)
            sysDim = self.pDynObj.getDimensionality();
        end
    end
end