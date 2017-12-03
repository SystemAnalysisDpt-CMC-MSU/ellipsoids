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
            self.resetTolCounters();
            [ellTubeRel,goodDirSetObj] = ...
                auxMakeEllTubeRel@elltool.reach.ReachContinuous(self, ...
            	varargin{:});
            self.checkMentions();
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

