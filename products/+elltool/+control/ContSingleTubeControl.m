classdef ContSingleTubeControl
    %
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        controlVectorFunct
    end
    %
    methods
        function self = ContSingleTubeControl(properEllTube,...
                probDynamicsList, goodDirSetList,inDownScaleKoeff)
            % CONTSINGLETUBECONTROL constructes an object for 
            %  control synthesis for a continuous time system based on a
            %  single ellipsoidal tube from any predetermined position 
            %  (t,x) and corresponding trajectory
            %
            % Input:
            %     regular:
            %         properEllTube: gras.ellapx.smartdb.rels.EllTube
            %         object - an ellipsoidal tube that is used for
            %         constructing of contol synthesis
            % 
            %         probDynamicsList: cellArray of 
            %         gras.ellapx.lreachplain.probdyn.LReachProblemLTIDynamics
            %         objects - provides information about system's dynamics 
            % 
            %         goodDirSetList: cellArray of
            %         gras.ellapx.lreachplain.GoodDirsContinuousLTI objects
            %         - provides information about 'good directions'
            % 
            %         indTube: index of ellipsoidal tube used for
            %         constructing control synthesis 
            % 
            %         inDownScaleKoeff: scaling coefficient for internal
            %         ellipsoid tube approximation
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $ 
            % $Date: 2015-30-10 $
            %            
            self.properEllTube = properEllTube;
            self.probDynamicsList = probDynamicsList;
            self.goodDirSetList = goodDirSetList;
            self.downScaleKoeff = inDownScaleKoeff;
            self.controlVectorFunct = elltool.control.ControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,inDownScaleKoeff);
        end


        function result = getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            % GETTRAJECTORY - returns a trajectory corresponding
            % to constructed control synthesis 
            % 
            % Input:
            %   regular:
            %       x0Vec - double[nDims,1], where nDims is 
            %           a dimentionality of phase space - position 
            %           the syntesis is to be constructed from
            % 
            %         switchSysTimeVec: double[1,] - system switch time
            %           moments vector
            % 
            %         isX0inSet: logical[1,1] showing whether given
            %           x0Vec is in the solvability domain
            % 
            % Output:
            %   trajectoryMat - double[n,] where n is a dimentionality
            %       of the phase space - trajectory, that corresponds
            %       to constructed control synthesis
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $ 
            % $Date: 2015-30-10 $
            %
            import modgen.common.throwerror;
            ERR_TOL = 1e-4;
            REL_TOL = 1e-4;
            ABS_TOL = 1e-4;
            trajectory = [];
            trajectory_time = [];
            switchTimeVecLenght = length(switchSysTimeVec);
            SOptions = odeset('RelTol',REL_TOL,'AbsTol',ABS_TOL);
            self.properEllTube.scale(@(x)1/sqrt(self.downScaleKoeff),'QArray'); 

            for iSwitch = 1:switchTimeVecLenght-1                 
                iSwitchBack = switchTimeVecLenght - iSwitch;

                tStart = switchSysTimeVec(iSwitch);
                tFin = switchSysTimeVec(iSwitch+1);
                
                indFin = find(self.properEllTube.timeVec{1} == tFin);
                AtMat = self.probDynamicsList{iSwitchBack}.getAtDynamics();
                
                [cur_time,odeResMat] = ode45(@(t,y)ode(t,y,AtMat,self.controlVectorFunct,tFin,tStart),[tStart tFin],x0Vec',SOptions);

                q1Vec = self.properEllTube.aMat{1}(:,indFin);
                q1Mat = self.properEllTube.QArray{1}(:,:,indFin);
                
                currentScalProd = dot(odeResMat(end,:)'-q1Vec,q1Mat\(odeResMat(end,:)'-q1Vec));
                
                if (isX0inSet)&&(currentScalProd > 1 + ERR_TOL)
                    throwerror('TestFails', ['the result of test does not ',...
                        'correspond with theory, current scalar production is ',...
                        num2str(currentScalProd), ' while isX0inSet is ', num2str(isX0inSet), ';', num2str(iSwitchBack) ]);
                end
                
                x0Vec = odeResMat(end,:);
                trajectory = cat(1,trajectory,odeResMat);
                trajectory_time = cat(1,trajectory_time,cur_time);
            end
            
            result.trajectory = trajectory;
            result.trajectory_time = trajectory_time;
            
            function dyMat = ode(time,yMat,AtMat,controlFuncVec,tFin,tStart)
               dyMat = -AtMat.evaluate(tFin-time+tStart)*yMat + controlFuncVec.evaluate(yMat,time);
            end            
        end
        
        function controlFunc = getControlFunction(self)
            % GETCONTROLFUNCTION -  controlVectorFunct getter
            controlFunc = self.controlVectorFunct.clone();
        end
        
        function properEllTube = getProperEllTube(self)
            % GETPROPERELLTUBE - properEllTube getter
            properEllTube = self.properEllTube.clone();
        end
        
    end
end