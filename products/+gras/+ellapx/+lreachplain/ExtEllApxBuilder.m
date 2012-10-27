classdef ExtEllApxBuilder<gras.ellapx.lreachplain.ATightEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='ExternalQ'
        APPROX_SCHEMA_DESCR='External approximation based on matrix ODE for Q'
    end    
    properties (Access=private)
        slBPBlSqrtSplineList
    end
    methods (Access=protected)
        function resMat=calcEllApxMatrixDeriv(~,ASpline,BPBTransSpline,...
                slBPBlSqrtSpline,ltSpline,t,QMat)
            AMat=ASpline.evaluate(t);
            piNumerator=slBPBlSqrtSpline.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            piDenominator=sqrt(sum((QMat*ltVec).*ltVec));
            tmpMat=AMat*QMat;
            resMat=tmpMat+tmpMat.'+piNumerator.*QMat./piDenominator+...
                piDenominator.*BPBTransSpline.evaluate(t)./piNumerator;
        end
        function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
                fHandle=...
                    @(t,y)calcEllApxMatrixDeriv(self,...
                    self.getProblemDef().getAtSpline,...
                    self.getProblemDef.getBPBTransSpline,...
                    self.slBPBlSqrtSplineList{iGoodDir},...
                    self.getGoodDirSet.getGoodDirOneCurveSpline(...
                    iGoodDir),t,y);     
        end
        function QArray=adjustEllApxMatrixVec(~,QArray)
        end
        function initQMat=getEllApxMatrixInitValue(self,~)
             initQMat=self.getProblemDef().getX0Mat();
        end
    end
    methods (Access=protected)
        function apxType=getApxType(~)
            apxType=gras.ellapx.enums.EApproxType.External;
        end
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self)
            apxSchemaName=self.APPROX_SCHEMA_NAME;
            apxSchemaDescr=self.APPROX_SCHEMA_DESCR;
        end 
    end
    methods (Access=private)
        function self=prepareODEData(self)
            import gras.ellapx.common.*;
            import gras.gen.MatVector;
            import gras.ellapx.lreachplain.IntEllApxBuilder;
            import gras.interp.MatrixInterpolantFactory;
            %
            nGoodDirs=self.getNGoodDirs();
            pDefObj=self.getProblemDef();
            timeVec=pDefObj.getTimeVec;
            %ODE is solved on time span [tau0, tau1]\in[t0,t1]
            dataBPBTransArray=pDefObj.getBPBTransSpline.evaluate(timeVec);
            %
            goodDirCurveSpline=self.getGoodDirSet().getGoodDirCurveSpline();
            goodDirArray=goodDirCurveSpline.evaluate(timeVec);
            slBPBlSqrtSplineList=cell(1,nGoodDirs);
            tmpArray=MatVector.rMultiply(dataBPBTransArray,...
                goodDirArray);
            lBPBlSqrtArray=shiftdim(sqrt(sum(tmpArray.*goodDirArray,1)),1);
            for l=1:1:nGoodDirs
                slBPBlSqrtSplineList{l}=...
                    MatrixInterpolantFactory.createInstance(...
                    'column',lBPBlSqrtArray(l,:),timeVec);
            end
            self.slBPBlSqrtSplineList=slBPBlSqrtSplineList;
        end
    end
    methods 
        function self=ExtEllApxBuilder(varargin)
            self=self@gras.ellapx.lreachplain.ATightEllApxBuilder(...
                varargin{:});
            self.prepareODEData();
        end
    end
end
