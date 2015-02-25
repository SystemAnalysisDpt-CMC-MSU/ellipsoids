classdef ControlVectorFunct < elltool.control.IControlVectFunction
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        iTube
        koef
    end
    methods
        function self=ControlVectorFunct(properEllTube,...
                probDynamicsList, goodDirSetList,iTube,k)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.iTube=iTube;
            self.koef=k;
        end
        function resVec=evaluate(self,xVec,timeVec)
            
            resVec=zeros(size(xVec,1),size(timeVec,2));
            import ; 
            %find curProbDynObj, curGoodDirSetObj corresponding to that time period                       
            
            for i=1:size(timeVec,2)
                probTimeVec=self.probDynamicsList{1}{1}.getTimeVec();
                if ((timeVec(i)<=probTimeVec(end))&&(timeVec(i)>=probTimeVec(1)))
                    curProbDynObj=self.probDynamicsList{1}{1};
                    curGoodDirSetObj=self.goodDirSetList{1}{1};
                    
                else
                    for iSwitch=2:numel(self.probDynamicsList)
                        probTimeVec=self.probDynamicsList{iSwitch}{self.iTube}.getTimeVec();
                        if ((timeVec(i)<=probTimeVec(end))&&(timeVec(i)>=probTimeVec(1)))
                            curProbDynObj=self.probDynamicsList{iSwitch}{self.iTube};
                            curGoodDirSetObj=self.goodDirSetList{iSwitch}{self.iTube};
                            break;
                        end
                    end
                end;
                
                xstTransMat=(curGoodDirSetObj.getXstTransDynamics());
                t1=max(probTimeVec);  
                t0=min(probTimeVec);
                xt1tMat=inv(transpose(xstTransMat.evaluate(t1-t1+t0)))*(transpose(xstTransMat.evaluate(t1-timeVec(i)+t0)));

                bpVec=-curProbDynObj.getBptDynamics.evaluate(t1-timeVec(i)+t0);%ellipsoid center
                bpbMat=curProbDynObj.getBPBTransDynamics.evaluate(t1-timeVec(i)+t0);   %ellipsoid matrice
                pVec=xt1tMat*bpVec;
                pMat=xt1tMat*bpbMat*transpose(xt1tMat);
                    
                ellTubeTimeVec=self.properEllTube.timeVec{:};
                
                ind=find(ellTubeTimeVec <= timeVec(i));
                tInd=size(ind,2);
              
                %find proper ellipsoid which corresponts current time
                if ellTubeTimeVec(tInd)<timeVec(i)
                    
                    nDim=size(self.properEllTube.aMat{:},1);
                    qVec=zeros(nDim,1);
                    for iDim=1:nDim
                        qVec(iDim)=interp1(ellTubeTimeVec,self.properEllTube.aMat{:}(iDim,:),timeVec(i));
                    end;
                    nDimRow=size(self.properEllTube.QArray{:},1);
                    nDimCol=size(self.properEllTube.QArray{:},2);
                    qMat=zeros(nDimRow,nDimCol);
                    for iDim=1:nDimRow                       
                        for jDim=1:nDimCol
                            QArrayTime(1,:)=self.properEllTube.QArray{:}(iDim,jDim,:);
                            qMat(iDim,jDim)=interp1(ellTubeTimeVec,QArrayTime,timeVec(i));
                        end
                    end;
                    
                else
                    if (ellTubeTimeVec(tInd)==timeVec(i))
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
                
                resVec(:,i)=pVec-(pMat*l0Vec)/sqrt(dot(l0Vec,pMat*l0Vec));
                resVec(:,i)=inv(xt1tMat)*resVec(:,i);

            end 
            function l0=findl0(elxCentVec,elXMat,x)
                %from the article
                 I=eye(size(elXMat));
                  f=@(lambda)1/(dot(inv(I+lambda*inv(elXMat))*(x-elxCentVec),...
                      inv(elXMat)*inv(I+lambda*inv(elXMat))*(x-elxCentVec)))-1;
                  lambda=fsolve(f,1.0e-5);
                  s0=inv(I+lambda*inv(elXMat))*(x-elxCentVec)+elxCentVec;
                  l0=(x-s0)/norm(x-s0);

            end
            
        end
        function iTube=getITube(self)
            iTube=self.iTube;
        end
    end
end