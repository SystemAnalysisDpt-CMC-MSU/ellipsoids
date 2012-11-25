classdef IntEllApxBuilder<gras.ellapx.lreachplain.IntProperEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='InternalUncert'
        APPROX_SCHEMA_DESCR='Internal approximation based on matrix ODE for (Q)'
    end
    properties(Access=protected)
        slCQClSqrtDynamicsList
    end
    methods (Access=protected)
% this is dead code and it contains calls to undefined methods like
% self.getADirSpline, it should probably be removed
%
%         function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
%             fHandle=...
%                 @(t,y)calcEllApxMatrixDeriv(self,...
%                 self.getProblemDef().getAtDynamics,...
%                 self.getBPBTransSqrtDynamics(iGoodDir),...
%                 self.getProblemDef().getCQCTransDynamics,...
%                 self.slCQClSqrtDynamicsList{iGoodDir},...
%                 self.getBDirSpline(iGoodDir),...
%                 self.getADirSpline(iGoodDir),...
%                 t,y);
%         end
        function res=calcEllApxMatrixDeriv(self,AtDynamics,...
                BPBTransSqrtDynamics,CQCTransDynamics,slCQClSqrtDynamics,...
                BPBTransSqrtLDynamics,ltSpline,t,QMat)
            import modgen.common.throwerror;
            A=AtDynamics.evaluate(t);
            R_sqrt=BPBTransSqrtDynamics.evaluate(t);
            rSqrtlVec=BPBTransSqrtLDynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            %
            [VMat,DMat]=eig(QMat);
            if any(diag(DMat)<0)
                throwerror('wrongState','internal approx has degraded');
            end
            Q_star=VMat*sqrt(DMat)*transpose(VMat);
            S=self.getOrthTranslMatrix(Q_star,R_sqrt,rSqrtlVec,Q_star*ltVec);
            %
            piNumerator=slCQClSqrtDynamics.evaluate(t);
            piDenominator=sqrt(sum((QMat*ltVec).*ltVec));
            %
            tmp=(A*Q_star+R_sqrt*transpose(S))*transpose(Q_star);
            res=tmp+transpose(tmp)-piNumerator.*QMat./piDenominator-...
                piDenominator.*CQCTransDynamics.evaluate(t)./piNumerator;
        end
    end
    methods (Access=private)
        function self=prepareODEData(self)
            import gras.ellapx.common.*;
            import gras.ellapx.uncertcalc.MatrixOperationsFactory;
            import gras.ellapx.lreachplain.IntEllApxBuilder;
            %
            nGoodDirs=self.getNGoodDirs();
            pDefObj=self.getProblemDef();
            timeVec=pDefObj.getTimeVec;
            %
            % calculate <l,CQC l>^{1/2}
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            CQCTransDynamics = pDefObj.getCQCTransDynamics();
            goodDirSet = self.getGoodDirSet();
            self.slCQClSqrtDynamicsList = cell(1, nGoodDirs);
            %
            for iGoodDir = 1:nGoodDirs
                ltSpline = goodDirSet.getGoodDirOneCurveSpline(iGoodDir);
                %
                self.slCQClSqrtDynamicsList{iGoodDir} = ...
                    matOpFactory.quadraticFormSqrt(CQCTransDynamics,ltSpline);
            end
        end
    end
    methods
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self)
            apxSchemaName=self.APPROX_SCHEMA_NAME;
            apxSchemaDescr=self.APPROX_SCHEMA_DESCR;
        end
        function self=IntEllApxBuilder(varargin)
            self=self@gras.ellapx.lreachplain.IntProperEllApxBuilder(...
                varargin{:});
            self.prepareODEData();
        end
    end
end