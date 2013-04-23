classdef EllipsoidMinkmpPlotTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods
        function self = EllipsoidMinkmpPlotTestCase(varargin)
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
            testThirdEll = ellipsoid([1 0; 0 2]);
            testForthEll = ellipsoid([0, -1, 3].', 3*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            testSixthEll = ellipsoid([1 0 0; 0 2 0; 0 0 1]);
            self = testMinkFillAndShade(self,@minkmp,[testFirEll,testThirdEll],testSecEll);
            self = testMinkFillAndShade(self,@minkmp,[testForthEll,testSixthEll],testFifthEll);
            self = testMinkColor(self,@minkmp,[testFirEll,testThirdEll],testSecEll,2);
            self = testMinkColor(self,@minkmp,[testForthEll, testSixthEll],testFifthEll,1); 
            self = testMinkProperties(self,@minkmp,[testFirEll,testThirdEll],testSecEll);
            self = testMinkProperties(self,@minkmp,[testForthEll, testSixthEll],testFifthEll); 
            minkmp(testFirEll,testThirdEll,testSecEll,'showAll',true);
            minkmp(testForthEll,testSixthEll,testFifthEll,'showAll',true);
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
                [supp1Arr,~] = rho(testFirEll,lGridMat.');
                [supp2Arr,~] = rho(testSecEll,lGridMat.');
                [supp3Arr,~] = rho(testThirdEll, lGridMat.');
                rhoDiffVec = gras.geom.sup.supgeomdiff2d(supp1Arr,supp2Arr,lGridMat.');
                sup = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunit.assert_equals(abs(sup'-rhoDiffVec-supp3Arr) < absTol,ones(1,size(sup,1)));      
           
            end
        end
    end
end