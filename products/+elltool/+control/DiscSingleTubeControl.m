classdef DiscSingleTubeControl
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        controlVectorFunct
        isBackward
    end
    methods
        function self=DiscSingleTubeControl(properEllTube,...
                probDynamicsList, goodDirSetList,inDownScaleKoeff)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.downScaleKoeff=inDownScaleKoeff;
            self.controlVectorFunct=elltool.control.DiscControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,inDownScaleKoeff);
        end


        function trajectory=getTrajectory(self,x0Vec,switchSysTimeVec,isX0inSet)
            import modgen.common.throwerror;
            ERR_TOL=10^(-4);
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
                AtMat=self.probDynamicsList{iSwitch}.getAtDynamics();    
                curProbDynObj=self.probDynamicsList{iSwitch};
                
                CRel = 10000;
                timeVec = fliplr(tStart:(tFin-tStart)/CRel:tFin);
                    
                odeResMat = DiscrBackwardDynamics(AtMat,self.controlVectorFunct,x0Vec,timeVec,curProbDynObj);     
             
                q1Vec=self.properEllTube.aMat{1}(:,indFin);
                q1Mat=self.properEllTube.QArray{1}(:,:,indFin);
                
                currentScalProd = dot(odeResMat(end,:)'-q1Vec,q1Mat\(odeResMat(end,:)'-q1Vec));
                
                if (isX0inSet)&&(currentScalProd > 1 + ERR_TOL)
                    throwerror('TestFails', ['the result of test does not',...
                        'corresponds with theory, current scalar production is ',...
                        num2str(currentScalProd), ' while isX0inSet is ', num2str(isX0inSet), ',', num2str(iSwitchBack) ]);
                end
                if (~isX0inSet)&&(currentScalProd < 1 - ERR_TOL)
                    throwerror('TestFails', ['the result of test does not',...
                        'corresponds with theory, current scalar production is ',...
                        num2str(currentScalProd), ' while isX0inSet is ', num2str(isX0inSet), ',', num2str(iSwitchBack) ]);
                end
                x0Vec=odeResMat(end,:);
                trajectory=cat(1,trajectory,odeResMat);
            end
             
            
            function resMat = DiscrBackwardDynamics(AtMat,controlVectorFunct,x0Vec,timeVec,curProbDynObj)
                sysDim = max([size(x0Vec, 1) size(x0Vec, 2)]);
                nTimePoints = length(timeVec);
               
                xtArray = zeros(nTimePoints,sysDim).';
                xtArray1 = zeros(nTimePoints,sysDim).';
                if (size(x0Vec, 2)>size(x0Vec, 1))
                    xtArray(:,1) = x0Vec.';
                else
                    xtArray(:,1) = x0Vec;
                end;
                xtArray1(:,1) = xtArray(:,1);
                for iTime = 2:nTimePoints 
                   aMat = AtMat.evaluate(timeVec(iTime));
                   bptVec = curProbDynObj.getBptDynamics.evaluate(timeVec(iTime)); 
                   xtArray1(:,iTime) = aMat * (xtArray1(:,iTime-1) - bptVec);
                   bpVec = controlVectorFunct.evaluate(xtArray1(:,iTime),timeVec,iTime);
                   if(rank(aMat)~= 0)
                   xtArray(:,iTime) = ...
                     aMat * (xtArray(:,iTime-1) - bpVec);
                   else
                      xtArray(:,iTime) =  - bpVec;
                   end;
                end
                 resMat = xtArray.';        
             end
        end
        
        function controlFunc = getControlFunction(self)
            % GETCONTROLFUNCTION - returns controlVectorFunct from class
            controlFunc = self.controlVectorFunct;
        end
        
        function properEllTube = getProperEllTube(self)
            % GETPROPERELLTUBE - returns properEllTube from class
            properEllTube = self.properEllTube;
        end
    end
end