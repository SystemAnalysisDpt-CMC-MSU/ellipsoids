classdef ApproxProblemPropertyBuilder
    methods (Static, Access=private)
        function l_data=get_l_data3_r(lpoints_num,pvec)
            psize=size(pvec);
            dim=sum(pvec);
            num= pvec;
            nd=randn([dim lpoints_num]);
            norm=sum(nd.*nd,1);
            l_data=zeros([psize(2) lpoints_num]);
            l_data(num,:)=nd./norm(ones(1,dim),:);
        end
        function l_data=get_l_data2(lpoints_num,pvec,range)
            import gras.geom.circlepart;
            psize=size(pvec);
            dirMat=circlepart(lpoints_num,range);
            l_data=zeros(psize(2),lpoints_num);
            l_data(logical(pvec),:)=dirMat.';
        end
        
    end
    methods (Static)
        function [pDefObj,goodDirSetObj]=build(confRepoMgr,...
                sysConfRepoMgr)
            import gras.ellapx.uncertcalc.ApproxProblemPropertyBuilder;
            import modgen.common.throwerror;
            import gras.ellapx.uncertcalc.log.Log4jConfigurator;
            %
            logger=Log4jConfigurator.getLogger();            
            %
            %% exctract calculation precision
            PRECISION_FACTOR=0.1;%we need this because this data is 
            %later used for solving ODE which also introduces its own
            %inprecision
            calcPrecision=...
                confRepoMgr.getParam('genericProps.calcPrecision')*...
                PRECISION_FACTOR;
            %
            %% Create problem definition object
            AtDefMat=sysConfRepoMgr.getParam('At');
            BtDefMat=sysConfRepoMgr.getParam('Bt');
            CtDefMat=sysConfRepoMgr.getParam('Ct');
            %
            PtDefMat=sysConfRepoMgr.getParam('control_restriction.Q');
            ptDefVec=sysConfRepoMgr.getParam('control_restriction.a');
            %
            QtDefMat=sysConfRepoMgr.getParam('disturbance_restriction.Q');
            qtDefVec=sysConfRepoMgr.getParam('disturbance_restriction.a');
            %
            X0DefMat=sysConfRepoMgr.getParam('initial_set.Q');
            x0DefVec=sysConfRepoMgr.getParam('initial_set.a');
            %
            tLims=[sysConfRepoMgr.getParam('time_interval.t0'),...
                sysConfRepoMgr.getParam('time_interval.t1')];
            %
            tStart=tic;            
            import gras.ellapx.lreachuncert.probdyn.LReachProblemDynamicsFactory;
            pDefObj = LReachProblemDynamicsFactory.createByParams(...
                AtDefMat,BtDefMat,PtDefMat,ptDefVec,CtDefMat,...
                QtDefMat,qtDefVec,X0DefMat,x0DefVec,tLims,calcPrecision);
            logger.info(...
                sprintf(['building interpolation of the problem definition, ',...
                'calc. precision=%d, time elapsed =%s sec.'],...
                calcPrecision,num2str(toc(tStart))));
            %
            %% Build good directions at time "s"
            tStart=tic;
            sysDim=sysConfRepoMgr.getParam('dim');
            sTime=confRepoMgr.getParam('goodDirSelection.selectionTime');
            methodName=confRepoMgr.getParam('goodDirSelection.methodName');
            SMethodDefs=confRepoMgr.getParam('goodDirSelection.methodProps');
            SMethodProps=SMethodDefs.(methodName);
            switch methodName
                case 'auto',
                    nGoodDirs=SMethodProps.nGoodDirs;
                    goodDirSpaceVec=SMethodProps.goodDirSpaceVec;
                    nProjDims=sum(goodDirSpaceVec);                    
                    switch nProjDims
                        case 2,
                            lsGoodDirMat=...
                                ApproxProblemPropertyBuilder.get_l_data2(...
                                nGoodDirs,...
                                goodDirSpaceVec,[0 pi]);
                        case 3,...
                            lsGoodDirMat=...
                            ApproxProblemPropertyBuilder.get_l_data3_r(...
                            nGoodDirs,...
                            goodDirSpaceVec);
                        otherwise , error_pr;
                    end;
                case 'manual',
                    setName=SMethodProps.lsGoodDirSetName;
                    lGoodDirList=SMethodProps.lsGoodDirSets.(setName);
                    cl=length(lGoodDirList);
                    lsGoodDirMat=zeros(sysDim,cl);
                    for k=1:1:cl
                        lsGoodDirMat(:,k)=transpose(...
                            lGoodDirList{k});
                    end;
                    norm=sum(lsGoodDirMat.*lsGoodDirMat);
                    num=find(norm);
                    norm(num)=sqrt(norm(num));
                    lsGoodDirMat(:,num)=lsGoodDirMat(:,num)./...
                        norm(ones(1,sysDim),num);
                otherwise,
                    throwerror('wrongInput',...
                        'unsupported goodDirGenerationMode');
            end
            %% Build good direction curves
            goodDirSetObj=gras.ellapx.lreachplain.GoodDirectionSet(...
                pDefObj,sTime,lsGoodDirMat,calcPrecision);
            logger.info(...
                sprintf(['Building good directions at time %d, ',...
                'calc. precision=%d, time elapsed =%s sec.'],...
                sTime,calcPrecision,num2str(toc(tStart))));                
        end
    end
end
