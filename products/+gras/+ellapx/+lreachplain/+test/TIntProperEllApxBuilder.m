classdef TIntProperEllApxBuilder < elltool.reach.test.mlunit.TolCounter & ...
        gras.ellapx.lreachplain.IntProperEllApxBuilder
    %TINTPROPERELLAPXBUILDER Subclass to count Tol references
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
        function self = TIntProperEllApxBuilder(varargin)
            self = self@elltool.reach.test.mlunit.TolCounter('true');
            self = self@gras.ellapx.lreachplain.IntProperEllApxBuilder(...
                varargin{:});
            self.finishTolTest();
        end
    end 
end

