classdef LReachProblemDefInterp<handle
    properties (Access=protected)
        pDefObj
        pDynObj
    end
    methods
        function sysDim=getDimensionality(self)
            sysDim=self.pDefObj.getDimensionality();
        end
        function BPBTransSpline=getBPBTransSpline(self)
            BPBTransSpline=self.pDynObj.getBPBTransDynamics();
        end
        function AtSpline=getAtSpline(self)
            AtSpline=self.pDynObj.getAtDynamics();
        end
        function BptSpline=getBptSpline(self)
            BptSpline=self.pDynObj.getBptDynamics();
        end
        function xtSpline=getxtSpline(self)
            xtSpline=self.pDynObj.getxtDynamics();
        end
        function Xtt0Spline=getXtt0Spline(self)
            Xtt0Spline=self.pDynObj.getXtt0Dynamics();
        end
        function X0Mat=getX0Mat(self)
            X0Mat=self.pDefObj.getX0Mat();
        end
        function x0Vec=getx0Vec(self)
            x0Vec=self.pDefObj.getx0Vec();
        end
        function tLims=getTimeLimsVec(self)
            tLims=self.pDefObj.getTimeLimsVec();
        end
        function t0=gett0(self)
            t0=self.pDefObj.gett0();
        end
        function t1=gett1(self)
            t1=self.pDefObj.gett1();
        end
        function timeVec=getTimeVec(self)
            timeVec=self.pDynObj.getTimeVec();
        end
    end
    methods
        function self=LReachProblemDefInterp(AtDefMat,BtDefMat,...
                PtDefMat,ptDefVec,X0DefMat,x0DefVec,tLims,calcPrecision)
            %
            import gras.ellapx.lreachplain.LReachProblemDynamicsFactory;
            %
            if nargin == 0
                % called from subclass
            else
                self.pDynObj = LReachProblemDynamicsFactory.createByParams(...
                    AtDefMat,BtDefMat,PtDefMat,ptDefVec,X0DefMat,...
                    x0DefVec,tLims,calcPrecision);
                self.pDefObj = self.pDynObj.getProblemDef();
            end
        end
    end
end