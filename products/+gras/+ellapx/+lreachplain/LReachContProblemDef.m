classdef LReachContProblemDef<gras.ellapx.lreachplain.IReachContProblemDef
    properties (Access=private)
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
    methods
        function self=LReachContProblemDef(aCMat,bCMat,...
                pCMat,pCVec,x0Mat,x0Vec,tLims)
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
    
    
    
    