classdef Control
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        koef
        controlVectorFunct
    end
    methods
        function self=Control(properEllTube,...
                probDynamicsList, goodDirSetList,indTube,inKoef)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.koef=inKoef;
            self.controlVectorFunct=elltool.control.ControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,inKoef);
        end


        function trajectory=getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            import modgen.common.throwerror;
            TOL=10^(-4);
            trajectory=[];
            switchTimeVecLenght=numel(switchSysTimeVec);
            options = odeset('RelTol',1e-4,'AbsTol',1e-4);
            properTube=self.controlVectorFunct.getITube();
            self.properEllTube.scale(@(x)1/sqrt(self.koef),'QArray'); 
            %iTube=1;
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
                
                [timeVec,odeResMat] = ode45(@(t,y)ode(t,y,AtMat,self.controlVectorFunct,tStart,tFin),[tStart tFin],x0Vec',options);
             
                q1Vec=self.properEllTube.aMat{1}(:,indFin);
                q1Mat=self.properEllTube.QArray{1}(:,:,indFin);
                
                if (isX0inSet)&&(dot(odeResMat(end,:)'-q1Vec,q1Mat\(odeResMat(end,:)'-q1Vec))>1+TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                if (~isX0inSet)&&(dot(odeResMat(end,:)'-q1Vec,q1Mat\(odeResMat(end,:)'-q1Vec))<1-TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                x0Vec=odeResMat(end,:);
                trajectory=cat(1,trajectory,odeResMat);
            end
            function dyMat=ode(time,yMat,AtMat,controlFuncVec,tStart,tFin)
               dyMat=zeros(AtMat.getNRows(),1); 
               dyMat=-AtMat.evaluate(tFin-time+tStart)*yMat+controlFuncVec.evaluate(yMat,time);

            end
            
            
        end
        function iTube=getITube(self)
            iTube=self.controlVectorFunct.getITube();
        end
    end
end