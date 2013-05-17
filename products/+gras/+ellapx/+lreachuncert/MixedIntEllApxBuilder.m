classdef MixedIntEllApxBuilder<gras.ellapx.gen.ATightEllApxBuilder
    properties (Constant)
        APPROX_SCHEMA_NAME = 'InternalMixed'
        APPROX_SCHEMA_DESCR = 'Internal approximation with regularization'
        APPROX_TYPE = gras.ellapx.enums.EApproxType.Internal
        N_TIME_POINTS = 100
    end
    properties (Access=private)
        mixingStrength
        mixingProportionsMat
        ellTubeRel
        AtDynamics
        BPBTransDynamics
        CQCTransDynamics
        ltSplineList
        goodDirSetObj
    end
    methods (Access=protected)
        function varargout = calcEllApxMatrixDeriv(self,t,varargin)
            nGoodDirs = self.getNGoodDirs();
            AMat = self.AtDynamics.evaluate(t);
            BPBTransMat = self.BPBTransDynamics.evaluate(t);
            CQCTransMat = self.CQCTransDynamics.evaluate(t);
            BPBTransSqrtMat = gras.la.sqrtmpos(BPBTransMat);
            %
            varargout = cell(1,nGoodDirs);
            %
            for iGoodDir = 1:nGoodDirs
                QMat = varargin{iGoodDir};
                %
                % dynamics and contol component
                %
                QSqrtMat = gras.la.sqrtmpos(QMat);
                ltVec = self.ltSplineList{iGoodDir}.evaluate(t);
                SMat = self.getOrthTranslMatrix(QSqrtMat,BPBTransSqrtMat,...
                    BPBTransSqrtMat*ltVec,QSqrtMat*ltVec);
                uMat = AMat*QMat + QSqrtMat*SMat*BPBTransSqrtMat;
                %
                % disturbance component
                %
                isDisturbance = sum(abs(CQCTransMat(:))) > self.calcPrecision;
                if isDisturbance
                    piNumerator = dot(ltVec, CQCTransMat*ltVec);
                    piDenominator = dot(ltVec, QMat*ltVec);
                    if piNumerator <= 0 || piDenominator <= 0
                        if min(eig(CQCTransMat)) <= 0
                            modgen.common.throwerror('wrongInput',...
                                ['degenerate matrices C,Q for disturbance ',...
                                'contraints are not supported']);
                        else
                            modgen.common.throwerror('wrongInput',...
                                'the estimate has degraded for unknown reason');
                        end
                    end
                    piFactor = realsqrt(piNumerator/piDenominator);
                    vMat = piFactor*QMat + CQCTransMat/piFactor;
                else
                    vMat = 0;
                end
                %
                % convex combination component
                %
                mMat = -QMat;
                for jGoodDir = 1:nGoodDirs
                    mMat = mMat+self.mixingProportionsMat(iGoodDir,...
                        jGoodDir)*varargin{jGoodDir};
                end
                %
                % derivative
                %
                varargout{iGoodDir} = uMat + uMat.' - vMat + ...
                    self.mixingStrength*mMat;
            end
        end
    end
    methods (Access=private)
        function self=prepareODEData(self)
            pDefObj = self.getProblemDef();
            %
            self.AtDynamics = pDefObj.getAtDynamics();
            self.BPBTransDynamics = pDefObj.getBPBTransDynamics();
            self.CQCTransDynamics = pDefObj.getCQCTransDynamics();
            self.ltSplineList = ...
                self.getGoodDirSet().getGoodDirOneCurveSplineList();
        end
        %
        function build(self)
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
                removeFirstPoint = true;
            else
                removeFirstPoint = false;
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
            if removeFirstPoint
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
        function self=MixedIntEllApxBuilder(pDynObj,goodDirSetObj,...
                timeLimsVec,calcPrecision,varargin)
            import gras.ellapx.lreachuncert.MixedIntEllApxBuilder;
            import gras.gen.MatVector;
            import modgen.common.type.simple.*;
            %
            self = self@gras.ellapx.gen.ATightEllApxBuilder(pDynObj,...
                goodDirSetObj,timeLimsVec,...
                MixedIntEllApxBuilder.N_TIME_POINTS,calcPrecision);
            %
            [~,~,sMethodName,mixingStrength,mixingProportionsCMat] = ...
                modgen.common.parseparext(varargin,...
                {'selectionMethodForSMatrix','mixingStrength',...
                'mixingProportions'}, 0, 3); %#ok
            mMat = cell2mat(mixingProportionsCMat);
            %
            checkgen(mixingStrength,'x>=0'); %#ok
            checkgenext(['size(x1,1)==size(x1,2) && size(x1,1)==x2 && '...
                'all(x1(:)>=0) && max(abs(sum(x1,2)-ones(x2,1)))<x3'],...
                3,mMat,goodDirSetObj.getNGoodDirs(),calcPrecision);
            %
            self.mixingStrength = mixingStrength; %#ok
            self.mixingProportionsMat = mMat;
            self.sMethodName = sMethodName;
            self.goodDirSetObj = goodDirSetObj;
            self.prepareODEData();
        end
        %
        function ellTubeRel = getEllTubes(self)
            self.build();
            ellTubeRel = self.ellTubeRel;
        end
    end
end