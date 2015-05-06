classdef DiscControlVectorFunct < elltool.control.IControlVectFunction&...
        modgen.common.obj.HandleObjectCloner
    properties (Constant = true)
    FSOLVE_TOL = 1.0e-5;
    end
    
    properties
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
        
        function resMat=evaluate(self,xVec,timeVec,iTime)
            
            resMat=zeros(size(xVec,1),size(timeVec,2));
%             import ; % <- I don't think we need it because the argument is void

            % next step is to find curProbDynObj, curGoodDirSetObj corresponding to that time period                       
   
                curControlTime = timeVec(iTime); 
                probTimeVec=self.probDynamicsList{1}.getTimeVec(); % what is probDynamicList? probTimeVec is the time vector for the system before first switch
                for iSwitch = 1:length(self.probDynamicsList)
                    probTimeVec = self.probDynamicsList{iSwitch}.getTimeVec();
                    if ( ( curControlTime <= probTimeVec(1) ) && ...
                            ( curControlTime >= probTimeVec(end) ) )
                        curProbDynObj = self.probDynamicsList{iSwitch};
                        curGoodDirSetObj = self.goodDirSetList{iSwitch};
                        break;
                    end
                end
     
                % now we got the needed objects corresponding to the time
                % moment we interested in
                
                tFin = max(probTimeVec);  
                tStart = min(probTimeVec);
                
                pVec = curProbDynObj.getBptDynamics.evaluate(timeVec(iTime)); % ellipsoid center
                pMat = curProbDynObj.getBPBTransDynamics.evaluate(timeVec(iTime));   % ellipsoid shape matrix
                    
                ellTubeTimeVec = self.properEllTube.timeVec{:};
                                
                ind = find(ellTubeTimeVec <= timeVec(iTime));
                indTime = size(ind,2);
              
                %find proper ellipsoid which corresponts current time               
                if ellTubeTimeVec(indTime)<timeVec(iTime)
                    
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
              
                resMat = pVec-(pMat*l0Vec)/sqrt(dot(l0Vec,pMat*l0Vec));

            % go to next moment in timeVec
            
        end % of evaluate()
        
        
    end
end