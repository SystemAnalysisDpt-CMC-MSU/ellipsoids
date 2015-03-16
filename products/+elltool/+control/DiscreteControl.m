classdef DiscreteControl
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        controlVectorFunct
        isBackward
    end
    
    methods
        function self=DiscreteControl(properEllTube,...
                probDynamicsList, goodDirSetList,indTube,inDownScaleKoeff,isBackward)
            self.properEllTube = properEllTube;
            self.probDynamicsList = probDynamicsList;
            self.goodDirSetList = goodDirSetList;
            self.downScaleKoeff = inDownScaleKoeff;
            self.controlVectorFunct = elltool.control.DiscreteControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,inDownScaleKoeff,isBackward);
            self.isBackward = isBackward;
        end


        function trajectory = getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            import modgen.common.throwerror;
            ERR_TOL = 1e-4;
            trajectory = [];
            switchTimeVecLenght=numel(switchSysTimeVec);
            properTube=self.DiscretecontrolVectorFunct.getITube();
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
                x0DefVec = problemDef.getx0Vec();
                sysDim = size(problemDef.getAMatDef(), 1);
                nTimePoints = length(self.timeVec);
            
                xtArray = zeros(sysDim, nTimePoints);
                xtArray(:, 1) = x0DefVec;
                for iTime = 1:nTimePoints - 1
                   aMat = AtMat.evaluate(self.timeVec(iTime));
                   bpVec = controlFuncVec.evaluate(yMat,time);
                   xtArray(:, iTime + 1) = ...
                    aMat * xtArray(:, iTime) + bpVec;
                end
                
             
                q1Vec=self.properEllTube.aMat{1}(:,indFin);
                q1Mat=self.properEllTube.QArray{1}(:,:,indFin);
                
                isOdeResInEll = dot(xtArray(end,:)'-q1Vec,q1Mat\(xtArray(end,:)'-q1Vec));
                
                if (isX0inSet)&&(isOdeResInEll > 1 + ERR_TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                if (~isX0inSet)&&(isOdeResInEll < 1 - ERR_TOL)
                    throwerror('TestFails',...
                        'the result of test does not correspond with theory');
                end
                x0Vec=xtArray(end,:);
                trajectory=cat(1,trajectory,xtArray);
            end
            
           
        end
        function indTube=getITube(self)
            indTube=self.controlVectorFunct.getITube();
        end
    end
end