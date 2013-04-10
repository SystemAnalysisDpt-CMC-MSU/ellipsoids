classdef ExtIntEllApxBuilder<gras.ellapx.gen.ATightEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME='ExtIntUncert'
        APPROX_SCHEMA_DESCR='External and internal approximation based on matrix ODEs for (Q)'
        N_TIME_POINTS=100;
    end
    properties (Access=private)
        sMethodName
        ellTubeRel
        slBPBlSqrtDynamicsList
        slCQClSqrtDynamicsList
        BPBTransSqrtLDynamicsList
        CQCTransSqrtLDynamicsList
        ltSplineList
        %
        minQMatEig
        %
        goodDirSetObj
        absTol
    end
    methods (Access=protected)
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
        %
        function resObj=getBPBTransSqrtDynamics(self,iGoodDir)
            resObj=self.BPBTransSqrtDynamicsList{iGoodDir};
        end
        function fHandle=getEllApxMatrixDerivFunc(self,iGoodDir)
            fHandle=...
                @(t,varargin)calcEllApxMatrixDeriv(self,...
                self.getProblemDef().getAtDynamics,...
                self.getProblemDef().getBPBTransDynamics,...
                self.getProblemDef().getCQCTransDynamics,...
                self.slBPBlSqrtDynamicsList{iGoodDir},...
                self.slCQClSqrtDynamicsList{iGoodDir},...
                self.BPBTransSqrtLDynamicsList{iGoodDir},...
                self.CQCTransSqrtLDynamicsList{iGoodDir},...
                self.ltSplineList{iGoodDir},...
                t,varargin{:});
        end
        function [isStrictViol,regQIntMat,regQExtMat]=...
                calcRegEllApxMatrix(self,QIntMat,QExtMat)
            STRICT_Q_MAT_EIG_FACTOR=0.1;
            TOL_ADJUSTMNET=100*eps;
            minQMatEig=self.minQMatEig;
            strinctMinQMatEig=minQMatEig*STRICT_Q_MAT_EIG_FACTOR;
            %
            [VMat,DMat]=eig(QIntMat,'nobalance');
            dVec=diag(DMat);
            isStrictViol=any(dVec-strinctMinQMatEig<0);
            if ~isStrictViol
                if any(dVec<minQMatEig)
                    mVec=-min(dVec-minQMatEig,0)+TOL_ADJUSTMNET;
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
        function [dQIntMat,dQExtMat]=calcEllApxMatrixDeriv(self,AtDynamics,...
                BPBTransDynamics,CQCTransDynamics,...
                slBPBlSqrtDynamics,slCQClSqrtDynamics,...
                BPBTransSqrtLDynamics,CQCTransSqrtLDynamics,...
                ltSpline,t,QIntMat,QExtMat)
            import modgen.common.throwerror;
            import gras.la.ismatposdef;
            A=AtDynamics.evaluate(t);
            ltVec=ltSpline.evaluate(t);
            %
            %% Internal approximation
            rSqrtlVec=BPBTransSqrtLDynamics.evaluate(t);
            R=BPBTransDynamics.evaluate(t);
            R_sqrt=gras.la.sqrtmpos(R);
            %
            D=CQCTransDynamics.evaluate(t);
            D_sqrt=gras.la.sqrtmpos(D);
            %
            [VMat,DMat]=eig(QIntMat);
            if ~ismatposdef(QIntMat,self.absTol,true)
                throwerror('wrongState','internal approx has degraded');
            end
            Q_star=VMat*sqrt(DMat)*transpose(VMat);
            S=self.getOrthTranslMatrix(Q_star,R_sqrt,rSqrtlVec,Q_star*ltVec);
            %
            piNumerator=slCQClSqrtDynamics.evaluate(t);
            piDenominator=sqrt(sum((QIntMat*ltVec).*ltVec));
            if (piNumerator<=0)||(piDenominator<=0)
                if ~ismatposdef(D,self.absTol)
                    throwerror('wrongInput',...
                        ['degenerate matrices C,Q for disturbance ',...
                        'contraints are not supported']);
                else
                    throwerror('wrongInput',...
                        'the estimate has degraded, reason unknown');
                end
            end
            %
            tmp=(A*Q_star+R_sqrt*transpose(S))*transpose(Q_star);
            dQIntMat=tmp+transpose(tmp)-...
                piNumerator.*QIntMat./piDenominator-...
                piDenominator.*D./piNumerator;
            %
            %% External approximation
            [VMat,DMat]=eig(QExtMat);
            if ~ismatposdef(QExtMat,self.absTol)
                throwerror('wrongState','external approx has degraded');
            end
            Q_star=VMat*sqrt(DMat)*transpose(VMat);
            piNumerator=slBPBlSqrtDynamics.evaluate(t);
            piDenominator=sqrt(sum((QExtMat*ltVec).*ltVec));
            dSqrtlVec=CQCTransSqrtLDynamics.evaluate(t);
            S=self.getOrthTranslMatrix(Q_star,D_sqrt,dSqrtlVec,Q_star*ltVec);
            tmp=(A*Q_star-D_sqrt*transpose(S))*transpose(Q_star);
            dQExtMat=tmp+transpose(tmp)+...
                piNumerator.*QExtMat./piDenominator+...
                piDenominator.*R./piNumerator;
        end
    end
    methods (Access=private)
        function self=prepareODEData(self)
            import gras.ellapx.common.*;
            import gras.ellapx.lreachplain.IntEllApxBuilder;
            import gras.mat.MatrixOperationsFactory;
            %
            nGoodDirs=self.getNGoodDirs();
            pDefObj=self.getProblemDef();
            timeVec=pDefObj.getTimeVec;
            %
            % calculate <l,Ml>^{1/2} and M^{1/2}l for BPB' and CQC'
            %
            matOpFactory = MatrixOperationsFactory.create(timeVec);
            %
            BPBTransDynamics = pDefObj.getBPBTransDynamics();
            CQCTransDynamics = pDefObj.getCQCTransDynamics();
            BPBTransSqrtDynamics = matOpFactory.sqrtmpos(BPBTransDynamics);
            CQCTransSqrtDynamics = matOpFactory.sqrtmpos(CQCTransDynamics);
            %
            self.ltSplineList = ...
                self.getGoodDirSet().getGoodDirOneCurveSplineList();
            %
            self.slBPBlSqrtDynamicsList = cell(1, nGoodDirs);
            self.slCQClSqrtDynamicsList = cell(1, nGoodDirs);
            self.BPBTransSqrtLDynamicsList = cell(1, nGoodDirs);
            self.CQCTransSqrtLDynamicsList = cell(1, nGoodDirs);
            %
            for iGoodDir = 1:nGoodDirs
                ltSpline = self.ltSplineList{iGoodDir};
                %
                self.slBPBlSqrtDynamicsList{iGoodDir} = ...
                    matOpFactory.quadraticFormSqrt(BPBTransDynamics,ltSpline);
                self.slCQClSqrtDynamicsList{iGoodDir} = ...
                    matOpFactory.quadraticFormSqrt(CQCTransDynamics,ltSpline);
                self.BPBTransSqrtLDynamicsList{iGoodDir} = ...
                    matOpFactory.rMultiply(BPBTransSqrtDynamics,ltSpline);
                self.CQCTransSqrtLDynamicsList{iGoodDir} = ...
                    matOpFactory.rMultiply(CQCTransSqrtDynamics,ltSpline);
            end
        end
        function build(self)
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            import gras.ellapx.common.*;
            import gras.gen.SquareMatVector;
            import gras.ode.MatrixSysODESolver;
            import modgen.logging.log4j.Log4jConfigurator;
            ODE_NORM_CONTROL='on';
            odeArgList={'NormControl',ODE_NORM_CONTROL,...
                'RelTol',self.getRelODECalcPrecision(),...
                'AbsTol',self.getAbsODECalcPrecision()};
            %
            sysDim=self.getProblemDef.getDimensionality();
            logger=Log4jConfigurator.getLogger();
            %
            %% Constructor solver object
            REG_MAX_STEP_TOL=0.05;
            REG_ABS_TOL=1e-8;
            N_MAX_REG_STEPS=6;
            fOdeReg=@(t,QIntMat,QExtMat)calcRegEllApxMatrix(self,...
                QIntMat,QExtMat);
            %
            solverObj=MatrixSysODESolver({[sysDim,sysDim],[sysDim,sysDim]},...
                @(varargin)gras.ode.ode45reg(varargin{:},...
                odeset(odeArgList{:}),...
                'regMaxStepTol',REG_MAX_STEP_TOL,...
                'regAbsTol',REG_ABS_TOL,...
                'nMaxRegSteps',N_MAX_REG_STEPS),...
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
            ltGoodDirArray=goodDirSetObj.getGoodDirCurveSpline(...
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
            %
            self=self@gras.ellapx.gen.ATightEllApxBuilder(pDefObj,...
                goodDirSetObj,timeLimsVec,...
                ExtIntEllApxBuilder.N_TIME_POINTS,calcPrecision);
            %
            [~,~,sMethodName,minQSqrtMatEig] = ...
                modgen.common.parseparext(varargin, ...
                {'selectionMethodForSMatrix','minQSqrtMatEig'}, 0, 2);
            %
            self.minQMatEig=minQSqrtMatEig*minQSqrtMatEig;
            self.goodDirSetObj=goodDirSetObj;
            self.sMethodName=sMethodName;
            self.prepareODEData();
            self.absTol=elltool.conf.Properties.getAbsTol();
        end
        function ellTubeRel=getEllTubes(self)
            import gras.gen.SquareMatVector;
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            self.build();
            ellTubeRel=self.ellTubeRel;
        end
    end
end