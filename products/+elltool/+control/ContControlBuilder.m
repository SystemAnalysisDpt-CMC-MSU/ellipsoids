classdef ContControlBuilder
    %
    properties (Access = private)
        intEllTube
        probDynamicsList
        goodDirSetList
        switchSysTimeVec
    end
    %
    methods
        function self = ContControlBuilder(reachContObj)
            % CONTCONTROLBUILDER is a main class for building control
            % synthesis for continuous time systems. The class acts like a
            % control factory
            %
            % Input:
            %   regular:
            %       reachContObj: elltool.reach.ReachContinuous[1,1] - an
            %           object containing reachability tube ellipsoidal
            %           approximations for some continuous time system. It
            %           is expected that a reachability tube in reachContObj
            %           is calculated in a backward time
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $
            % $Date: 2015-30-10 $
            %
            import modgen.common.throwerror;
            self.switchSysTimeVec =  reachContObj.getSwitchTimeVec();
            ellTubeRel = reachContObj.getEllTubeRel();
            self.intEllTube = ellTubeRel.getTuplesFilteredBy('approxType', ...
                gras.ellapx.enums.EApproxType.Internal);
            self.probDynamicsList = reachContObj.getIntProbDynamicsList();
            self.goodDirSetList = reachContObj.getGoodDirSetList();
            isBackward = reachContObj.isbackward();
            if (~isBackward)
                throwerror('wrongInput',...
                    ['System is in a forward time while it should',...
                    'be in a backward time']);
            end
        end
        
        function controlFuncObj = getControlObj(self,x0Vec)
            % GETCONTROLOBJ returns an eltool.control.ContSingleTubeControl
            % object
            %
            % Input:
            %   regular:
            %       x0Vec: double[nDims,1] - starting point of system
            %           trajectory from which control synthesis is performed.
            %           Here nDims denotes a phase space dimensionality.
            %
            % Output:
            %   controlFuncObj: elltool.control.ContSingleTubeControl[1,1]
            %       - object providing computing control synthesis and
            %       getting the corresponding trajectory
            %
            % $Author: Komarov Yuri <ykomarov94@gmail.com> $
            % $Date: 2015-30-10 $
            %
            import modgen.common.throwerror;
            ELL_INT_TOL = 1e-5;
            %
            nEllTubes = self.intEllTube.getNTuples;
            %
            indProperTube = 1;
            isX0InSet = false;
            %
            if ~all(size(x0Vec) == size(self.intEllTube.aMat{1}(:,1)))
                throwerror('wrongInput',...
                    ['the dimension of x0 does not correspond the ',...
                    'dimension of solvability domain']);
            end
            %
            for iTube=1:nEllTubes
                qVec = self.intEllTube.aMat{iTube}(:,1);
                qMat = self.intEllTube.QArray{iTube}(:,:,1);
                if ( dot(x0Vec-qVec,qMat\(x0Vec-qVec)) <= 1 + ELL_INT_TOL)
                    isX0InSet = true;
                    indProperTube = iTube;
                    break;
                end
            end
            %
            goodDirOrderedVec = mapGoodDirInd(self.goodDirSetList{1}{1},...
                self.intEllTube);
            indTube = goodDirOrderedVec(indProperTube);
            properEllTube = self.intEllTube.getTuples(indProperTube);
            %
            qVec = properEllTube.aMat{1}(:,1);
            qMat = properEllTube.QArray{1}(:,:,1);
            if (isX0InSet)
                indWithoutX=findEllWithoutX(qVec, qMat, x0Vec);
            else
                indWithoutX=1;
            end
            properEllTube.scale(@(x)sqrt(indWithoutX),'QArray');
            % scale multiplies QArray*(k^2)
            %
            properProbDynList = getProperProbDynList(indTube);
            properGoodDirSetList = getProperGoodDirSetList(indTube);
            %
            controlFuncObj = elltool.control.ContSingleTubeControl(...
                properEllTube,properProbDynList, properGoodDirSetList,...
                self.switchSysTimeVec, indWithoutX);
            %
            function properProbDynList = getProperProbDynList(indTube)
                properProbDynList = cellfun(@(x)(x{min(indTube,numel(x))}),...
                    self.probDynamicsList,'UniformOutput',false);
            end
            %
            function properGoodDirSetList = getProperGoodDirSetList(indTube)
                properGoodDirSetList = cellfun(@(x)(x{min(indTube,numel(x))}),...
                    self.goodDirSetList,'UniformOutput',false);
            end
            %
            function indWithoutX = findEllWithoutX(qVec, qMat, x0Vec)
                indWithoutX = 1;
                scalProd = dot(x0Vec-qVec,qMat\(x0Vec-qVec));
                if (scalProd > 0 && scalProd <= 1)
                    indWithoutX = scalProd;
                end
            end
            %
            function goodDirOrderedVec = mapGoodDirInd(goodDirSetObj,ellTube)
                import modgen.common.throwerror;
                CMP_TOL=1e-10;
                %
                nEllTubes = ellTube.getNTuples;
                goodDirOrderedVec = zeros(1,nEllTubes);
                lsGoodDirMat = goodDirSetObj.getlsGoodDirMat();
                for iGoodDir = 1:size(lsGoodDirMat, 2)
                    lsGoodDirMat(:, iGoodDir) = ...
                        lsGoodDirMat(:, iGoodDir) / ...
                        norm(lsGoodDirMat(:, iGoodDir));
                end
                %
                lsGoodDirCMat = ellTube.lsGoodDirVec;
                for iEllTube = 1 : nEllTubes
                    %
                    % good directions' indexes mapping
                    %
                    curGoodDirVec = lsGoodDirCMat{iEllTube};
                    curGoodDirVec = curGoodDirVec / norm(curGoodDirVec);
                    for iGoodDir = 1:size(lsGoodDirMat, 2)
                        isFound = norm(curGoodDirVec - ...
                            lsGoodDirMat(:, iGoodDir)) <= CMP_TOL;
                        if isFound
                            break;
                        end
                    end
                    if ~isFound
                        throwerror('wrongState',...
                            ['Ooops, we should not be here, ',...
                            '''one to one'' mapping between good ',...
                            'directions from\n',...
                            'goodDirSetObj object and good directions\n',...
                            'from ellipsoidal tubes cannot be ',...
                            'constructed']);
                    end
                    goodDirOrderedVec(iEllTube)=iGoodDir;
                end
            end
        end
    end
end