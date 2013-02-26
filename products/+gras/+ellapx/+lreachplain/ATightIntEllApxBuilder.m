classdef ATightIntEllApxBuilder<gras.ellapx.lreachplain.ATightEllApxBuilder
    properties (Access=private)
        ltSplineList
        BPBTransSqrtDynamics
        sMethodName
    end
    methods (Access=protected)
        function ltSpline=getltSpline(self,iGoodDir)
            ltSpline=self.ltSplineList{iGoodDir};
        end
        %
        function resObj=getBPBTransSqrtDynamics(self)
            resObj=self.BPBTransSqrtDynamics;
        end
        %
        function S=getOrthTranslMatrix(self,Q_star,R_sqrt,b,a)
            import gras.la.*;
            methodName=self.sMethodName;
            switch methodName
                case 'hausholder'
                    S=orthtranslhaus(b,a);
                case 'gram',
                    S=orthtransl(b,a);
                case 'direction',
                    aMaxVec=R_sqrt*l;
                    bMaxVec=Q_star*l;
                    S=orthtranslmaxdir(b,a,bMaxVec,aMaxVec);
                case 'trace',
                    maxMat=R_sqrt*Q_star;
                    S=orthtranslmaxtr(b,a,maxMat);
                case 'volume',
                    maxMat=R_sqrt/(Q_star.');
                    S=orthtranslmaxtr(b,a,maxMat);
                otherwise,
                    modgen.common.throwerror('wrongInput',...
                        'method %s is not supported',methodName);
            end
        end
    end
    methods (Access=protected)
        function apxType=getApxType(~)
            apxType=gras.ellapx.enums.EApproxType.Internal;
        end
    end
    methods (Access=private)
        function self=prepareODEData(self)
            import gras.mat.MatrixOperationsFactory;
            %
            pDefObj=self.getProblemDef();
            timeVec=pDefObj.getTimeVec;
            %
            % calculate (BPB')^{1/2}
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            BPBTransDynamics = pDefObj.getBPBTransDynamics();
            self.BPBTransSqrtDynamics = matOpFactory.sqrtm(BPBTransDynamics);
            self.ltSplineList = ...
                self.getGoodDirSet().getGoodDirOneCurveSplineList();
        end
    end
    methods
        function self=ATightIntEllApxBuilder(pDefObj,goodDirSetObj,...
                timeLimsVec,calcPrecision,sMethodName)
            self=self@gras.ellapx.lreachplain.ATightEllApxBuilder(...
                pDefObj,goodDirSetObj,timeLimsVec,calcPrecision);
            self.sMethodName=sMethodName;
            self.prepareODEData();
        end
    end
end
