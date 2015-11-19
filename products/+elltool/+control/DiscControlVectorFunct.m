classdef DiscControlVectorFunct < elltool.control.IControlVectFunction&...
        modgen.common.obj.HandleObjectCloner
    properties (Constant = true)
        FSOLVE_TOL = 1.0e-5;
    end
    
    properties (Access = private)
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
    end
    
    
    methods
        function self = DiscControlVectorFunct(properEllTube,... % class constructor
                probDynamicsList, goodDirSetList,inDownScaleKoeff)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.downScaleKoeff=inDownScaleKoeff;
        end
        
        function resMat=evaluate(self,xVec,timeVec,iTime,A)
            resMat = zeros(size(xVec,1),size(timeVec,2));
            %             import ; % <- I don't think we need it because the argument is void
            
            % next step is to find curProbDynObj, curGoodDirSetObj corresponding to that time period
            %
             tEnd = self.probDynamicsList{1}.getTimeVec(); 
              tEnd = tEnd(end);
            curControlTime = timeVec(iTime-1);
                %
                for iSwitch = length(self.probDynamicsList):-1:1
                    probTimeVec = ...
                        self.probDynamicsList{iSwitch}.getTimeVec();
                    if ( ( curControlTime < probTimeVec(1) ) && ...
                            ( curControlTime >= probTimeVec(end) ) || ...
                            ( curControlTime ==  tEnd) )
                        curProbDynObj = self.probDynamicsList{iSwitch};
                        curGoodDirSetObj = self.goodDirSetList{iSwitch};
                        t1 = max(probTimeVec);
                        t0 = min(probTimeVec);
                        break;
                    end
                end
            xstTransMat = curGoodDirSetObj.getXstTransDynamics();
            xt1tMat = transpose(xstTransMat.evaluate(t1)\...
                    xstTransMat.evaluate(curControlTime));
                %
           evalTime = t1-curControlTime+t0;
                %
           bpVec = -curProbDynObj.getBptDynamics.evaluate(evalTime);           
           bpbMat = ...
              curProbDynObj.getBPBTransDynamics.evaluate(evalTime);
                %
           pVec = A*bpVec;
           pMat = A*bpbMat*transpose(A);
            
            ellTubeTimeVec = self.properEllTube.timeVec{:};
            indVec = find(ellTubeTimeVec <= timeVec(iTime));
            indTime = length(indVec);
            
            %find proper ellipsoid which corresponts current time
            if ellTubeTimeVec(indTime) < timeVec(iTime)
                
                nDim=size(self.properEllTube.aMat{:},1);
                qVec=zeros(nDim,1);
                for iDim=1:nDim
                    qVec(iDim)=interp1(ellTubeTimeVec,self.properEllTube.aMat{:}(iDim,:),timeVec(iTime));
                end;
                nDimRow=size(self.properEllTube.QArray{1},1);
                nDimCol=size(self.properEllTube.QArray{1},2);
                qMat=zeros(nDimRow,nDimCol);
                for iDim=1:nDimRow
                    for jDim=1:nDimCol
                        QArrayTime(1,:)=self.properEllTube.QArray{:}(iDim,jDim,:);
                        qMat(iDim,jDim)=interp1(ellTubeTimeVec,QArrayTime,timeVec(iTime));
                    end
                end;
                
            else
                if (ellTubeTimeVec(indTime)==timeVec(iTime))
                    qVec=self.properEllTube.aMat{1}(:,indTime);
                    qMat=self.properEllTube.QArray{1}(:,:,indTime);
                end
            end
            l0Vec=((qMat)\(xVec-qVec));
            if (dot((xVec-qVec),l0Vec) <= 1)
                resMat = pVec;
            else
                
                resMat = pVec-(pMat*l0Vec)/sqrt((l0Vec.')*pMat*l0Vec);
            end;
            
            % go to next moment in timeVec
            
        end % of evaluate()
        
        
    end
end