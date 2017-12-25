classdef TExtIntEllApxBuilder < gras.test.mlunit.TolCounter & ...
        gras.ellapx.lreachuncert.ExtIntEllApxBuilder
    %TEXTINTELLAPXBUILDER Subclass to count Tol references
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
            beforeGetAbsTol@gras.ellapx.lreachuncert.ExtIntEllApxBuilder(self);
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            beforeGetRelTol@gras.ellapx.lreachuncert.ExtIntEllApxBuilder(self);
            self.incRelTolCount();
        end
    end
    %
    methods
        function self = TExtIntEllApxBuilder(varargin)
            self = self@gras.test.mlunit.TolCounter(true);
            self = ...
                self@gras.ellapx.lreachuncert.ExtIntEllApxBuilder(varargin{:});
            self.finishTolTest();
        end
    end
end

