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
                    self.getProblemDef().getAtDynamics,...
                    self.getProblemDef.getBPBTransDynamics,...
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
            import gras.mat.fcnlib.MatrixOperationsFactory;
            import gras.ellapx.lreachplain.IntEllApxBuilder;
            %
            nGoodDirs=self.getNGoodDirs();
            pDefObj=self.getProblemDef();
            timeVec=pDefObj.getTimeVec;
            %
            % calculate <l,BPB' l>^{1/2}
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            BPBTransDynamics = pDefObj.getBPBTransDynamics();
            goodDirSet = self.getGoodDirSet();
            self.slBPBlSqrtSplineList = cell(1, nGoodDirs);
            %
            for iGoodDir = 1:nGoodDirs
                ltSpline = goodDirSet.getGoodDirOneCurveSpline(iGoodDir);
                %
                self.slBPBlSqrtSplineList{iGoodDir} = matOpFactory.quadraticFormSqrt(...
                    BPBTransDynamics, ltSpline);
            end               
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
