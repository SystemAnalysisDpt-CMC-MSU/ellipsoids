classdef ApproxProblemPropertyBuilder
    methods (Static, Access=private)
        function lMat = autoGoodDirs(nGoodDirs, spaceVec)
            sysDim = length(spaceVec);
            lMat = zeros(sysDim,nGoodDirs);
            nProjDims = sum(spaceVec);
            %
            switch nProjDims
                case 2
                    [xVec,yVec] = gras.geom.circlepart(nGoodDirs,[0,pi]);
                    pMat = [xVec,yVec];
                case 3
                    pMat = gras.geom.spherepart(nGoodDirs);
                otherwise
                    modgen.common.throwerror('wrongInput', ['auto '...
                        'generation mode is not supported for '...
                        'dimensions greater than 3']);
            end
            %
            lMat(logical(spaceVec),:) = pMat.';
        end
    end
    %
    methods (Static)
        function [pDynObj,goodDirSetObj] = build(confRepoMgr,...
                sysConfRepoMgr, logger)
            import gras.ellapx.uncertcalc.ApproxProblemPropertyBuilder;
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            import gras.ellapx.gen.RegProblemDynamicsFactory;
			import gras.ellapx.lreachplain.GoodDirsContinuousFactory
            %
            % we need PRECISION_FACTOR because this data is later used
            % for solving ODE which also introduces its own imprecision
            %
            PRECISION_FACTOR = 0.1;
            calcPrecision = confRepoMgr.getParam(...
                'genericProps.calcPrecision')*PRECISION_FACTOR;
            %
            % create problem dynamics
            %
            AtDefMat = sysConfRepoMgr.getParam('At');
            BtDefMat = sysConfRepoMgr.getParam('Bt');
            CtDefMat = sysConfRepoMgr.getParam('Ct');
            PtDefMat = sysConfRepoMgr.getParam('control_restriction.Q');
            ptDefVec = sysConfRepoMgr.getParam('control_restriction.a');
            QtDefMat = sysConfRepoMgr.getParam('disturbance_restriction.Q');
            qtDefVec = sysConfRepoMgr.getParam('disturbance_restriction.a');
            X0DefMat = sysConfRepoMgr.getParam('initial_set.Q');
            x0DefVec = sysConfRepoMgr.getParam('initial_set.a');
            tLims = [sysConfRepoMgr.getParam('time_interval.t0'),...
                sysConfRepoMgr.getParam('time_interval.t1')];
            %
            isRegEnabled =...
                confRepoMgr.getParam('regularizationProps.isEnabled');
            isJustCheck =...
                confRepoMgr.getParam('regularizationProps.isJustCheck');
            regTol = confRepoMgr.getParam('regularizationProps.regTol');
            %
            tStart=tic;
            pDynObj = LReachProblemDynamicsFactory.createByParams(...
                AtDefMat,BtDefMat,PtDefMat,ptDefVec,CtDefMat,...
                QtDefMat,qtDefVec,X0DefMat,x0DefVec,tLims,calcPrecision);
            pDynObj = RegProblemDynamicsFactory.create(pDynObj,...
                isRegEnabled, isJustCheck, regTol);
            logger.info(...
                sprintf(['building interpolation of the problem definition, ',...
                'calc. precision=%d, time elapsed =%s sec.'],...
                calcPrecision,num2str(toc(tStart))));
            %
            % build good directions at time "s"
            %
            tStart = tic;
            sTime = confRepoMgr.getParam('goodDirSelection.selectionTime');
            methodName = confRepoMgr.getParam('goodDirSelection.methodName');
            SMethodDefs = confRepoMgr.getParam('goodDirSelection.methodProps');
            SMethodProps = SMethodDefs.(methodName);
            switch methodName
                case 'auto'
                    nGoodDirs = SMethodProps.nGoodDirs;
                    spaceVec = SMethodProps.goodDirSpaceVec;
                    lsGoodDirMat = ...
                        ApproxProblemPropertyBuilder.autoGoodDirs(...
                        nGoodDirs,spaceVec);
                case 'manual'
                    setName = SMethodProps.lsGoodDirSetName;
                    lGoodDirList=SMethodProps.lsGoodDirSets.(setName);
                    nGoodDirs=length(lGoodDirList);
                    sysDim=sysConfRepoMgr.getParam('dim');
                    lsGoodDirMat=zeros(sysDim,nGoodDirs);
                    for iGoodDir = 1:nGoodDirs
                        lsGoodDirMat(:,iGoodDir)=transpose(...
                            lGoodDirList{iGoodDir});
                    end;
                    normVec=sum(lsGoodDirMat.*lsGoodDirMat);
                    indVec=find(normVec);
                    normVec(indVec)=realsqrt(normVec(indVec));
                    lsGoodDirMat(:,indVec)=lsGoodDirMat(:,indVec)./...
                        normVec(ones(1,sysDim),indVec);
                otherwise,
                    modgen.common.throwerror('wrongInput',...
                        'unsupported goodDirGenerationMode');
            end
            %
            % build good direction curves
            %
            goodDirSetObj = GoodDirsContinuousFactory.create(pDynObj,...
                sTime,lsGoodDirMat,calcPrecision);
            logger.info(...
                sprintf(['Building good directions at time %d, ',...
                'calc. precision=%d, time elapsed =%s sec.'],...
                sTime,calcPrecision,num2str(toc(tStart))));
        end
    end
end
