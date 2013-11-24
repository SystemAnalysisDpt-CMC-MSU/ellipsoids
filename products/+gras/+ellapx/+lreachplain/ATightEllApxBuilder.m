classdef ATightEllApxBuilder<gras.ellapx.gen.ATightEllApxBuilder
    properties (Constant,GetAccess=protected)
        N_TIME_POINTS=100;
        NON_ZERO_DISTURBANCE_TOL=1e-14;
    end
    properties (Access=private)
        ellTubeRel
    end
    methods (Access=private)
        function build(self)
            import gras.ellapx.lreachplain.ATightEllApxBuilder;
            import gras.ellapx.common.*;
            import gras.gen.SquareMatVector;
            import gras.ode.MatrixSysODERegInterpSolver;
            import modgen.logging.log4j.Log4jConfigurator;
            logger=Log4jConfigurator.getLogger();
            ODE_NORM_CONTROL='on';
            odeArgList={'NormControl',ODE_NORM_CONTROL,...
                'RelTol',self.getRelODECalcPrecision(),...
                'AbsTol',self.getAbsODECalcPrecision()};
            %
            sysDim=self.getProblemDef.getDimensionality();
%             solverObj=MatrixODESolver([sysDim,sysDim],@ode45,...
%                 odeArgList{:});
            
            solverObj=MatrixSysODERegInterpSolver({[sysDim,sysDim]},...
                @(varargin)gras.ode.ode45reg(varargin{:},...
                odeset(odeArgList{:})),'outArgStartIndVec',[1 2]);            
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
            interpObjList=cell(1,nLDirs);
            
            function varargout=fAdvRegFunc(~,varargin)
                    nEqs=length(varargin);
                    varargout{1}=false;
                    for iEq=1:nEqs
                        varargout{iEq+1} = varargin{iEq};
                    end
            end
            %% Calculating internal approximation
            for l=1:1:nLDirs
                tStart=tic;
                logStr=sprintf(...
                    'solving ode for direction \n %s  defined at time %f',...
                    mat2str(lsGoodDirMat(:,l).'),sTime);
                logger.debug([logStr,'...']);
                fHandle=self.getEllApxMatrixDerivFunc(l);
                initValueMat=self.getEllApxMatrixInitValue(l);
                %
                [~,data_Q_star,~,interpObj]=solverObj.solve(...
                    {fHandle,@fAdvRegFunc},solveTimeVec,initValueMat);
                interpObj = gras.ode.MatrixODE45InterpFunc(interpObj);
                if isFirstPointToRemove
                    data_Q_star(:,:,1)=[];
                end
                %
                QArrayList{l}=self.adjustEllApxMatrixVec(data_Q_star);
                interpObjList{l}=interpObj;
                logger.debug(sprintf([logStr,':done, %.3f sec. elapsed'],...
                    toc(tStart)));
            end
            %
            aMatInterpObj = pDefObj.getxtDynamics();
            aMat=aMatInterpObj.evaluate(resTimeVec);
            %
            [apxSchemaName,apxSchemaDescr]=self.getApxSchemaNameAndDescr();
            apxType=self.getApxType();
            %
            goodDirSetObj=self.getGoodDirSet();
            ltGoodDirInterpObj = goodDirSetObj.getRGoodDirCurveInterpObj();
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
