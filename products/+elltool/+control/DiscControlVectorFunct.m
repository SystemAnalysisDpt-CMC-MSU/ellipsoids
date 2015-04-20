classdef DiscControlVectorFunct < elltool.control.IControlVectFunction
    properties (Constant = true)
    FSOLVE_TOL = 1.0e-5;
    end
    
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        indTube
        downScaleKoeff
    end
   
    
    methods
        function self = DiscControlVectorFunct(properEllTube,... % class constructor
                probDynamicsList, goodDirSetList,indTube,inDownScaleKoeff)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.indTube=indTube;
            self.downScaleKoeff=inDownScaleKoeff;
        end
        
        function resMat=evaluate(self,xVec,timeVec,iTime)
            
            resMat=zeros(size(xVec,1),size(timeVec,2));
%             import ; % <- I don't think we need it because the argument is void

            % next step is to find curProbDynObj, curGoodDirSetObj corresponding to that time period                       
   
            
                probTimeVec=self.probDynamicsList{1}{1}.getTimeVec(); % what is probDynamicList? probTimeVec is the time vector for the system before first switch
                if ((timeVec(iTime)<=probTimeVec(1))&&(timeVec(iTime)>=probTimeVec(end))) % if the tube is constructed for the selected moment of time
                    curProbDynObj=self.probDynamicsList{1}{1};
                    curGoodDirSetObj=self.goodDirSetList{1}{1};
                    
                else
                    for iSwitch=2:numel(self.probDynamicsList)
                        probTimeVec=self.probDynamicsList{iSwitch}{self.indTube}.getTimeVec();
                        if ((timeVec(iTime)<=probTimeVec(1))&&(timeVec(iTime)>=probTimeVec(end)))
                            curProbDynObj=self.probDynamicsList{iSwitch}{self.indTube};
                            curGoodDirSetObj=self.goodDirSetList{iSwitch}{self.indTube};
                            break;
                        end
                    end
                end;
     
                % now we got the needed objects corresponding to the time
                % moment we interested in
                
                tFin = max(probTimeVec);  
                tStart = min(probTimeVec);
                
                pVec = curProbDynObj.getBptDynamics.evaluate(tFin-timeVec(iTime-1)); % ellipsoid center
                pMat = curProbDynObj.getBPBTransDynamics.evaluate(tFin-timeVec(iTime-1));   % ellipsoid shape matrix
                    
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
                    nDimRow=size(self.properEllTube.QArray{:},1);
                    nDimCol=size(self.properEllTube.QArray{:},2);
                    qMat=zeros(nDimRow,nDimCol);
                    for iDim=1:nDimRow                       
                        for jDim=1:nDimCol
                            QArrayTime(1,:)=self.properEllTube.QArray{:}(iDim,jDim,:);
                            qMat(iDim,jDim)=interp1(ellTubeTimeVec,QArrayTime,timeVec(iTime));
                        end
                    end;
                   
                else
                    if (ellTubeTimeVec(indTime)==timeVec(iTime))
                        qVec=self.properEllTube.aMat{:}(:,indTime);
                        qMat=self.properEllTube.QArray{:}(:,:,indTime);                        
                    end
                end                
                l0Vec=((qMat)\(xVec-qVec));
                if (dot((xVec-qVec),l0Vec) <= 1)
                    resMat = pVec;
                else
               
                resMat = pVec-(pMat*l0Vec)/sqrt(dot(l0Vec,pMat*l0Vec));
                end;
                if (dot(bpVec-resMat,bpbMat\(bpVec-resMat)) > 1.05)
                    disp('error');
                    disp(dot(bpVec-resMat,bpbMat\(bpVec-resMat)));
                end;

            % go to next moment in timeVec
            
        end % of evaluate()
        
        function indTube=getITube(self)
            indTube=self.indTube;
        end
        
    end
end