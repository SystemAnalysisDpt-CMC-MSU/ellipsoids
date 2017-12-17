classdef TExtEllApxBuilder < gras.ellapx.lreachplain.ExtEllApxBuilder & ...
    gras.ellapx.lreachplain.test.TATightEllApxBuilder
    %TEXTELLAPXBUILDER Subclass to check Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods
        function self = TExtEllApxBuilder(varargin)
            self = ...
                self@gras.ellapx.lreachplain.test.TATightEllApxBuilder(...
                varargin{:});
        end
    end
end

