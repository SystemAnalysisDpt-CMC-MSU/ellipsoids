classdef Control
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        koef
        ControlVectorFunct
    end
    methods
        function self=Control(properEllTube,...
                probDynamicsList, goodDirSetList,indTube,k)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.koef=k;
            self.ControlVectorFunct=elltool.control.ControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,k);
        end


        function trajectory=getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            import modgen.common.throwerror;
            TOL=10^(-4);
            trajectory=[];
            switchTimeVecLenght=numel(switchSysTimeVec);
            options = odeset('RelTol',1e-4,'AbsTol',1e-4);
            properTube=self.ControlVectorFunct.getITube();
            self.properEllTube.scale(@(x)1/sqrt(self.koef),'QArray'); 
            iTube=1;
            for iSwitch=1:switchTimeVecLenght-1                 
                iTube=1;
                iSwitchBack=switchTimeVecLenght-iSwitch;
                if (iSwitchBack>1)
                    iTube=properTube;
                end
                t0=switchSysTimeVec(iSwitch);
                t1=switchSysTimeVec(iSwitch+1);
               
                ind=find(self.properEllTube.timeVec{1}==t1);
                AtMat=self.probDynamicsList{iSwitchBack}{iTube}.getAtDynamics();
                
                [T,Y] = ode45(@(t,y)ode(t,y,AtMat,self.ControlVectorFunct,t0,t1),[t0 t1],x0Vec',options);
             
                q1Vec=self.properEllTube.aMat{1}(:,ind);
                q1Mat=self.properEllTube.QArray{1}(:,:,ind);
                
                if (isX0inSet)&&(dot(Y(end,:)'-q1Vec,q1Mat\(Y(end,:)'-q1Vec))>1+TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                if (~isX0inSet)&&(dot(Y(end,:)'-q1Vec,q1Mat\(Y(end,:)'-q1Vec))<1-TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                x0Vec=Y(end,:);
                trajectory=cat(1,trajectory,Y);
            end
            function dy=ode(t,y,AtMat,controlFuncVec,t0,t1)
               dy=zeros(AtMat.getNRows(),1); 
               dy=-AtMat.evaluate(t1-t+t0)*y+controlFuncVec.evaluate(y,t);

            end
            
            
        end
        function iTube=getITube(self)
            iTube=self.ControlVectorFunct.getITube();
        end
    end
end