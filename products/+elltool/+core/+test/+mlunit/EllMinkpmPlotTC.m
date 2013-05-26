classdef EllMinkpmPlotTC < elltool.core.test.mlunit.EllMinkDTC
    
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods
        function self = EllMinkpmPlotTC(varargin)
            self =...
                self@elltool.core.test.mlunit.EllMinkDTC(varargin{:});
            self.isInv = false;
            self.fMink = @minkpm;
            self.fRhoDiff2d = @fRhoDiff2d;
            self.fRhoDiff3d = @fRhoDiff3d;
            function rhoDiffVec=...
                    fRhoDiff2d(supp1Mat,supp2Mat,supp3Mat,lGridMat)
                rhoDiffVec = gras.geom.sup.supgeomdiff2d(supp1Mat...
                    +supp2Mat,supp3Mat,lGridMat.');
            end
            
            
            function rhoDiffVec=...
                    fRhoDiff3d(supp1Mat,supp2Mat,supp3Mat,lGridMat)
                rhoDiffVec = gras.geom.sup.supgeomdiff3d(supp1Mat...
                    +supp2Mat,supp3Mat,lGridMat.');
            end
        end
        function self = tear_down(self,varargin)
            close all;
        end
        
    end
end