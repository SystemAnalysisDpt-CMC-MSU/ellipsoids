classdef ATightIntEllApxBuilder<gras.ellapx.lreachplain.ATightEllApxBuilder
    properties (Access=private)
        ltSplineList
        BPBTransSqrtSpline
        sMethodName
    end
    methods (Access=protected)
        function ltSpline=getltSpline(self,iGoodDir)
            ltSpline=self.ltSplineList{iGoodDir};
        end
        %
        function resSpline=getBPBTransSqrtSpline(self)
            resSpline=self.BPBTransSqrtSpline;
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
            %ODE is solved on time span [tau0, tau1]\in[t0,t1]
            import gras.interp.MatrixInterpolantFactory;
            import gras.mat.symb.MatrixSFSqrtm;
            pDefObj=self.getProblemDef();
            nGoodDirs=self.getNGoodDirs();
            timeVec=pDefObj.getTimeVec;
            %
            goodDirCurveSpline=self.getGoodDirSet().getGoodDirCurveSpline();
            goodDirArray=goodDirCurveSpline.evaluate(timeVec);
            ltSplineList=cell(1,nGoodDirs);
            for iGoodDir=1:nGoodDirs
                ltSplineList{iGoodDir}=...
                    MatrixInterpolantFactory.createInstance(...
                    'column',...
                    squeeze(goodDirArray(:,iGoodDir,:)),timeVec);
            end
            self.ltSplineList=ltSplineList;
            self.BPBTransSqrtSpline=MatrixSFSqrtm(...
                self.getProblemDef().getBPBTransSpline());
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
