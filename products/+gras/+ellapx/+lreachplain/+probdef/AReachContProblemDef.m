classdef AReachContProblemDef<gras.ellapx.lreachplain.probdef.IReachContProblemDef
    properties (Access=protected)
        sysDim
        bCMat
        aCMat
        x0Mat
        x0Vec
        t0
        t1
        pCVec
        pCMat
    end
    methods
        function sysDim=getDimensionality(self)
            sysDim=self.sysDim;
        end
        function bCMat=getBMatDef(self)
            bCMat=self.bCMat;
        end
        function aCMat=getAMatDef(self)
            aCMat=self.aCMat;
        end
        function x0Mat=getX0Mat(self)
            x0Mat=self.x0Mat;
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
        function pCVec=getpCVec(self)
            pCVec=self.pCVec;
        end
        function pCMat=getPCMat(self)
            pCMat=self.pCMat;
        end
    end
    methods(Static)
        function isOk=isCompatible(aCMat,bCMat,pCMat,pCVec,x0Mat,...
                x0Vec,tLims)
            import modgen.common.type.simple.lib.*;
            isOk = ...
                iscellofstring(aCMat)&&ismat(aCMat)&&...
                iscellofstring(bCMat)&&ismat(bCMat)&&...
                iscellofstring(pCMat)&&ismat(pCMat)&&...
                iscellofstring(pCVec)&&iscol(pCVec)&&...
                isnumeric(x0Mat)&&ismat(x0Mat)&&...
                isnumeric(x0Vec)&&iscol(x0Vec)&&...
                isnumeric(tLims)&&isrow(tLims)&&...
                size(aCMat,1)==size(aCMat,2)&&...
                size(pCMat,1)==size(pCMat,2)&&...
                size(x0Mat,1)==size(x0Mat,2)&&...
                size(bCMat,1)==size(aCMat,1)&&...
                size(pCMat,1)==size(bCMat,2)&&...
                size(pCVec,1)==size(bCMat,2)&&...
                size(x0Mat,1)==size(aCMat,1)&&...
                size(x0Vec,1)==size(aCMat,1)&&...
                size(tLims,2)==2;
        end
    end
    methods
        function self=AReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                x0Mat,x0Vec,tLims)
            %
            import gras.ellapx.lreachplain.probdef.AReachContProblemDef;
            %
            if ~AReachContProblemDef.isCompatible(aCMat,bCMat,pCMat,...
                    pCVec,x0Mat,x0Vec,tLims)
                modgen.common.throwerror(...
                    'wrongInput','Incorrect system definition');
            end            
            %
            self.aCMat = aCMat;
            self.bCMat = bCMat;
            self.pCMat = pCMat;
            self.pCVec = pCVec;
            self.x0Mat = x0Mat;
            self.x0Vec = x0Vec;
            self.t0 = tLims(1);
            self.t1 = tLims(2);
            self.sysDim = size(aCMat,1);
        end
    end
end



