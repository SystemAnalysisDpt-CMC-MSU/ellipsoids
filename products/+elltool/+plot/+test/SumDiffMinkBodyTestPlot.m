classdef SumDiffMinkBodyTestPlot < elltool.plot.test.SMinkBodyTestPlot
    methods
        function self = SumDiffMinkBodyTestPlot(varargin)
            self = self@elltool.plot.test.SMinkBodyTestPlot(varargin{:});
        end
        function self = simpleOptions1(self,fmink)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([2 0; 0 1]);
            testForthEll = ellipsoid([0, -1, 3].', 0.5*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            self = testMinkFillAndShade(self,fmink,testSecEll,testFirEll);
            self = testMinkFillAndShade(self,fmink,testFifthEll,testForthEll);
            self = testMinkColor(self,fmink,testSecEll,testFirEll,2);
            self = testMinkColor(self,fmink,testFifthEll,testForthEll,1);
            self = testMinkColor(self,fmink,testFirEll,testThirdEll,2);
            self = testMinkProperties(self,fmink,testSecEll,testFirEll);
            self = testMinkProperties(self,fmink,testFifthEll,testForthEll);
            self = testMinkProperties(self,fmink,testFirEll,testThirdEll);
        end
    end
end