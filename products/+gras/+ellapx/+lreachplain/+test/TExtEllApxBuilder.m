classdef TExtEllApxBuilder < gras.ellapx.lreachplain.ExtEllApxBuilder & ...
    gras.test.mlunit.TolCounter
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
        function beforeGetAbsTol(self)
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            self.incRelTolCount();
        end
    end
    %
    methods
        function self = TExtEllApxBuilder(varargin)
            self = self@gras.test.mlunit.TolCounter(true);
            self = ...
                self@gras.ellapx.lreachplain.ExtEllApxBuilder(varargin{:});
            self.finishTolTest();
        end
    end
end

