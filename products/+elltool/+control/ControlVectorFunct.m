classdef ControlVectorFunct < elltool.control.IControlVectFunction&...
        modgen.common.obj.HandleObjectCloner
    properties (Constant = true)
        FSOLVE_TOL = 1e-5;
    end
    
    properties
        properEllTube
        probDynamicsList
        goodDirSetList
        downScaleKoeff
    end
    
    methods
        function self=ControlVectorFunct(properEllTube,... % class constructor
                probDynamicsList, goodDirSetList,inDownScaleKoeff)
            self.properEllTube=properEllTube;
            self.probDynamicsList=probDynamicsList;
            self.goodDirSetList=goodDirSetList;
            self.downScaleKoeff=inDownScaleKoeff;
        end
        
        function resMat = evaluate(self,xVec,timeVec)
            
            resMat = zeros(size(xVec,1),size(timeVec,2));                      
            
            tEnd = self.probDynamicsList{1}.getTimeVec();                
            % probDynamicsList{indSwitch}{indTube} returns dynamics for
            %       indSwitch time period and indTube tube
            tEnd = tEnd(end);
            
            for iTime = 1:size(timeVec,2)
                curControlTime = timeVec(iTime);
                
                for iSwitch = length(self.probDynamicsList):-1:1
                    probTimeVec = self.probDynamicsList{iSwitch}.getTimeVec();
                    if ( ( curControlTime < probTimeVec(end) ) && ...
                            ( curControlTime >= probTimeVec(1) ) || ( curControlTime ==  tEnd) )
                        curProbDynObj = self.probDynamicsList{iSwitch};
                        curGoodDirSetObj = self.goodDirSetList{iSwitch};
                        t1 = max(probTimeVec);
                        t0 = min(probTimeVec);
                        break;
                    end
                end
                
                xstTransMat = curGoodDirSetObj.getXstTransDynamics();
                % X(t,t_0) = ( xstTransMat.evaluate(t)\xstTransMat.evaluate(t_0) )'
                xt1tMat = transpose(xstTransMat.evaluate(t1)\xstTransMat.evaluate(curControlTime));

                bpVec = -curProbDynObj.getBptDynamics.evaluate(t1-curControlTime+t0); % ellipsoid center           
                bpbMat = curProbDynObj.getBPBTransDynamics.evaluate(t1-curControlTime+t0);   % ellipsoid shape matrix

                pVec = xt1tMat*bpVec;
                pMat = xt1tMat*bpbMat*transpose(xt1tMat);
                    
                ellTubeTimeVec = self.properEllTube.timeVec{1};
                
                indVec = find(ellTubeTimeVec <= timeVec(iTime));
                indTime = length(indVec);
              
                if ellTubeTimeVec(indTime) < timeVec(iTime)
                    
                    qVec = interp1(ellTubeTimeVec',transpose(self.properEllTube.aMat{1}),curControlTime);
                    qVec = qVec';
                    
                    nDimRow=size(self.properEllTube.QArray{1},1);
                    nDimCol=size(self.properEllTube.QArray{1},2);
                    qMat=zeros(nDimRow,nDimCol);
                    for iDim=1:nDimRow                       
                        for jDim=1:nDimCol
                            QArrayTime(1,:)=self.properEllTube.QArray{1}(iDim,jDim,:);
                            qMat(iDim,jDim)=interp1(ellTubeTimeVec,QArrayTime,curControlTime);
                        end
                    end;
                    
                else
                    if (ellTubeTimeVec(indTime) == timeVec(iTime)) 
                        qVec = self.properEllTube.aMat{1}(:,indTime);
                        qMat = self.properEllTube.QArray{1}(:,:,indTime);                        
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
                
                resMat(:,iTime) = pVec - (pMat*l0Vec) / sqrt(l0Vec'*pMat*l0Vec);
                resMat(:,iTime) = xt1tMat \ resMat(:,iTime);
                
            end 
            
        end
        
    end
end