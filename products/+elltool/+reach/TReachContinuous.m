classdef TReachContinuous < elltool.reach.ReachContinuous & ...
        elltool.reach.TolCounter
    %TREACHCONTINUOUS Subclass to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Access=protected)
        function countAbsTolMentions(self)
            self.incAbsTolCount();
        end
        function countRelTolMentions(self)
            self.incRelTolCount();
        end
    end
    %
    methods (Access = protected)
        function [ellTubeRel,goodDirSetObj] = auxMakeEllTubeRel(self, ...
            varargin)
            self.startTolTest();
            [ellTubeRel,goodDirSetObj] = ...
                auxMakeEllTubeRel@elltool.reach.ReachContinuous(self, ...
            	varargin{:});
            self.finishTolTest();
        end
        function [ellTubeRel,goodDirSetObj] = internalMakeEllTubeRel(...
                self,probDynObj,l0Mat,timeVec,isDisturb,absTol,relTol,...
                approxTypeVec)
            self.startTolTest();
            [ellTubeRel,goodDirSetObj] = ...
                internalMakeEllTubeRel@elltool.reach.ReachContinuous(...
                self,probDynObj,l0Mat,timeVec,isDisturb,absTol,relTol,...
                approxTypeVec);
            self.finishTolTest();
        end
        function linSys = getProbDynamics(self,atStrCMat,btStrCMat,...
                ptStrCMat,ptStrCVec,ctStrCMat,qtStrCMat,qtStrCVec, x0Mat,...
                x0Vec,timeLimVec,relTol,absTol)
            self.startTolTest();
            linSys = getProbDynamics@elltool.reach.ReachContinuous(self,...
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
        function self = TReachContinuous(varargin)
            self = self@elltool.reach.TolCounter();
            self = self@elltool.reach.ReachContinuous(varargin{:});
        end
    end
end

