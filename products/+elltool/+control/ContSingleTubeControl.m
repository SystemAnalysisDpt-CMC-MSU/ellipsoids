classdef ContSingleTubeControl<elltool.control.ASingleTubeControl
    properties (Access = private)
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        switchSysTimeVec
        logger
        timeout
    end
    %
    methods
        function self=ContSingleTubeControl(properEllTube,...
                probDynamicsList,goodDirSetList,switchSysTimeVec,...
                inDownScaleKoeff,timeout)
            % CONTSINGLETUBECONTROL constructes an object for 
            % control synthesis for a continuous time system based on a
            % single ellipsoidal tube from any predetermined position 
            % (t,x) and corresponding trajectory
            %
            % Input:
            %   regular:
            %       properEllTube: gras.ellapx.smartdb.rels.EllTube[1,1]
            %           - an object containing ellipsoidal tube that is
            %           used for contol synthesis constructing
            %
            %       probDynamicsList: cell[1,nSysSwitches] - 
            %           gras.ellapx.lreachplain.probdyn.LReachProblemLTIDynamics[1,]
            %           - list of objects containing an information about
            %           the system dynamics
            %
            %       goodDirSetList: cell[1,nSysSwitches] -
            %           gras.ellapx.lreachplain.GoodDirsContinuousLTI[1,]
            %           - cellArray provides information about
            %           'good directions'
            %
            %       switchSysTimeVec: double[1,nSysSwitches-1] - 
            %           system switch time moments vector
            %
            %       inDownScaleKoeff: double[1,1] - scaling coefficient for
            %           internal ellipsoid tube approximation
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $ 
            % $Date: 2015-30-10 $
            %
            import elltool.logging.Log4jConfigurator;
            self.logger=Log4jConfigurator.getLogger();           
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.switchSysTimeVec=switchSysTimeVec;
            self.downScaleKoeff=inDownScaleKoeff;
            self.controlVectorFunct=...
                elltool.control.ControlVectorFunct(properEllTube,...
                self.probDynamicsList,self.goodDirSetList,...
                inDownScaleKoeff);
            self.timeout=timeout;
        end


        function [trajEvalTimeVec,trajectoryMat]=...
                    getTrajectory(self,x0Vec)
            % GETTRAJECTORY returns a trajectory corresponding
            % to constructed control synthesis 
            % 
            % Input:
            %   regular:
            %       x0Vec: double[nDims,1], where nDims is 
            %           a dimentionality of phase space - position 
            %           the syntesis is to be constructed from
            %
            % Output:
            %   trajEvalTimeVec: double[1,] - time vector, corresponding to
            %       constructed trajectory
            %
            %   trajectoryMat: double[nDims,] where nDims is a
            %       dimentionality of the phase space - trajectory, that
            %       corresponds to constructed control synthesis
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $ 
            % $Date: 2015-30-10 $
            %
            import modgen.common.throwerror;
            ERR_TOL=1e-4;
            relTol=elltool.conf.Properties.getRelTol();
            absTol=elltool.conf.Properties.getAbsTol();
            trajectoryMat=[];
            trajEvalTimeVec=[];
            switchTimeVecLength=length(self.switchSysTimeVec);
            self.logger.info(...
                sprintf('%d switches found',switchTimeVecLength)...
            );
            SOptions=odeset('RelTol',relTol,'AbsTol',absTol,...
                'Events',@stopByTimeout);
            self.properEllTube.scale(@(x)1/sqrt(self.downScaleKoeff),...
                'QArray'); 
            %
            q0Vec=self.properEllTube.aMat{1}(:,1);
            q0Mat=self.properEllTube.QArray{1}(:,:,1);
            isX0inSet=dot(x0Vec-q0Vec,q0Mat\(x0Vec-q0Vec));
            %
            for iSwitch = 1:switchTimeVecLength-1
                self.logger.info(sprintf(['Calculating trajectory '...
                    'between switches #%d and #%d'],iSwitch,iSwitch+1));
                iSwitchBack=switchTimeVecLength-iSwitch;
                %
                tStart=self.switchSysTimeVec(iSwitch);
                tFin=self.switchSysTimeVec(iSwitch+1);
                %
                indFin=find(self.properEllTube.timeVec{1}==tFin);
                AMat=self.probDynamicsList{iSwitchBack}.getAtDynamics();
                %
                timeMarker=tic;
                [curTrajEvalTimeVec,curTrajectoryMat,indTimeoutVec]=...
                    ode45(@(t,y)ode(t,y,AMat,self.controlVectorFunct,...
                            tStart,tFin,iSwitch),...
                        [tStart tFin],x0Vec.',SOptions);
                isTimeoutHappened=~isempty(indTimeoutVec);
                %
                q1Vec=self.properEllTube.aMat{1}(:,indFin);
                q1Mat=self.properEllTube.QArray{1}(:,:,indFin);
                %
                if isTimeoutHappened
                    throwerror('TestFails',...
                        'Timeout of calculating the trajectory');
                elseif isX0inSet
                    currentScalProd=dot(curTrajectoryMat(end,:).'-q1Vec,...
                        q1Mat\(curTrajectoryMat(end,:).'-q1Vec));
                    %
                    if currentScalProd > 1+ERR_TOL
                        throwerror('TestFails', ['the result of test '...
                            'does not correspond with theory, current '...
                            'scalar production at the end of system '...
                            'switch interval number ',...
                            num2str(iSwitchBack),' is '...
                            num2str(currentScalProd),', while the'...
                            ' original solvability domain actually'...
                            ' contains x(t0)']);
                    end
                end
                %
                x0Vec=curTrajectoryMat(end,:);
                trajectoryMat=vertcat(trajectoryMat,curTrajectoryMat);
                trajEvalTimeVec=...
                    vertcat(trajEvalTimeVec,curTrajEvalTimeVec);
            end
            %
            function dyMat=ode(tVal,yMat,AMat,controlFuncVec,...
                    tStart,tFin,indSwitch)
               dyMat = -AMat.evaluate(tFin-tVal+tStart)*yMat + ...
                   controlFuncVec.evaluate(yMat,tVal,indSwitch);
            end
            %
            function [value,isTerminal,direction]=stopByTimeout(T,Y)
                value=1;
                if toc(timeMarker)-self.timeout >= 0
                    value=0;
                    self.logger.warn(sprintf(['timeout=%d reached! '...
                        'stopping calculations...'],self.timeout));
                end
                isTerminal=true;
                direction=0;
            end
        end
    end
end