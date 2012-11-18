classdef AReachContProblemDef<...
        gras.ellapx.lreachuncert.probdef.IReachContProblemDef & ...
        gras.ellapx.lreachplain.probdef.AReachContProblemDef
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
    methods(Static,Access=protected)
        function isOk=isPartialCompatible(aCMat,bCMat,pCMat,pCVec,cCMat,...
                qCMat,qCVec,x0Mat,x0Vec,tLims)
            import modgen.common.type.simple.lib.*;
            isOk = ...
                iscellofstring(cCMat)&&ismat(cCMat)&&...
                iscellofstring(qCMat)&&ismat(qCMat)&&...
                iscellofstring(qCVec)&&iscol(qCVec)&&...
                size(qCMat,1)==size(qCMat,2)&&...
                size(cCMat,1)==size(aCMat,1)&&...
                size(qCMat,1)==size(cCMat,2)&&...
                size(qCVec,1)==size(cCMat,2);
        end
    end    
    methods(Static)
        function isOk=isCompatible(aCMat,bCMat,pCMat,pCVec,cCMat,...
                qCMat,qCVec,x0Mat,x0Vec,tLims)
            isOk = ...
                gras.ellapx.lreachuncert.probdef.AReachContProblemDef.isPartialCompatible(...
                aCMat,bCMat,pCMat,pCVec,cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)&&...
                gras.ellapx.lreachplain.probdef.AReachContProblemDef.isCompatible(...
                aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
        end
    end
    methods
        function self=AReachContProblemDef(aCMat,bCMat,pCMat,pCVec,...
                cCMat,qCMat,qCVec,x0Mat,x0Vec,tLims)
            %
            import gras.ellapx.lreachuncert.probdef.AReachContProblemDef;
            %
            if ~AReachContProblemDef.isPartialCompatible(aCMat,bCMat,pCMat,pCVec,cCMat,...
                qCMat,qCVec,x0Mat,x0Vec,tLims)
                modgen.common.throwerror(...
                    'wrongInput','Incorrect system definition');
            end                 
            %
            self=self@gras.ellapx.lreachplain.probdef.AReachContProblemDef(...
                aCMat,bCMat,pCMat,pCVec,x0Mat,x0Vec,tLims);
            %
            self.cCMat = cCMat;
            self.qCMat = qCMat;
            self.qCVec = qCVec;
        end
    end
end