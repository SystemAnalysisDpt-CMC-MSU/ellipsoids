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
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.downScaleKoeff=inDownScaleKoeff;
            self.isBackward = isBackward;
            self.controlVectorFunct=elltool.control.DiscControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,inDownScaleKoeff);
        end


        function trajectory=getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            import modgen.common.throwerror;
            ERR_TOL=10^(-4);
            %REL_TOL = 1e-4;
            %ABS_TOL = 1e-4;
            trajectory=[];
            switchTimeVecLenght=numel(switchSysTimeVec);
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
                AtMat=self.probDynamicsList{iSwitch}{iTube}.getAtDynamics();    
                
                CRel = 5000;
                timeVec = tStart:(tFin-tStart)/CRel:tFin;
           
                if self.isBackward
                    odeResMat = DiscrBackwardDynamics(AtMat,self.controlVectorFunct,x0Vec,timeVec);
                else
                    odeResMat = DiscrForwardDynamics(AtMat,self.controlVectorFunct,x0Vec,timeVec);
                end
             
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
            
            function resMat = DiscrForwardDynamics(AtMat,controlVectorFunct,x0Vec,timeVec)
                sysDim = max([size(x0Vec, 1) size(x0Vec, 2)]);
                nTimePoints = length(timeVec);
                
                xtArray = zeros(sysDim, nTimePoints);
                if (size(x0Vec, 2)>size(x0Vec, 1))
                    xtArray(:, 1) = x0Vec.';
                else
                    xtArray(:, 1) = x0Vec;
                end;
                for iTime = 1:nTimePoints - 1
                   aMat = AtMat.evaluate(timeVec(iTime));
                   %bpVec = controlVectorFunct().evaluate(timeVec(iTime));
                   bpVec = zeros(sysDim,1);
                   xtArray(:, iTime + 1) = ...
                     aMat * xtArray(:, iTime) + bpVec;
                end
                 resMat = xtArray.';                   
            end
             
            
            function resMat = DiscrBackwardDynamics(AtMat,controlVectorFunct,x0Vec,timeVec)
                sysDim = max([size(x0Vec, 1) size(x0Vec, 2)]);
                nTimePoints = length(timeVec);
               
                xtArray = zeros(nTimePoints,sysDim).';
                if (size(x0Vec, 2)>size(x0Vec, 1))
                    xtArray(:,1) = x0Vec.';
                else
                    xtArray(:,1) = x0Vec;
                end;
                for iTime = 2:nTimePoints 
                   aMat = AtMat.evaluate(timeVec(iTime));
                   bpVec = controlVectorFunct.evaluate(xtArray(:,iTime-1),timeVec,iTime);
                   xtArray(:,iTime) = ...
                     aMat \ xtArray(:,iTime-1) - bpVec;
                end
                 resMat = xtArray.';        
             end
        end
        
        function iTube=getITube(self)
            iTube=self.controlVectorFunct.getITube();
            %iTube = 1;
        end
    end
end