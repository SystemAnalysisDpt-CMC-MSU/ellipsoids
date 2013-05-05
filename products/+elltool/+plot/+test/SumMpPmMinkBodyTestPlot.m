classdef SumMpPmMinkBodyTestPlot < elltool.plot.test.SMinkBodyTestPlot
    methods
        function self = SumMpPmMinkBodyTestPlot(varargin)
            self = self@elltool.plot.test.SMinkBodyTestPlot(varargin{:});
        end
        function self = simpleOptions2(self,fmink,isInv)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([1 0; 0 2]);
            testForthEll = ellipsoid([0, -1, 3].', 3*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            testSixthEll = ellipsoid([1 0 0; 0 2 0; 0 0 1]);
            if isInv
                testFirstEllMat = [testFirEll,testThirdEll];
                testSecEllMat = testSecEll;
                testThirdEllMat = [testForthEll,testSixthEll];
                testForthEllMat = testFifthEll;
            else
                testFirstEllMat = [testFirEll, testSecEll];
                testSecEllMat = testThirdEll;
                testThirdEllMat = [testForthEll,testFifthEll];
                testForthEllMat = testSixthEll;
            end
            self = testMinkFillAndShade(self,fmink,testFirstEllMat,testSecEllMat);
            self = testMinkFillAndShade(self,fmink,testThirdEllMat,testForthEllMat);
            self = testMinkColor(self,fmink,testFirstEllMat,testSecEllMat,2);
            self = testMinkColor(self,fmink,testThirdEllMat,testForthEllMat,1); 
            self = testMinkProperties(self,fmink,testFirstEllMat,testSecEllMat);
            self = testMinkProperties(self,fmink,testThirdEllMat,testForthEllMat); 
            fmink(testFirstEllMat,testSecEllMat,'showAll',true);
            fmink(testThirdEllMat,testForthEllMat,'showAll',true);
        end
    end
end