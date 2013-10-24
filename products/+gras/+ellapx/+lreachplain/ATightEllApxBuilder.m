classdef ATightEllApxBuilder<gras.ellapx.gen.ATightEllApxBuilder
    properties (Constant,GetAccess=protected)
        N_TIME_POINTS=100;
        NON_ZERO_DISTURBANCE_TOL=1e-14;
    end
    properties (Access=private)
        ellTubeRel
    end
    methods (Static)
        function  [QArray]=fCalcTube(self,...
              logger, solverObj,...
              lsGoodDirMat, sTime, isFirstPointToRemove,solveTimeVec,...
               fHandle, initValueMat)
    
                tStart=tic;
                logStr=sprintf(...
                    'solving ode for direction \n %s  defined at time %f',...
                    mat2str(lsGoodDirMat.'),sTime);
                logger.debug([logStr,'...']);

                [~,data_Q_star]=solverObj.solve(fHandle,...
                    solveTimeVec,initValueMat);
                if isFirstPointToRemove
                    data_Q_star(:,:,1)=[];
                end
                %
                QArray=self.adjustEllApxMatrixVec(data_Q_star);
                logger.debug(sprintf([logStr,':done, %.3f sec. elapsed'],...
                    toc(tStart)));
            end
        
    end    
    methods (Access=private)
        function build(self)
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            import gras.ellapx.common.*;
            import gras.gen.SquareMatVector;
            import gras.ode.MatrixODESolver;
            import modgen.logging.log4j.Log4jConfigurator;
            logger=Log4jConfigurator.getLogger();
            ODE_NORM_CONTROL='on';
            odeArgList={'NormControl',ODE_NORM_CONTROL,...
                'RelTol',self.getRelODECalcPrecision(),...
                'AbsTol',self.getAbsODECalcPrecision()};
            %
            sysDim=self.getProblemDef.getDimensionality();
            solverObj=MatrixODESolver([sysDim,sysDim],@ode45,...
                odeArgList{:});
            %
            nLDirs=self.getNGoodDirs;
            %
            lsGoodDirMat=self.getGoodDirSet().getlsGoodDirMat;
            sTime=self.getGoodDirSet().getsTime();
            %
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
            QArrayList=cell(1,nLDirs);
            %% Calculating internal approximation
             pCalc=elltool.pcalc.ParCalculator();
           
            
            lsGoodDirMat=(lsGoodDirMat(:, 1:nLDirs));
            [nGoodDirs]=size(lsGoodDirMat,1);
            lsGoodDirMatCVec=mat2cell(lsGoodDirMat,nGoodDirs,[ones(1,nLDirs)]);
            
            fHandleCVec=cell(1,nLDirs);
            for iDir=1:nLDirs
             fHandleCVec(iDir)={self.getEllApxMatrixDerivFunc(iDir)};
            end
            
            initValueMatCVec=cell(1,nLDirs);
            for iDir=1:nLDirs
              initValueMatCVec(iDir)={self.getEllApxMatrixInitValue(iDir)};
            end


            selfCVec=cell(1,nLDirs);
            sTimeCVec=cell(1,nLDirs);
            solverObjCVec=cell(1,nLDirs);
            isFirstPointToRemoveCVec=cell(1,nLDirs);
            loggerCVec=cell(1,nLDirs);
            solveTimeVecCVec=cell(1,nLDirs);
            
            selfCVec(:)={self};
            sTimeCVec(:)={sTime};
            solverObjCVec(:)={solverObj};
            isFirstPointToRemoveCVec(:)={isFirstPointToRemove};
            loggerCVec(:)={logger};
            solveTimeVecCVec(:)={solveTimeVec};
            
            
            [QArrayCVec]=pCalc.eval(@gras.ellapx.lreachplain.ATightEllApxBuilder.fCalcTube,selfCVec,...
              loggerCVec, solverObjCVec,...
              lsGoodDirMatCVec, sTimeCVec, isFirstPointToRemoveCVec,solveTimeVecCVec,...
               fHandleCVec, initValueMatCVec);
              QArrayList= QArrayCVec';   
            %
            aMat=pDefObj.getxtDynamics.evaluate(resTimeVec);
            %
            [apxSchemaName,apxSchemaDescr]=self.getApxSchemaNameAndDescr();
            apxType=self.getApxType();
            %
            goodDirSetObj=self.getGoodDirSet();
            sTime=goodDirSetObj.getsTime();
            ltGoodDirArray=goodDirSetObj.getRGoodDirCurveSpline(...
                ).evaluate(resTimeVec);
            %
            self.ellTubeRel=gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                QArrayList,aMat,resTimeVec,ltGoodDirArray,sTime,apxType,...
                apxSchemaName,apxSchemaDescr,self.getCalcPrecision);
        end
    end
    methods (Abstract,Access=protected)
        apxType=getApxType(self);
        [apxSchemaName,apxSchemaDescr]=getApxSchemaNameAndDescr(self);
    end
    methods (Abstract, Access=protected)
        fHandle=getEllApxMatrixDerivFunc(self,iGoodDir);
        QArray=adjustEllApxMatrixVec(self,QArray);
        initQMat=getEllApxMatrixInitValue(self,iGoodDir);
    end
    methods
        function self=ATightEllApxBuilder(pDefObj,goodDirSetObj,...
                timeLimsVec,calcPrecision)
            import gras.ellapx.common.*;
            import modgen.common.throwerror;
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            %
            %Since certain parameters of ellipsoidal approximation depend
            %on all configuration matrix components we need increase
            %precision. The resulting tolerance is proportional to the
            %cumulative tolerance in all matrix components. To account
            %for that fact we need to adjust a tolerance for
            %each matrix component.
            %
            self=self@gras.ellapx.gen.ATightEllApxBuilder(pDefObj,...
                goodDirSetObj,timeLimsVec,...
                ATightEllApxBuilder.N_TIME_POINTS,calcPrecision);
        end
        function ellTubeRel=getEllTubes(self)
            import gras.gen.SquareMatVector;
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            self.build();
            ellTubeRel=self.ellTubeRel;
        end
    end
end
