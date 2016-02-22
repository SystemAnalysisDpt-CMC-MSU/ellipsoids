classdef MixedIntEllApxBuilder<gras.ellapx.gen.ATightEllApxBuilder
    properties (Constant)
        APPROX_SCHEMA_NAME = 'InternalMixed'
        APPROX_SCHEMA_DESCR = 'Internal approximation with regularization'
        APPROX_TYPE = gras.ellapx.enums.EApproxType.Internal
    end
    properties (Access=private)
        mixingStrength
        mixingProportionsMat
        ellTubeRel
        bigAtDynamics
        bigBPBTransDynamics
        bigCQCTransDynamics
        ltSplineList
        goodDirSetObj
    end
    methods (Access=protected)
        function varargout = calcEllApxMatrixDeriv(self,t,varargin)
            nGoodDirs = self.getNGoodDirs();
            bigAMat = self.bigAtDynamics.evaluate(t);
            bigBPBTransMat = self.bigBPBTransDynamics.evaluate(t);
            bigCQCTransMat = self.bigCQCTransDynamics.evaluate(t);
            bigBPBTransSqrtMat = gras.la.sqrtmpos(bigBPBTransMat);
            %
            varargout = cell(1,nGoodDirs);
            %
            for iGoodDir = 1:nGoodDirs
                bigQMat = varargin{iGoodDir};
                %
                % dynamics and contol component
                %
                bigQSqrtMat = gras.la.sqrtmpos(bigQMat);
                ltVec = self.ltSplineList{iGoodDir}.evaluate(t);
                ltVec=ltVec./norm(ltVec);
                %
                bigSMat = self.getOrthTranslMatrix(bigQSqrtMat,...
                    bigBPBTransSqrtMat,bigBPBTransSqrtMat*ltVec,...
                    bigQSqrtMat*ltVec);
                %
                uMat = bigAMat*bigQMat+bigQSqrtMat*bigSMat*...
                    bigBPBTransSqrtMat;
                %
                % disturbance component
                %
                isDisturbance=sum(abs(bigCQCTransMat(:)))>self.absTol;
                if isDisturbance
                    piNumerator = dot(ltVec, bigCQCTransMat*ltVec);
                    piDenominator = dot(ltVec, bigQMat*ltVec);
                    if piNumerator <= self.absTol||...
                            piDenominator <= self.absTol
                        %
                        if ~gras.la.ismatposdef(bigCQCTransMat,self.absTol)
                            modgen.common.throwerror('wrongInput',...
                                ['matrices C,Q for disturbance ',...
                                'contraints are found to be degenerate',...
                                'with absolute precision =%g ',...
                                'which is not supported'],self.absTol);
                        else
                            modgen.common.throwerror('wrongInput',...
                                ['the estimate has degraded below ',...
                                'absolute precision level = %g for ',...
                                'unknown reason'],self.absTol);
                        end
                    end
                    piFactor = realsqrt(piNumerator/piDenominator);
                    vMat = piFactor*bigQMat + bigCQCTransMat/piFactor;
                else
                    vMat = 0;
                end
                %
                % convex combination component
                %
                mMat = -bigQMat;
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
            self.bigAtDynamics = pDefObj.getAtDynamics();
            self.bigBPBTransDynamics = pDefObj.getBPBTransDynamics();
            self.bigCQCTransDynamics = pDefObj.getCQCTransDynamics();
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
            bigQArrayList = cell(1,nGoodDirs);
            [~,bigQArrayList{:}] = solverObj.solve(...
                {@self.calcEllApxMatrixDeriv},solveTimeVec,initQMatList{:});
            if removeFirstPoint
                bigQArrayList = cellfun(@(x) x(:,:,2:end), bigQArrayList,...
                    'UniformOutput', false);
            end
            %
            % create tubes
            %
            aMat = pDefObj.getxtDynamics.evaluate(resTimeVec);
            ltGoodDirArray = ...
                self.goodDirSetObj.getGoodDirCurveSpline().evaluate(...
                resTimeVec);
            %
            self.ellTubeRel = ...
                gras.ellapx.smartdb.rels.EllTube.fromQArrays(...
                bigQArrayList,aMat,resTimeVec,ltGoodDirArray,...
                sTime,self.APPROX_TYPE,...
                self.APPROX_SCHEMA_NAME,self.APPROX_SCHEMA_DESCR,...
                self.absTol, self.relTol);
        end
    end
    methods
        function self=MixedIntEllApxBuilder(pDynObj,goodDirSetObj,...
                timeLimsVec,relTol,absTol,varargin)
            import gras.ellapx.lreachuncert.MixedIntEllApxBuilder;
            import gras.gen.MatVector;
            import modgen.common.type.simple.*;
            import modgen.common.throwerror;
            import gras.ellapx.lreachuncert.probdyn.PlainAsUncertWrapperProbDynamics;
            %
            if ~isa(pDynObj,...
                    'gras.ellapx.lreachuncert.probdyn.IReachProblemDynamics')
                if isa(pDynObj,...
                        'gras.ellapx.lreachplain.probdyn.IReachProblemDynamics')
                    pDynObj=PlainAsUncertWrapperProbDynamics(pDynObj);
                else
                    throwerror('wrongInput',...
                        ['this ellipsoidal tube builder \n (%s) \n',...
                        'expected a problem system dynamics object but\n',...
                        'received an object of type \n (%s)'],...
                        mfilename('class'),class(pDynObj));
                end
            end
            %
            [unparsedArgList,~,sMethodName,mixingStrength,...
                mixingProportionsCMat] = ...
                modgen.common.parseparext(varargin,...
                {'selectionMethodForSMatrix','mixingStrength',...
                'mixingProportions'},[0 4],'isObligatoryPropVec',...
                [true true true]);
            %
            self = self@gras.ellapx.gen.ATightEllApxBuilder(pDynObj,...
                goodDirSetObj,timeLimsVec,relTol,absTol,unparsedArgList{:});
            %
            mMat = cell2mat(mixingProportionsCMat);
            %
            checkgen(mixingStrength,'x>=0');
            checkgenext(['size(x1,1)==size(x1,2) && size(x1,1)==x2 && '...
                'all(x1(:)>=0) && max(abs(sum(x1,2)-ones(x2,1)))<x3'],...
                3,mMat,goodDirSetObj.getNGoodDirs(),absTol);
            %
            self.mixingStrength = mixingStrength;
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