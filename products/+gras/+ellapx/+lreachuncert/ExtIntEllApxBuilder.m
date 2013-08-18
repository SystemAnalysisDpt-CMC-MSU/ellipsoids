classdef ExtIntEllApxBuilder<gras.ellapx.gen.ATightEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='ExtIntUncert'
        APPROX_SCHEMA_DESCR='External and internal approximation based on matrix ODEs for (Q)'
        N_TIME_POINTS=100;
        ODE_NORM_CONTROL='on';
        REG_MAX_STEP_TOL=0.05;
        REG_ABS_TOL=1e-8;
        N_MAX_REG_STEPS=6;
    end
    properties (Access=private)
        ellTubeRel
        ltSplineList
        %
        minQMatEig
        %
        goodDirSetObj
    end
    methods (Access=protected)
        function resObj=getBPBTransSqrtDynamics(self)
            resObj=self.BPBTransSqrtDynamics;
        end
        function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
            fHandle=...
                @(t,varargin)calcEllApxMatrixDeriv(self,...
                self.getProblemDef().getAtDynamics,...
                self.getProblemDef().getBPBTransDynamics,...
                self.getProblemDef().getCQCTransDynamics,...
                self.ltSplineList{iGoodDir},...
                t,varargin{:});
        end
        function [isStrictViol,regQIntMat,regQExtMat]=...
                calcRegEllApxMatrix(self,QIntMat,QExtMat)
            STRICT_Q_MAT_EIG_FACTOR=0.1;
            TOL_ADJUSTMNET=100*eps;
            strinctMinQMatEig=self.minQMatEig*STRICT_Q_MAT_EIG_FACTOR;
            %
            [VMat,DMat]=eig(QIntMat,'nobalance');
            dVec=diag(DMat);
            isStrictViol=any(dVec-strinctMinQMatEig<0);
            if ~isStrictViol
                if any(dVec<self.minQMatEig)
                    mVec=-min(dVec-self.minQMatEig,0)+TOL_ADJUSTMNET;
                    MMat=VMat*diag(mVec)*transpose(VMat);
                    MMat=0.5*(MMat+MMat.');
                    regQIntMat=QIntMat+MMat;
                    regQExtMat=QExtMat+MMat;
                else
                    regQIntMat=QIntMat;
                    regQExtMat=QExtMat;
                end
            else
                regQIntMat=nan(size(QIntMat));
                regQExtMat=nan(size(QIntMat));
            end
        end
        function [dQIntMat,dQExtMat]=calcEllApxMatrixDeriv(self,...
                AtDynamics,BPBTransDynamics,CQCTransDynamics,...
                ltSpline,t,QIntMat,QExtMat)
            import modgen.common.throwerror;
            import gras.la.ismatposdef;
            import gras.la.sqrtmpos;
            A=AtDynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            %
            %% Internal approximation
            BPBTransMat=BPBTransDynamics.evaluate(t);
            BPBTransSqrtMat=sqrtmpos(BPBTransMat);
            %
            CQCTransMat=CQCTransDynamics.evaluate(t);
            %
            [VMat,DMat]=eig(QIntMat);
            if ~ismatposdef(QIntMat,self.calcPrecision,true)
                throwerror('wrongState','internal approx has degraded');
            end
            Q_star=VMat*realsqrt(DMat)*transpose(VMat);
            S=self.getOrthTranslMatrix(Q_star,BPBTransSqrtMat,...
                BPBTransSqrtMat*ltVec,Q_star*ltVec);
            %
            piNumerator=realsqrt(ltVec.'*CQCTransMat*ltVec);
            piDenominator=realsqrt(sum((QIntMat*ltVec).*ltVec));                        
            if piNumerator<=self.absTol
                throwerror('wrongInput',...
                    ['matrices C,Q for disturbance ',...
                    'contraints are either degenerate or ill-conditioned']);
            elseif piDenominator<=self.absTol
                throwerror('wrongInput',...
                    'the internal estimate has degraded, reason unknown');
            end
            %
            tmp=(A*Q_star+BPBTransSqrtMat*transpose(S))*transpose(Q_star);
            dQIntMat=tmp+transpose(tmp)-...
                piNumerator.*QIntMat./piDenominator-...
                piDenominator.*CQCTransMat./piNumerator;
            %
            %% External approximation
            CQCTransSqrtMat=sqrtmpos(CQCTransMat);            
            [VMat,DMat]=eig(QExtMat);
            if ~ismatposdef(QExtMat,self.absTol)
                throwerror('wrongState','external approx has degraded');
            end
            Q_star=VMat*realsqrt(DMat)*transpose(VMat);
            piNumerator=realsqrt(ltVec.'*BPBTransMat*ltVec);
            piDenominator=realsqrt(sum((QExtMat*ltVec).*ltVec));
            if piNumerator<=self.absTol
                throwerror('wrongInput',...
                    ['matrices B,P for control ',...
                    'contraints are either degenerate or ill-conditioned']);
            elseif piDenominator<=self.absTol
                throwerror('wrongInput',...
                    'the external estimate has degraded, reason unknown');
            end            
            S=self.getOrthTranslMatrix(Q_star,CQCTransSqrtMat,...
                CQCTransSqrtMat*ltVec,Q_star*ltVec);
            tmp=(A*Q_star-CQCTransSqrtMat*transpose(S))*transpose(Q_star);
            dQExtMat=tmp+transpose(tmp)+...
                piNumerator.*QExtMat./piDenominator+...
                piDenominator.*BPBTransMat./piNumerator;
            dQExtMat=(dQExtMat+dQExtMat.')*0.5;
        end
    end
    methods (Access=private)
        function self=prepareODEData(self)
            self.ltSplineList = ...
                self.getGoodDirSet().getRGoodDirOneCurveSplineList();
        end
        function build(self)
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            import gras.ellapx.common.*;
            import gras.gen.SquareMatVector;
            import gras.ode.MatrixSysODESolver;
            import modgen.logging.log4j.Log4jConfigurator;
            odeArgList={'NormControl',self.ODE_NORM_CONTROL,...
                'RelTol',self.getRelODECalcPrecision(),...
                'AbsTol',self.getAbsODECalcPrecision()};
            %
            sysDim=self.getProblemDef.getDimensionality();
            logger=Log4jConfigurator.getLogger();
            %
            %% Constructor solver object
            fOdeReg=@(t,QIntMat,QExtMat)calcRegEllApxMatrix(self,...
                QIntMat,QExtMat);
            %
            solverObj=MatrixSysODESolver({[sysDim,sysDim],[sysDim,sysDim]},...
                @(varargin)gras.ode.ode45reg(varargin{:},...
                odeset(odeArgList{:}),...
                'regMaxStepTol',self.REG_MAX_STEP_TOL,...
                'regAbsTol',self.REG_ABS_TOL,...
                'nMaxRegSteps',self.N_MAX_REG_STEPS),...
                'outArgStartIndVec',[1 2]);
            %
            nLDirs=self.getNGoodDirs;
            %
            lsGoodDirMat=self.goodDirSetObj.getlsGoodDirMat;
            sTime=self.goodDirSetObj.getsTime();
            %
            pDefObj=self.getProblemDef();
            pDefTimeLimsVec=pDefObj.getTimeLimsVec();
            pStartTime=pDefTimeLimsVec(1);
            solveTimeVec=self.getTimeVec;
            resTimeVec=self.getTimeVec;
            if solveTimeVec(1)~=pStartTime
                solveTimeVec=[pStartTime solveTimeVec];
                isFirstPointToRemove=true;
            else
                isFirstPointToRemove=false;
            end
            QIntArrayList=cell(1,nLDirs);
            MIntArrayList=cell(1,nLDirs);
            QExtArrayList=cell(1,nLDirs);
            MExtArrayList=cell(1,nLDirs);
            %
            %% Calculating approximations
            for iDir=1:1:nLDirs
                logStr=sprintf(...
                    'solving ode for direction \n %s  defined at time %f',...
                    mat2str(lsGoodDirMat(:,iDir).'),sTime);
                tStart=tic;
                logger.info([logStr,'...']);
                fHandle=self.getEllApxMatrixDerivFunc(iDir);
                initValueMat=self.getEllApxMatrixInitValue(iDir);
                %
                [~,QStarIntArray,QStarExtArray,MIntArray,MExtArray]=...
                    solverObj.solve({fHandle,fOdeReg},...
                    solveTimeVec,initValueMat,initValueMat);
                if isFirstPointToRemove
                    QStarIntArray(:,:,1)=[];
                    QStarExtArray(:,:,1)=[];
                end
                %
                QIntArrayList{iDir}=self.adjustEllApxMatrixVec(QStarIntArray);
                MIntArrayList{iDir}=MIntArray;
                QExtArrayList{iDir}=self.adjustEllApxMatrixVec(QStarExtArray);
                MExtArrayList{iDir}=MExtArray;
                logger.info(sprintf([logStr,':done, %.3f sec. elapsed'],...
                    toc(tStart)));
            end
            %
            aMat=pDefObj.getxtDynamics.evaluate(resTimeVec);
            %
            [apxSchemaName,apxSchemaDescr]=self.getApxSchemaNameAndDescr();
            %
            goodDirSetObj=self.getGoodDirSet();
            sTime=goodDirSetObj.getsTime();
            ltGoodDirArray=goodDirSetObj.getRGoodDirCurveSpline(...
                ).evaluate(resTimeVec);
            %
            self.ellTubeRel=...
                gras.ellapx.smartdb.rels.EllTube.fromQMArrays(...
                QIntArrayList,aMat,MIntArrayList,resTimeVec,ltGoodDirArray,...
                sTime,gras.ellapx.enums.EApproxType.Internal,...
                apxSchemaName,apxSchemaDescr,...
                self.getCalcPrecision);
            %
            self.ellTubeRel.unionWith(...
                gras.ellapx.smartdb.rels.EllTube.fromQMArrays(...
                QExtArrayList,aMat,MExtArrayList,resTimeVec,ltGoodDirArray,...
                sTime,gras.ellapx.enums.EApproxType.External,...
                apxSchemaName,apxSchemaDescr,...
                self.getCalcPrecision));
        end
    end
    methods (Access=protected)
        function [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self)
            apxSchemaName=self.APPROX_SCHEMA_NAME;
            apxSchemaDescr=self.APPROX_SCHEMA_DESCR;
        end
        function QArray=adjustEllApxMatrixVec(~,QArray)
        end
        function initQMat=getEllApxMatrixInitValue(self,~)
            initQMat=self.getProblemDef().getX0Mat();
        end
    end
    methods
        function self=ExtIntEllApxBuilder(pDefObj,goodDirSetObj,...
                timeLimsVec,calcPrecision,varargin)
            import gras.ellapx.lreachuncert.ExtIntEllApxBuilder;
            import modgen.common.throwerror;
            import gras.la.ismatposdef;
            self=self@gras.ellapx.gen.ATightEllApxBuilder(pDefObj,...
                goodDirSetObj,timeLimsVec,...
                ExtIntEllApxBuilder.N_TIME_POINTS,calcPrecision);
            x0Mat = pDefObj.getX0Mat();            
            if ~ismatposdef(x0Mat, self.REG_ABS_TOL)
                throwerror('wrongInput',...
                    'Initial set is not positive definite.');
            end
            %
            [~,~,sMethodName,minQSqrtMatEig] = ...
                modgen.common.parseparext(varargin, ...
                {'selectionMethodForSMatrix','minQSqrtMatEig'}, 0, 2);
            %
            self.minQMatEig=minQSqrtMatEig*minQSqrtMatEig;
            self.goodDirSetObj=goodDirSetObj;
            self.sMethodName=sMethodName;
            self.prepareODEData();
        end
        function ellTubeRel=getEllTubes(self)
            import gras.gen.SquareMatVector;
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            self.build();
            ellTubeRel=self.ellTubeRel;
        end
    end
end