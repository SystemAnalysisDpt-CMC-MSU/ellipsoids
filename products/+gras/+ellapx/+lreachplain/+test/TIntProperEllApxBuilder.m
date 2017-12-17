classdef TIntProperEllApxBuilder < ...
        gras.ellapx.lreachplain.IntProperEllApxBuilder & ...
        gras.ellapx.lreachplain.TATightIntEllApxBuilder
    %TINTPROPERELLAPXBUILDER Subclass to count Tol references
    %
    % $Authors: Ivan Chistyakov <efh996@gmail.com> $
    %               $Date: December-2017
    %
    % $Copyright: Moscow State University,
    %             Faculty of Computational Mathematics
    %             and Computer Science,
    %             System Analysis Department 2017$
    methods
        function self = TIntProperEllApxBuilder(varargin)
            self = self@gras.ellapx.lreachplain.TATightIntEllApxBuilder(...
                varargin{:});
        end
    end 
end

