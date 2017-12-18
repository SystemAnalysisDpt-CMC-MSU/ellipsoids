classdef TExtEllApxBuilder < gras.ellapx.lreachplain.ExtEllApxBuilder & ...
    elltool.reach.test.mlunit.TolCounter
    %TEXTELLAPXBUILDER Subclass to check Tol references
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
        function self = TExtEllApxBuilder(varargin)
            self = self@elltool.reach.test.mlunit.TolCounter('true');
            self = ...
                self@gras.ellapx.lreachplain.ExtEllApxBuilder(varargin{:});
            self.finishTolTest();
        end
    end
end

