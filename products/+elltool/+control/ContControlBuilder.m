classdef ContControlBuilder

    properties (Access = private)
        intEllTube
        probDynamicsList
        goodDirSetList
    end
    
    methods        
        function self = ContControlBuilder(reachContObj)
            % CONTCONTROLBUILDER is a wrapper for building control
            % synthesis for continuous-time case
            %
            % Input:
            %   regular:
            %      reachContObj: an elltool.reach.ReachContinuous object
            %           containing required properties for control
            %           synthesis construction.
            %
            %      Note:  reachContObj is to be in backward time
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $ 
            % $Date: 2015-30-10 $
            % 
            import modgen.common.throwerror;
            ellTubeRel = reachContObj.getEllTubeRel();
            self.intEllTube = ellTubeRel.getTuplesFilteredBy('approxType', ...
                gras.ellapx.enums.EApproxType.Internal);
            self.probDynamicsList = reachContObj.getIntProbDynamicsList();
            self.goodDirSetList = reachContObj.getGoodDirSetList();
            isBackward = reachContObj.isbackward();
            if (~isBackward)
                throwerror('wrongInput',...
                    'System is in the forward time while should be backward system');                
            end
        end
        
        function controlFuncObj = getControlObj(self,x0Vec)
            % GETCONTROLOBJ returns an eltool.control.ContSingleTubeControl
            % object
            %
            % Input:
            %   regular:
            %         x0Vec: double[n,1] where n is a dimentionality of
            %             phase space - position from which the syntesis is 
            %             to be constructed
            % 
            % Output:
            %     regular:
            %         controlFuncObj: an elltool.control.Control object
            %             providing computing control synthesis and
            %             getting the corresponding trajectory
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $ 
            % $Date: 2015-30-10 $
            %
            import modgen.common.throwerror;
            nTuples = self.intEllTube.getNTuples;
            ELL_INT_TOL = 10^(-5);
            
            properIndTube = 1;
            isX0InSet = false;
            
            if (~all(size(x0Vec) == size(self.intEllTube.aMat{1}(:,1))))
                throwerror('wrongInput',...
                    'the dimension of x0 does not correspond the dimension of solvability domain');
            end
            
            for iTube=1:nTuples
                qVec = self.intEllTube.aMat{iTube}(:,1);  
                qMat = self.intEllTube.QArray{iTube}(:,:,1); 
                if ( dot(x0Vec-qVec,qMat\(x0Vec-qVec)) <= 1 + ELL_INT_TOL)                    
                    isX0InSet = true;                    
                    properIndTube = iTube;
                    break;
                end
            end
            
            goodDirOrderedVec = mapGoodDirInd(self.goodDirSetList{1}{1},self.intEllTube);
            indTube = goodDirOrderedVec(properIndTube);
            properEllTube = self.intEllTube.getTuples(properIndTube); 
            
            qVec = properEllTube.aMat{1}(:,1);
            qMat = properEllTube.QArray{1}(:,:,1);
            if (isX0InSet)  
                indWithoutX=findEllWithoutX(qVec, qMat, x0Vec);
            else
                indWithoutX=1;
            end
            properEllTube.scale(@(x)sqrt(indWithoutX),'QArray'); 
            % scale multiplies QArray*(k^2)
            
            properProbDynList = getProperProbDynList(indTube);
            properGoodDirSetList = getProperGoodDirSetList(indTube);
            
            controlFuncObj = elltool.control.ContSingleTubeControl(properEllTube,...
                properProbDynList, properGoodDirSetList,indWithoutX);  
            
            
            function properProbDynList = getProperProbDynList(indTube)
                properProbDynList = cellfun(@(x)(x{min(indTube,numel(x))}),...
                        self.probDynamicsList,'UniformOutput',false);    
            end
            
            function properGoodDirSetList = getProperGoodDirSetList(indTube)
                properGoodDirSetList = cellfun(@(x)(x{min(indTube,numel(x))}),...
                        self.goodDirSetList,'UniformOutput',false);
            end
            
            function iWithoutX = findEllWithoutX(qVec, qMat, x0Vec)
                iWithoutX = 1;
                scalProd = dot(x0Vec-qVec,qMat\(x0Vec-qVec));
                if (scalProd > 0 && scalProd <= 1)
                    iWithoutX = scalProd;
                end                
            end            
   
            function goodDirOrderedVec = mapGoodDirInd(goodDirSetObj,ellTube)
                CMP_TOL=1e-10;
                nTuples = ellTube.getNTuples;
                goodDirOrderedVec = zeros(1,nTuples);
                lsGoodDirMat = goodDirSetObj.getlsGoodDirMat();
                for iGoodDir = 1:size(lsGoodDirMat, 2)
                    lsGoodDirMat(:, iGoodDir) = ...
                        lsGoodDirMat(:, iGoodDir) / ...
                        norm(lsGoodDirMat(:, iGoodDir));
                end
                lsGoodDirCMat = ellTube.lsGoodDirVec;
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