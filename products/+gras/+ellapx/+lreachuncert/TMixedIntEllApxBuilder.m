classdef TMixedIntEllApxBuilder < elltool.reach.TolCounter & ...
        gras.ellapx.lreachuncert.MixedIntEllApxBuilder
    %TMIXEDINTELLAPXBUILDER Subclass to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods (Access = protected)
        function countAbsTolMentions(self)
            self.incAbsTolCount();
        end
        function countRelTolMentions(self)
            self.incRelTolCount();
        end
    end
    %
    methods
        function self = TMixedIntEllApxBuilder(varargin)
            self = self@elltool.reach.TolCounter('true');
            self = ...
                self@gras.ellapx.lreachuncert.MixedIntEllApxBuilder(varargin{:});
            self.finishTolTest();
        end
    end
end
