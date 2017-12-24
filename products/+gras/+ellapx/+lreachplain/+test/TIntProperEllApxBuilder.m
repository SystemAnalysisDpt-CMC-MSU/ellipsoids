classdef TIntProperEllApxBuilder < gras.test.mlunit.TolCounter & ...
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
        function beforeGetAbsTol(self)
            beforeGetAbsTol@gras.ellapx.lreachplain.IntProperEllApxBuilder(self);
            self.incAbsTolCount();
        end
        function beforeGetRelTol(self)
            beforeGetRelTol@gras.ellapx.lreachplain.IntProperEllApxBuilder(self);
            self.incRelTolCount();
        end
    end
    %
    methods
        function self = TIntProperEllApxBuilder(varargin)
            self = self@gras.test.mlunit.TolCounter(true);
            self = self@gras.ellapx.lreachplain.IntProperEllApxBuilder(...
                varargin{:});
            self.finishTolTest();
        end
    end 
end

