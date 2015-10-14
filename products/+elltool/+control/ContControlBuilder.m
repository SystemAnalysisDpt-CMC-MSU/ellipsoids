classdef ContControlBuilder
    properties (Access = private)
        intEllTube
        probDynamicsList
        goodDirSetList
    end
    methods        
        function self=ContControlBuilder(reachContObj)
            import modgen.common.throwerror;
            ellTubeRel=reachContObj.getEllTubeRel();
            self.intEllTube=ellTubeRel.getTuplesFilteredBy('approxType', ...
                gras.ellapx.enums.EApproxType.Internal);
            self.probDynamicsList=reachContObj.getIntProbDynamicsList();
            self.goodDirSetList=reachContObj.getGoodDirSetList();
            isBackward=reachContObj.isbackward();
            if (~isBackward)
                throwerror('wrongInput',...
                    'System is in the forward time while should be backward system');                
            end
        end
        
        function controlFuncObj=getControl(self,x0)
            import modgen.common.throwerror;
            nTuples = self.intEllTube.getNTuples;
            TOL=10^(-5);
            %Tuple selection
            properIndTube=1;
            isx0inset=false;
            if (~all(size(x0)==size(self.intEllTube.aMat{1}(:,1))))
                throwerror('wrongInput',...
                    'the dimension of x0 does not correspond the dimension of solvability domain');
            end
            for iTube=1:nTuples
                %check if x is in E(q,Q), x: <x-q,Q^(-1)(x-q)><=1
                %if (dot(x-qVec,inv(qMat)*(x-qVec))<=1)
                
                qVec=self.intEllTube.aMat{iTube}(:,1);  
                qMat=self.intEllTube.QArray{iTube}(:,:,1); 
                if (dot(x0-qVec,qMat\(x0-qVec))<=1+TOL)                    
                    isx0inset=true;                    
                    properIndTube=iTube;
                end
            end
            goodDirOrderedVec=mapGoodDirInd(self.goodDirSetList{1}{1},self.intEllTube);
            indTube=goodDirOrderedVec(properIndTube);
            properEllTube=self.intEllTube.getTuples(properIndTube); 
            qVec=properEllTube.aMat{:}(:,1);  
            qMat=properEllTube.QArray{:}(:,:,1);  
            if (isx0inset)  
                k=findEllWithoutX(qVec, qMat, x0);
            else
                k=1;
            end
            properEllTube.scale(@(x)sqrt(k),'QArray'); 
            % scale multiplies k^2 
 
            controlFuncObj=elltool.control.Control(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,k);  
            function k=findEllWithoutX(qVec, qMat, x0)
                k=1;
                if (dot(x0-qVec,qMat\(x0-qVec))<=1)
                    k=dot(x0-qVec,qMat\(x0-qVec));                    
                end                
            end            
   
            function goodDirOrderedVec=mapGoodDirInd(goodDirSetObj,ellTube)
                CMP_TOL=1e-10;
                nTuples = ellTube.getNTuples;
                goodDirOrderedVec=zeros(1,nTuples);
                lsGoodDirMat = goodDirSetObj.getlsGoodDirMat();
                for iGoodDir = 1:size(lsGoodDirMat, 2)
                    lsGoodDirMat(:, iGoodDir) = ...
                        lsGoodDirMat(:, iGoodDir) / ...
                        norm(lsGoodDirMat(:, iGoodDir));
                end
                lsGoodDirCMat = ellTube.lsGoodDirVec();
                for iTuple = 1 : nTuples
                    %
                    % good directions' indexes mapping
                    %
                    curGoodDirVec = lsGoodDirCMat{iTuple};
                    curGoodDirVec = curGoodDirVec / norm(curGoodDirVec);
                    for iGoodDir = 1:size(lsGoodDirMat, 2)
                        isFound = norm(curGoodDirVec - ...
                            lsGoodDirMat(:, iGoodDir)) <= CMP_TOL;
                        if isFound
                            break;
                        end
                    end
                    mlunitext.assert_equals(true, isFound,...
                        'Vector mapping - good dir vector not found');
                    goodDirOrderedVec(iTuple)=iGoodDir;
                end
            end
        end
    end    
end