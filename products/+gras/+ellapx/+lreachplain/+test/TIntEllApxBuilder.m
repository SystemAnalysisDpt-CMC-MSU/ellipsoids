classdef TIntEllApxBuilder < gras.test.mlunit.TolCounter & ...
    gras.ellapx.lreachplain.IntEllApxBuilder
    %TINTELLAPXBUILDER Subclass to check Tol references
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
            beforeGetAbsTol@gras.ellapx.lreachplain.IntEllApxBuilder(self);
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            beforeGetRelTol@gras.ellapx.lreachplain.IntEllApxBuilder(self);
            self.incRelTolCount();
        end
    end
    %
    methods
        function self = TIntEllApxBuilder(varargin)
            self = self@gras.test.mlunit.TolCounter(true);
            self = self@gras.ellapx.lreachplain.IntEllApxBuilder(...
                varargin{:});
            self.finishTolTest();
        end
    end
end

