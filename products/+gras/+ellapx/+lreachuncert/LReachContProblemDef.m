classdef LReachContProblemDef<gras.ellapx.lreachuncert.IReachContProblemDef & gras.ellapx.lreachplain.LReachContProblemDef
    properties (Access=private)
        cCMat
        qCVec
        qCMat
    end
    methods
        function cCMat=getCMatDef(self)
            cCMat=self.cCMat;
        end
		function qCVec=getqCVec(self)
            qCVec=self.qCVec;
        end
		function qCMat=getQCMat(self)
            qCMat=self.qCMat;
        end
        function self=LReachContProblemDef(aCMat,bCMat,...
                pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            self=self@gras.ellapx.lreachplain.LReachContProblemDef(aCMat,bCMat,...
                pCMat,pCVec,x0Mat,x0Vec,tLims);
            %
            self.cCMat = cCMat;
            self.qCMat = qCMat;
            self.qCVec = qCVec; 
        end
    end
end