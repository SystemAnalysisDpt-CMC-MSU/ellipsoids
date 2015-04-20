classdef ContControlBuilder
% ContControlBuilder - wrapper class for building control synthesis for
%   continuous case
% 
% Properties:
% 	intEllTube - an gras.ellapx.smartdb.rels.EllTube object containing
%       internal approximations of solvability tube 
% 
%   probDynamicsList - cellArray of gras.ellapx.lreachplain.probdyn.LReachProblemLTIDynamics
%       objects that provides information about system's dynamics
% 
%   goodDirSetList - cellArray of gras.ellapx.lreachplain.GoodDirsContinuousLTI
%       objects that provides information about so-called 'good directions'
% 
% Methods:
%   ContControlBuilder() - class constructor
% 
%   getControl() - returns the eltool.control.Control object that provides
%       getting control synthesis for predetermined point (t,x) and
%       corresponding trajectory
%

    properties (Access = private)
        intEllTube
        probDynamicsList
        goodDirSetList
    end
    
    methods        
        function self = ContControlBuilder(reachContObj)
            % CONTCONTROLBUILDER is a class constructor. Creates an
            %   instance of ContControlBuilder class defining its properies
            %   required for constructing coltrol synthesis.
            %
            % Input:
            %   reachContObj: an elltool.reach.ReachContinuous object
            %       containing required properties for control synthesis
            %       construction. Notice that reachContObj is to be in
            %       backward time.
            
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
        
        function controlFuncObj = getControl(self,x0Vec)
            % GETCONTROL returns the eltool.control.Control object that
            %   provides getting control synthesis for predetermined point
            %   (t,x) and corresponding trajectory
            %
            % Input:
            %   x0Vec: double[n,1], where n is a dimentionality of phase
            %       space - position from which the syntesis is to 
            %       be constructed
            %
            % Output:
            %   controlFuncObj: an elltool.control.Control object that
            %       provides computing control synthesis for each point
            %       (t,x) we interested in and getting the corresponding
            %       trajectory
            
            import modgen.common.throwerror;
            nTuples = self.intEllTube.getNTuples;
            ELL_INT_TOL = 10^(-5);
            
            %Tuple selection
            properIndTube = 1;
            isX0InSet = false;
            
            if (~all(size(x0Vec) == size(self.intEllTube.aMat{1}(:,1))))
                throwerror('wrongInput',...
                    'the dimension of x0 does not correspond the dimension of solvability domain');
            end
            
            for iTube=1:nTuples
                %check if x is in E(q,Q), x: <x-q,Q^(-1)(x-q)><=1
                %if (dot(x-qVec,inv(qMat)*(x-qVec))<=1)
                
                qVec = self.intEllTube.aMat{iTube}(:,1);  
                qMat = self.intEllTube.QArray{iTube}(:,:,1); 
                if ( dot(x0Vec-qVec,qMat\(x0Vec-qVec)) <= 1 + ELL_INT_TOL)                    
                    isX0InSet = true;                    
                    properIndTube = iTube;
                    break; % 'cause till this moment the proper tube is already found
                end
            end
            
            goodDirOrderedVec = mapGoodDirInd(self.goodDirSetList{1}{1},self.intEllTube);
            indTube = goodDirOrderedVec(properIndTube);
            properEllTube = self.intEllTube.getTuples(properIndTube); 
            
            qVec = properEllTube.aMat{:}(:,1);  
            qMat = properEllTube.QArray{:}(:,:,1);  
            if (isX0InSet)  
                indWithoutX=findEllWithoutX(qVec, qMat, x0Vec);
            else
                indWithoutX=1;
            end
            properEllTube.scale(@(x)sqrt(indWithoutX),'QArray'); 
            % scale multiplies QArray*(k^2)
 
            controlFuncObj = elltool.control.Control(properEllTube,...
                self.probDynamicsList, self.goodDirSetList,indTube,indWithoutX);  
            
            function iWithoutX = findEllWithoutX(qVec, qMat, x0Vec)
                iWithoutX = 1;
                scalProd = dot(x0Vec-qVec,qMat\(x0Vec-qVec));
                if (scalProd <= 1)
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