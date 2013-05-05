classdef EllipsoidMinkmpPlotTestCase < mlunitext.test_case & elltool.plot.test.SumMpPmMinkBodyTestPlot
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods
        function self = EllipsoidMinkmpPlotTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self = self@elltool.plot.test.SumMpPmMinkBodyTestPlot(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = testSimpleOptions(self)
            self = simpleOptions2(self,@minkmp,true);
        end
        function self = test2d(self)
            testFirEll = ellipsoid([1, 0].', [9 2;2 4]);
            testSecEll = ellipsoid(eye(2));
            testThirdEll = ellipsoid([2 1;1 2]);
            testForthEll=ellipsoid(diag([0.8 0.1]));
            testFifthEll=ellipsoid(diag([1 2]));
            check(testFirEll,testSecEll,testThirdEll);
            check(testFifthEll,testForthEll,testSecEll);
            
            function check(testFirEll,testSecEll,testThirdEll)
                absTol = 10^(-3);
                [~,boundPoints] = minkmp(testFirEll,testSecEll,testThirdEll);
                [lGridMat] = gras.geom.circlepart(200);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                [supp3Mat,~] = rho(testThirdEll, lGridMat.');
                rhoDiffVec = gras.geom.sup.supgeomdiff2d(supp1Mat,supp2Mat,lGridMat.');
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunit.assert_equals(abs(supVec'-rhoDiffVec-supp3Mat) < absTol,ones(1,size(supVec,1)));      
           
            end
        end
        function self = test3d(self)
            testFirEll = ellipsoid([1, 0, 0].', [9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = ellipsoid(eye(3));
            testForthEll=ellipsoid(diag([1 2 1 ]));
            testFifthEll=ellipsoid(diag([0.8 0.1 0.1]));       
            testThirdEll = ellipsoid([2 1 0 ;1 2 0;0 0 1]);
            check(testFirEll,testSecEll,testThirdEll);
            check(testForthEll,testFifthEll,testSecEll);
            
            function check(testFirEll,testSecEll,testThirdEll)
                absTol = 10^(-1);
                [~,boundPoints] = minkmp(testFirEll,testSecEll,testThirdEll);
                [lGridMat, ~] = gras.geom.tri.spheretri(3);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                [supp3Mat,~] = rho(testThirdEll, lGridMat.');
                rhoDiffVec = gras.geom.sup.supgeomdiff3d(supp1Mat,supp2Mat,lGridMat.');
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunit.assert_equals(abs(supVec'-rhoDiffVec-supp3Mat) < absTol,ones(1,size(supVec,1)));     
           
            end
        end
    end
end