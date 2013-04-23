classdef EllipsoidMinkdiffPlotTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods
        function self = EllipsoidMinkdiffPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testSimpleOptions(self)
            import elltool.plot.test.testMinkFillAndShade
            import elltool.plot.test.testMinkColor
            import elltool.plot.test.testMinkProperties
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([2 0; 0 0]);
            testForthEll = ellipsoid([0, -1, 3].', 0.5*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            %             testSixthEll = ellipsoid([1 0 0; 0 0 0; 0 0 1]);
            self = testMinkFillAndShade(self,@minkdiff,testSecEll,testFirEll);
            self = testMinkFillAndShade(self,@minkdiff,testFifthEll,testForthEll);
            self = testMinkColor(self,@minkdiff,testSecEll,testFirEll,2);
            self = testMinkColor(self,@minkdiff,testFifthEll,testForthEll,1);
            self = testMinkColor(self,@minkdiff,testFirEll,testThirdEll,2);
            self = testMinkProperties(self,@minkdiff,testSecEll,testFirEll);
            self = testMinkProperties(self,@minkdiff,testFifthEll,testForthEll);
            self = testMinkProperties(self,@minkdiff,testFirEll,testThirdEll);
        end
        function self = test2d(self)
            testFirEll = ellipsoid([1, 0].', [9 2;2 4]);
            testSecEll = ellipsoid(eye(2));
            testThirdEll=ellipsoid(diag([1 2]));
            testForthEll=ellipsoid(diag([0.8 0.1]));
            check(testFirEll,testSecEll);
            check(testThirdEll,testForthEll);
            
            function check(testFirEll,testSecEll)
                absTol = 10^(-4);
                [~,boundPoints] = minkdiff(testFirEll,testSecEll);
                [lGridMat] = gras.geom.circlepart(200);
                [supp1Arr,~] = rho(testFirEll,lGridMat.');
                [supp2Arr,~] = rho(testSecEll,lGridMat.');
                rhoDiffVec = gras.geom.sup.supgeomdiff2d(supp1Arr,supp2Arr,lGridMat.');
                sup = max(lGridMat*boundPoints(:,1:end-1),[],2);
                abs(sup'-rhoDiffVec)
                mlunit.assert_equals(abs(sup'-rhoDiffVec) < absTol,ones(1,size(sup,1)));      
            end
        end
        function self = test3d(self)
            testFirEll = ellipsoid([1, 0, 0].', [9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = ellipsoid(eye(3));
            check(testFirEll,testSecEll);
            
            function check(testFirEll,testSecEll)
                absTol = 10^(-3);
                [~,boundPoints] = minkdiff(testFirEll,testSecEll);
                [lGridMat, fMat] = gras.geom.tri.spheretri(1);
                [supp1Arr,~] = rho(testFirEll,lGridMat.');
                [supp2Arr,~] = rho(testSecEll,lGridMat.');
                rhoDiffVec = gras.geom.sup.supgeomdiff3d(supp1Arr,supp2Arr,lGridMat.',fMat);
                sup = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunit.assert_equals(abs(sup'-rhoDiffVec) < absTol,ones(1,size(sup,1)));      
            end
        end
    end
end