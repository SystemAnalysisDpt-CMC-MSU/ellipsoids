classdef EllMinkATC < mlunitext.test_case &...
        elltool.plot.test.EllMinkBodyPlotT
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    properties (Access=public)
        fMink,isInv
    end
    methods
        function self = EllMinkATC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self = self@elltool.plot.test.EllMinkBodyPlotT(varargin{:});
        end
        function self = testMinkmpSimpleOptions(self)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([1 0; 0 2]);
            testForthEll = ellipsoid([0, -1, 3].', 3*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            testSixthEll = ellipsoid([1 0 0; 0 2 0; 0 0 1]);
            if self.isInv
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
            self = minkFillAndShade(self,self.fMink,testFirstEllMat,...
                testSecEllMat);
            self = minkFillAndShade(self,self.fMink,testThirdEllMat,...
                testForthEllMat);
            self = minkColor(self,self.fMink,testFirstEllMat,testSecEllMat,2);
            self = minkColor(self,self.fMink,testThirdEllMat,testForthEllMat,1);
            self = minkProperties(self,self.fMink,testFirstEllMat,...
                testSecEllMat);
            self = minkProperties(self,self.fMink,testThirdEllMat,...
                testForthEllMat);
            self.fMink(testFirstEllMat,testSecEllMat,'showAll',true);
            self.fMink(testThirdEllMat,testForthEllMat,'showAll',true);
        end
        
    end
end