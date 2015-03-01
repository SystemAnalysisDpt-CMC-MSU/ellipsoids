classdef ControlVectorFunct < elltool.control.IControlVectFunction
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        iTube
        koef
    end
    methods
        function self=ControlVectorFunct(properEllTube,... % class constructor
                probDynamicsList, goodDirSetList,iTube,inKoef)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.iTube=iTube;
            self.koef=inKoef;
        end
        function resVec=evaluate(self,xVec,timeVec)
            
            resVec=zeros(size(xVec,1),size(timeVec,2));
%             import ; % <- I don't think we need it because the argument is void

            % next step is to find curProbDynObj, curGoodDirSetObj corresponding to that time period                       
            
            for iTime=1:size(timeVec,2) % for every moment of time in timeVec
                probTimeVec=self.probDynamicsList{1}{1}.getTimeVec(); % what is probDynamicList? probTimeVec is the time vector for the system before first switch
                if ((timeVec(iTime)<=probTimeVec(end))&&(timeVec(iTime)>=probTimeVec(1))) % if the tube is constructed for the selected moment of time
                    curProbDynObj=self.probDynamicsList{1}{1};
                    curGoodDirSetObj=self.goodDirSetList{1}{1};
                    
                else
                    for iSwitch=2:numel(self.probDynamicsList)
                        probTimeVec=self.probDynamicsList{iSwitch}{self.iTube}.getTimeVec();
                        if ((timeVec(iTime)<=probTimeVec(end))&&(timeVec(iTime)>=probTimeVec(1)))
                            curProbDynObj=self.probDynamicsList{iSwitch}{self.iTube};
                            curGoodDirSetObj=self.goodDirSetList{iSwitch}{self.iTube};
                            break;
                        end
                    end
                end;
                
                % now we got the needed objects corresponding to the time
                % moment we interested in
                
                xstTransMat = curGoodDirSetObj.getXstTransDynamics();
                tFin = max(probTimeVec);  
                tStart = min(probTimeVec);
                xt1tMat = inv(transpose(xstTransMat.evaluate(tFin-tFin+tStart)))*(transpose(xstTransMat.evaluate(tFin-timeVec(iTime)+tStart)));
                %tFin-tFin there is some mistake... of course she is a woman  
                % There is an opinion that we are to have 
                % X(t1,t) = inv( X(s,t1) ) * X(s,t) 

                bpVec=-curProbDynObj.getBptDynamics.evaluate(tFin-timeVec(iTime)+tStart); % ellipsoid center
                bpbMat=curProbDynObj.getBPBTransDynamics.evaluate(tFin-timeVec(iTime)+tStart);   % ellipsoid shape matrix
                pVec=xt1tMat*bpVec;
                pMat=xt1tMat*bpbMat*transpose(xt1tMat);
                    
                ellTubeTimeVec=self.properEllTube.timeVec{:};
                
                ind=find(ellTubeTimeVec <= timeVec(iTime));
                tInd=size(ind,2);
              
                %find proper ellipsoid which corresponts current time
                if ellTubeTimeVec(tInd)<timeVec(iTime)
                    
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
                    if (ellTubeTimeVec(tInd)==timeVec(iTime))
                        qVec=self.properEllTube.aMat{:}(:,tInd);
                        qMat=self.properEllTube.QArray{:}(:,:,tInd);                        
                    end
                end                
                qVec=xt1tMat*qVec;
                qMat=xt1tMat*qMat*transpose(xt1tMat); 
                xVec=xt1tMat*xVec;
                ml1Vec=sqrt(dot(xVec-qVec,inv(qMat)*(xVec-qVec)));
                l0Vec=inv(qMat)*(xVec-qVec)/ml1Vec;
                if (dot(-l0Vec,xVec)-dot(-l0Vec,qVec)>dot(l0Vec,xVec)-dot(l0Vec,qVec))
                    l0Vec=-l0Vec;
                end
                l0Vec=l0Vec/norm(l0Vec);
                %l0Vec=findl0(qVec,qMat,xVec)
                
                resVec(:,iTime)=pVec-(pMat*l0Vec)/sqrt(dot(l0Vec,pMat*l0Vec));
                resVec(:,iTime)=inv(xt1tMat)*resVec(:,iTime);

            end 
            
            function l0Vec=findl0(elxCentVec,elXMat,xVec)
                %from the article
                 IMat=eye(size(elXMat));
                  fCalc=@(lambda)1/(dot(inv(IMat+lambda*inv(elXMat))*(xVec-elxCentVec),...
                      inv(elXMat)*inv(IMat+lambda*inv(elXMat))*(xVec-elxCentVec)))-1;
                  lamMat=fsolve(fCalc,1.0e-5);
                  s0Vec=inv(IMat+lamMat*inv(elXMat))*(xVec-elxCentVec)+elxCentVec;
                  l0Vec=(xVec-s0Vec)/norm(xVec-s0Vec);

            end
            
        end % of evaluate()
        
        function iTube=getITube(self)
            iTube=self.iTube;
        end
        
    end
end