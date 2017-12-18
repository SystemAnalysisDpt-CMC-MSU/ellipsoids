classdef TReachDiscrete < elltool.reach.ReachDiscrete & ...
        gras.test.mlunit.TolCounter
    %TREACHDISCRETE Subclass to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Access=protected)
        function beforeGetAbsTol(self)
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            self.incRelTolCount();
        end
    end
    %
    methods (Access = protected)
        function [ellTubeRel,goodDirSetObj] = auxMakeEllTubeRel(self, ...
            varargin)
            self.startTolTest();
            [ellTubeRel,goodDirSetObj] = ...
                auxMakeEllTubeRel@elltool.reach.ReachDiscrete(self, ...
            	varargin{:});
            self.finishTolTest();
        end
        function [ellTubeRel,goodDirSetObj] = internalMakeEllTubeRel(...
                self,probDynObj,l0Mat,timeVec,isDisturb,absTol,relTol,...
                approxTypeVec)
            self.startTolTest();
            [ellTubeRel,goodDirSetObj] = ...
                internalMakeEllTubeRel@elltool.reach.ReachDiscrete(...
                self,probDynObj,l0Mat,timeVec,isDisturb,absTol,relTol,...
                approxTypeVec);
            self.finishTolTest();
        end
        function linSys = getProbDynamics(self,atStrCMat,btStrCMat,...
                ptStrCMat,ptStrCVec,ctStrCMat,qtStrCMat,qtStrCVec, x0Mat,...
                x0Vec,timeLimVec,relTol,absTol)
            self.startTolTest();
            linSys = getProbDynamics@elltool.reach.ReachDiscrete(self,...
                atStrCMat,btStrCMat,ptStrCMat,ptStrCVec,ctStrCMat,...
                qtStrCMat,qtStrCVec, x0Mat,...
                x0Vec,timeLimVec,relTol,absTol);
            self.finishTolTest();
        end
        function [ellTubeRel,goodDirSetObj,probDynObj] = makeEllTubeRel(...
                self,probDynObj,l0Mat,timeVec,isDisturb,absTol,relTol,...
                approxTypeVec)
            self.startTolTest();
            [ellTubeRel,goodDirSetObj,probDynObj] = ...
                makeEllTubeRel@elltool.reach.AReach(self,probDynObj,...
                    l0Mat,timeVec,isDisturb,absTol,relTol,approxTypeVec);
            self.finishTolTest();
        end
    end
    %
    methods
        function self = TReachDiscrete(varargin)
            self = self@gras.test.mlunit.TolCounter();
            self = self@elltool.reach.ReachDiscrete(varargin{:});
        end
    end
    
end

