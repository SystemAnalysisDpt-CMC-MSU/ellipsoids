classdef Control
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        controlVectorFunct
    end
    methods
        function self=Control(properEllTube,...
                probDynamicsList, goodDirSetList,indTube,inDownScaleKoeff)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.downScaleKoeff=inDownScaleKoeff;
            self.controlVectorFunct=elltool.control.ControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,inDownScaleKoeff);
        end


        function trajectory=getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            import modgen.common.throwerror;
            ERR_TOL = 1e-4;
            REL_TOL = 1e-4;
            ABS_TOL = 1e-4;
            trajectory=[];
            switchTimeVecLenght=numel(switchSysTimeVec);
            SOptions = odeset('RelTol',REL_TOL,'AbsTol',ABS_TOL);
            properTube=self.controlVectorFunct.getITube();
            self.properEllTube.scale(@(x)1/sqrt(self.downScaleKoeff),'QArray'); 

            for iSwitch=1:switchTimeVecLenght-1                 
                iTube=1;
                iSwitchBack=switchTimeVecLenght-iSwitch;
                if (iSwitchBack>1)
                    iTube=properTube;
                end
                tStart=switchSysTimeVec(iSwitch);
                tFin=switchSysTimeVec(iSwitch+1);
               
                indFin=find(self.properEllTube.timeVec{1}==tFin);
                AtMat=self.probDynamicsList{iSwitchBack}{iTube}.getAtDynamics();
                
                [~,odeResMat] = ode45(@(t,y)ode(t,y,AtMat,self.controlVectorFunct,tStart,tFin),[tStart tFin],x0Vec',SOptions);
             
                q1Vec=self.properEllTube.aMat{1}(:,indFin);
                q1Mat=self.properEllTube.QArray{1}(:,:,indFin);
                
                isOdeResInEll = dot(odeResMat(end,:)'-q1Vec,q1Mat\(odeResMat(end,:)'-q1Vec));
                
                if (isX0inSet)&&(isOdeResInEll > 1 + ERR_TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                if (~isX0inSet)&&(isOdeResInEll < 1 - ERR_TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                x0Vec=odeResMat(end,:);
                trajectory=cat(1,trajectory,odeResMat);
            end
            
            function dyMat=ode(time,yMat,AtMat,controlFuncVec,tStart,tFin)
               dyMat=-AtMat.evaluate(tFin-time+tStart)*yMat+controlFuncVec.evaluate(yMat,time);
            end
            
            
        end
        function indTube=getITube(self)
            indTube=self.controlVectorFunct.getITube();
        end
    end
end