classdef EllipsoidMinkdiffPlotTestCase < mlunitext.test_case & elltool.plot.test.SumDiffMinkBodyTestPlot
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods
        function self = EllipsoidMinkdiffPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self = self@elltool.plot.test.SumDiffMinkBodyTestPlot(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testSimpleOptions(self)
            self = simpleOptions1(self,@minkdiff);
        end
        function self = test2d(self)
            testFirEll = ellipsoid([1, 0].', [9 2;2 4]);
            testSecEll = ellipsoid(eye(2));
            testThirdEll=ellipsoid(diag([1 2]));
            testForthEll=ellipsoid(diag([0.8 0.1]));
            check(testFirEll,testSecEll);
            check(testThirdEll,testForthEll);
            
            function check(testFirEll,testSecEll)
                absTol = 10^(-3);
                [~,boundPoints] = minkdiff(testFirEll,testSecEll);
                [lGridMat] = gras.geom.circlepart(200);
                [supp1Arr,~] = rho(testFirEll,lGridMat.');
                [supp2Arr,~] = rho(testSecEll,lGridMat.');
                rhoDiffVec = gras.geom.sup.supgeomdiff2d(supp1Arr,supp2Arr,lGridMat.');
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunit.assert_equals(abs(supVec'-rhoDiffVec) < absTol,ones(1,size(supVec,1)));      
            end
        end
        function self = test3d(self)
            testFirEll = ellipsoid([1, 0, 0].', [9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = ellipsoid(eye(3));
            testThirdEll=ellipsoid(diag([1 2 1 ]));
            testForthEll=ellipsoid(diag([0.8 0.1 0.1]));
            check(testFirEll,testSecEll);
            check(testThirdEll,testForthEll);

            
            function check(testFirEll,testSecEll)
                absTol = 10^(-2);
                [~,boundPoints] = minkdiff(testFirEll,testSecEll);
                [lGridMat, ~] = gras.geom.tri.spheretri(3);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                rhoDiffVec = gras.geom.sup.supgeomdiff3d(supp1Mat,supp2Mat,lGridMat.');
                mlunit.assert_equals(abs(supVec'-rhoDiffVec) < absTol,ones(1,size(supVec,1)));      
            end
        end
    end
end