classdef ControlVectorFunct < elltool.control.IControlVectFunction
    properties (Constant = true)
        FSOLVE_TOL = 1e-5;
    end
    
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        indTube
        downScaleKoeff
    end
    
    methods
        function self=ControlVectorFunct(properEllTube,... % class constructor
                probDynamicsList, goodDirSetList,indTube,inDownScaleKoeff)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.indTube=indTube;
            self.downScaleKoeff=inDownScaleKoeff;
        end
        
        function resMat=evaluate(self,xVec,timeVec)
            
            resMat=zeros(size(xVec,1),size(timeVec,2));

            % next step is to find curProbDynObj, curGoodDirSetObj corresponding to that time period                       
            
            for iTime=1:size(timeVec,2) % for every moment of time in timeVec
                probTimeVec=self.probDynamicsList{1}{1}.getTimeVec(); % what is probDynamicList? probTimeVec is the time vector for the system before first switch
                if ((timeVec(iTime)<=probTimeVec(end))&&(timeVec(iTime)>=probTimeVec(1))) % if the tube is constructed for the selected moment of time
                    curProbDynObj=self.probDynamicsList{1}{1};
                    curGoodDirSetObj=self.goodDirSetList{1}{1};
                    
                else
                    for iSwitch=2:numel(self.probDynamicsList)
                        probTimeVec=self.probDynamicsList{iSwitch}{self.indTube}.getTimeVec();
                        if ((timeVec(iTime)<=probTimeVec(end))&&(timeVec(iTime)>=probTimeVec(1)))
                            curProbDynObj=self.probDynamicsList{iSwitch}{self.indTube};
                            curGoodDirSetObj=self.goodDirSetList{iSwitch}{self.indTube};
                            break;
                        end
                    end
                end;
                
                % now we got the needed objects corresponding to the time
                % moment we interested in
                
                xstTransMat = curGoodDirSetObj.getXstTransDynamics();
                tFin = max(probTimeVec);  
                tStart = min(probTimeVec);
                xt1tMat = (transpose(xstTransMat.evaluate(tFin-tFin+tStart)))\(transpose(xstTransMat.evaluate(tFin-timeVec(iTime)+tStart)));
                %tFin-tFin seems to be okay. Better look in other place
                % There is an opinion that we are to have 
                % X(t1,t) = inv( X(s,t1) ) * X(s,t) 

                bpVec = -curProbDynObj.getBptDynamics.evaluate(tFin-timeVec(iTime)+tStart); % ellipsoid center
                bpbMat = curProbDynObj.getBPBTransDynamics.evaluate(tFin-timeVec(iTime)+tStart);   % ellipsoid shape matrix
                pVec = xt1tMat*bpVec;
                pMat = xt1tMat*bpbMat*transpose(xt1tMat);
                    
                ellTubeTimeVec = self.properEllTube.timeVec{:};
                
                ind = find(ellTubeTimeVec <= timeVec(iTime));
                indTime = size(ind,2);
              
                %find proper ellipsoid which corresponds to current time
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
                qVec=xt1tMat*qVec;
                qMat=xt1tMat*qMat*transpose(xt1tMat); 
                xVec=xt1tMat*xVec;
                ml1Vec=sqrt(dot(xVec-qVec,qMat\(xVec-qVec)));
                l0Vec=(qMat\(xVec-qVec))/ml1Vec;
                if (dot(-l0Vec,xVec)-dot(-l0Vec,qVec)>dot(l0Vec,xVec)-dot(l0Vec,qVec))
                    l0Vec=-l0Vec;
                end
                l0Vec=l0Vec/norm(l0Vec);
                
                resMat(:,iTime)=pVec-(pMat*l0Vec)/sqrt(dot(l0Vec,pMat*l0Vec));
                resMat(:,iTime)=xt1tMat\resMat(:,iTime);

            end 
            
        end % of evaluate()
        
        function indTube=getITube(self)
            indTube=self.iTube;
        end
        
    end
end