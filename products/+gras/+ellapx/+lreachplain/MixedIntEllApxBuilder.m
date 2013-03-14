classdef MixedIntEllApxBuilder<gras.ellapx.gen.ATightEllApxBuilder
    properties (Constant,GetAccess=private)
        APPROX_SCHEMA_NAME = 'InternalMixed'
        APPROX_SCHEMA_DESCR = 'Internal approximation with regularization'
        APPROX_TYPE = gras.ellapx.enums.EApproxType.Internal
        N_TIME_POINTS = 100
    end
    properties (Access=private)
        sMethodName
        ellTubeRel
        AtDynamics
        BPBTransSqrtDynamics
        ltSplineList
        goodDirSetObj
    end
    methods (Access=protected)
        function S = getOrthTranslMatrix(self,Q_star,R_sqrt,b,a)
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
        function varargout = calcEllApxMatrixDeriv(self,t,varargin)
            nGoodDirs = self.getNGoodDirs();
            AMat = self.AtDynamics.evaluate(t);
            BPBTransSqrtMat = self.BPBTransSqrtDynamics.evaluate(t);
            %
            varargout = cell(1,nGoodDirs);
            %
            for iGoodDir = 1:nGoodDirs
                QMat = varargin{iGoodDir};
                ltVec = self.ltSplineList{iGoodDir}.evaluate(t);
                %
                [VMat,DMat] = eig(QMat);
                QSqrtMat = VMat*sqrt(DMat)*(VMat.');
                SMat = self.getOrthTranslMatrix(QSqrtMat,...
                    BPBTransSqrtMat,BPBTransSqrtMat*ltVec,QSqrtMat*ltVec);
                tmp = (AMat*QSqrtMat+BPBTransSqrtMat*(SMat.'))*(QSqrtMat.');
                varargout{iGoodDir} = tmp + (tmp.');
            end
        end
    end
    methods (Access=private)
        function self=prepareODEData(self)
            import gras.ellapx.common.*;
            import gras.mat.MatrixOperationsFactory;
            %
            pDefObj = self.getProblemDef();
            %
            matOpFactory = MatrixOperationsFactory.create(pDefObj.getTimeVec());
            %
            self.AtDynamics = pDefObj.getAtDynamics();
            self.BPBTransSqrtDynamics = ...
                matOpFactory.sqrtm(pDefObj.getBPBTransDynamics());
            self.ltSplineList = ...
                self.getGoodDirSet().getGoodDirOneCurveSplineList();
        end
        function build(self)
            import gras.ellapx.common.*;
            import gras.ode.MatrixSysODESolver;
            import modgen.logging.log4j.Log4jConfigurator;
            logger = Log4jConfigurator.getLogger();
            %
            sysDim = self.getProblemDef.getDimensionality();
            nGoodDirs = self.getNGoodDirs();
            sTime = self.getGoodDirSet().getsTime();
            %
            % init ode solver
            %
            odeArgList = {'NormControl', 'on',...
                'RelTol',self.getRelODECalcPrecision(),...
                'AbsTol',self.getAbsODECalcPrecision()};
            odeHandle = @(varargin) ode45(varargin{:}, odeset(odeArgList{:}));
            sizeVecList = repmat({[sysDim,sysDim]},1,nGoodDirs);
            solverObj = MatrixSysODESolver(sizeVecList,odeHandle);
            %
            % determine time interval
            %
            pDefObj = self.getProblemDef();
            pDefTimeLimsVec = pDefObj.getTimeLimsVec();
            pStartTime = pDefTimeLimsVec(1);
            solveTimeVec = self.getTimeVec;
            resTimeVec = self.getTimeVec;
            if solveTimeVec(1) ~= pStartTime
                solveTimeVec = [pStartTime solveTimeVec];
                isFirstPointToRemove = true;
            else
                isFirstPointToRemove = false;
            end
            %
            % calculate approximations
            %
            logger.info(sprintf([...
                'solving ode for %d good direction(s) \n '...
                'defined at time %f...'],nGoodDirs,sTime));
            initQMatList = repmat({pDefObj.getX0Mat()},1,nGoodDirs);
            QArrayList = cell(1,nGoodDirs);
            [~,QArrayList{:}] = solverObj.solve(...
                {@self.calcEllApxMatrixDeriv},solveTimeVec,initQMatList{:});
            if isFirstPointToRemove
                QArrayList = cellfun(@(x) x(:,:,2:end), QArrayList,...
                    'UniformOutput', false);
            end
            %
            % create tubes
            %
            aMat = pDefObj.getxtDynamics.evaluate(resTimeVec);
            ltGoodDirArray = ...
                self.goodDirSetObj.getGoodDirCurveSpline().evaluate(resTimeVec);
            self.ellTubeRel = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                QArrayList,aMat,resTimeVec,ltGoodDirArray,...
                sTime,self.APPROX_TYPE,...
                self.APPROX_SCHEMA_NAME,self.APPROX_SCHEMA_DESCR,...
                self.getCalcPrecision);
        end
    end
    methods
        function self=MixedIntEllApxBuilder(pDefObj,goodDirSetObj,...
                timeLimsVec,calcPrecision,sMethodName)
            import gras.ellapx.lreachplain.MixedIntEllApxBuilder;
            self = self@gras.ellapx.gen.ATightEllApxBuilder(pDefObj,...
                goodDirSetObj,timeLimsVec,...
                MixedIntEllApxBuilder.N_TIME_POINTS,calcPrecision);
            self.goodDirSetObj = goodDirSetObj;
            self.sMethodName = sMethodName;
            self.prepareODEData();
        end
        function ellTubeRel = getEllTubes(self)
            self.build();
            ellTubeRel = self.ellTubeRel;
        end
    end
end