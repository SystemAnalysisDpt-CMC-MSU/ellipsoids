classdef DiscSingleTubeControl<elltool.control.ASingleTubeControl
    properties (Access = private)
        probDynamicsList
        goodDirSetList
        downScaleKoeff
        isBackward
        switchSysTimeVec
    end
    methods
        function self = DiscSingleTubeControl(properEllTube,...
                probDynamicsList, goodDirSetList,switchSysTimeVec,inDownScaleKoeff)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.switchSysTimeVec = switchSysTimeVec;
            self.downScaleKoeff=inDownScaleKoeff;
            self.controlVectorFunct=elltool.control.DiscControlVectorFunct(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,inDownScaleKoeff);
        end
        %
        function [trajEvalTime, trajectory] = getTrajectory(self,x0Vec)
            import modgen.common.throwerror;
            ERR_TOL = 1e-4;
            trajEvalTime = [];
            trajectory = [];
            switchTimeVecLenght=numel(self.switchSysTimeVec);
            self.properEllTube.scale(@(x)1/sqrt(self.downScaleKoeff),'QArray');
            %
            q0Vec = self.properEllTube.aMat{1}(:,1);
            q0Mat = self.properEllTube.QArray{1}(:,:,1);
            isX0inSet = dot(x0Vec-q0Vec,q0Mat\(x0Vec-q0Vec));
            %
            for iSwitch=1:switchTimeVecLenght-1                 
                iSwitchBack = switchTimeVecLenght - iSwitch;
                %
                tStart = self.switchSysTimeVec(iSwitch);
                tFin = self.switchSysTimeVec(iSwitch+1);
                %
                indFin=find(self.properEllTube.timeVec{1}==tFin);
                AtMat=self.probDynamicsList{iSwitchBack}.getAtDynamics();    
                curProbDynObj=self.probDynamicsList{iSwitchBack};
                %
                CRel = 10000;
                timeVec = tStart:(tFin-tStart)/CRel:tFin;
                %   
                odeResMat = DiscrBackwardDynamics(AtMat,...
                    self.controlVectorFunct,x0Vec,timeVec,curProbDynObj);     
                %
                q1Vec=self.properEllTube.aMat{1}(:,indFin);
                q1Mat=self.properEllTube.QArray{1}(:,:,indFin);
                
                currentScalProd = dot(odeResMat(end,:)'-q1Vec,q1Mat\...
                    (odeResMat(end,:)'-q1Vec));
                
                if (isX0inSet)&&(currentScalProd > 1 + ERR_TOL)
                    throwerror('TestFails', ['the result of test does '...
                        'not correspond with theory, current scalar ' ...
                        'production at the end of system switch ' ...
                        'interval number ', num2str(iSwitchBack), ' is '...
                        num2str(currentScalProd), ', while the original'...
                        ' solvability domain actually contains x(t0)']);
                end
                %
                x0Vec = odeResMat(end,:);
                trajEvalTime = vertcat(trajEvalTime, timeVec);
                trajectory = vertcat(trajectory, odeResMat);
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
                   if(rank(aMat)~= 0)
                   xtArray1(:,iTime) = aMat * (xtArray(:,iTime-1) - bptVec);
                   else
                       xtArray1(:,iTime) =  - bptVec;
                   end;
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
            controlFunc = self.controlVectorFunct.clone();
        end
        
        function properEllTube = getEllTube(self)
            % GETPROPERELLTUBE - returns properEllTube from class
            properEllTube = self.properEllTube.clone();
        end
    end
end