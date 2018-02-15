classdef EllMinkdiffPlotTC < elltool.core.test.mlunit.EllMinkBTC
%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    properties (Access = private)
        ellFactoryObj;
    end
    %
    methods
        function set_up_param(self)
            self.ellFactoryObj = elltool.core.test.mlunit.TEllipsoidFactory();
        end
    end
    methods
        function ellObj = ellipsoid(self, varargin)
            ellObj = self.ellFactoryObj.createInstance('ellipsoid', ...
                varargin{:});            
        end
    end
    %
    methods
        function self = EllMinkdiffPlotTC(varargin)
            self =...
               self@elltool.core.test.mlunit.EllMinkBTC(varargin{:});
           self.fMink = @minkdiff;
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = test2d(self)
            testFirEll = self.ellipsoid([1, 0].', [9 2;2 4]);
            testSecEll = self.ellipsoid(eye(2));
            testThirdEll=self.ellipsoid(diag([1 2]));
            testForthEll=self.ellipsoid(diag([0.8 0.1]));
            check(testFirEll,testSecEll);
            check(testThirdEll,testForthEll);
            
            function check(testFirEll,testSecEll)
                import elltool.conf.Properties;
                ABS_TOL = 10^(-3);
                [~,boundPoints] = minkdiff(testFirEll,testSecEll);
                [lGridMat] = gras.geom.circlepart(...
                    Properties.getNPlot2dPoints);
                [supp1Arr,~] = rho(testFirEll,lGridMat.');
                [supp2Arr,~] = rho(testSecEll,lGridMat.');
                rhoDiffVec = gras.geom.sup.supgeomdiff2d(supp1Arr,...
                    supp2Arr,lGridMat.');
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunitext.assert_equals(abs(supVec'-rhoDiffVec) < ABS_TOL,...
                    ones(1,size(supVec,1)));      
            end
        end
        function self = test3d(self)
            testFirEll = self.ellipsoid([1, 0, 0].', [9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = self.ellipsoid(eye(3));
            testThirdEll = self.ellipsoid(diag([1 2 1 ]));
            testForthEll = self.ellipsoid(diag([0.8 0.1 0.1]));
            check(testFirEll,testSecEll);
            check(testThirdEll,testForthEll);
            function check(testFirEll,testSecEll)
                ABS_TOL = 10^(-2);
                [~,boundPoints] = minkdiff(testFirEll,testSecEll);
                [lGridMat, ~] = gras.geom.tri.spheretri(3);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                rhoDiffVec = gras.geom.sup.supgeomdiff3d(supp1Mat,...
                    supp2Mat,lGridMat.');
                mlunitext.assert_equals(abs(supVec'-rhoDiffVec) < ABS_TOL,...
                    ones(1,size(supVec,1)));      
            end
        end
    end
end