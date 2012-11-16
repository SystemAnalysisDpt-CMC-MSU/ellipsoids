classdef AReachContProblemDef<...
        gras.ellapx.lreachuncert.IReachContProblemDef & ...
        gras.ellapx.lreachplain.AReachContProblemDef
    properties (Access=protected)
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
    end
    methods(Static)
        function isOk=isCompatible(aCMat,bCMat,pCMat,pCVec,cCMat,...
                qCMat,qCVec,x0Mat,x0Vec,tLims)
            import modgen.common.type.simple.lib.*;
            isOk = ...
                iscellofstring(cCMat)&&ismat(cCMat)&&...
                iscellofstring(qCMat)&&ismat(qCMat)&&...
                iscellofstring(qCVec)&&iscol(qCVec)&&...
                size(qCMat,1)==size(qCMat,2)&&...
                size(cCMat,1)==size(aCMat,1)&&...
                size(qCMat,1)==size(cCMat,2)&&...
                size(qCVec,1)==size(cCMat,2)&&...
                gras.ellapx.lreachplain.AReachContProblemDef.isCompatible(...
                aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
        end
    end
    methods
        function self=AReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            self=self@gras.ellapx.lreachplain.AReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
            %
            self.cCMat = cCMat;
            self.qCMat = qCMat;
            self.qCVec = qCVec;
        end
    end
end