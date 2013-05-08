classdef EllMinkpmPlotTC < mlunitext.test_case &...
        elltool.plot.test.EllMinkATC
    
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    methods
        function self = EllMinkpmPlotTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self =...
                self@elltool.plot.test.EllMinkATC(varargin{:});
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testSimpleOptions(self)
            self = minkmpSimpleOptions(self, @minkpm, false);
        end
        function self = test2d(self)
            self = minkTest2d(self,@minkpm,@fRhoDiff,false);
            
            function rhoDiffVec=fRhoDiff(supp1Mat,supp2Mat,supp3Mat,lGridMat)
                rhoDiffVec = gras.geom.sup.supgeomdiff2d(supp1Mat...
                    +supp2Mat,supp3Mat,lGridMat.');
            end
        end
        
        
        function self = test3d(self)
            self = minkTest3d(self,@minkpm,@fRhoDiff,false);
            
            function rhoDiffVec=fRhoDiff(supp1Mat,supp2Mat,supp3Mat,lGridMat)
                rhoDiffVec = gras.geom.sup.supgeomdiff3d(supp1Mat...
                    +supp2Mat,supp3Mat,lGridMat.');
            end
        end
    end
end