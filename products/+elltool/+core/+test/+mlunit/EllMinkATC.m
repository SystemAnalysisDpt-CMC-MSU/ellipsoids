classdef EllMinkATC < mlunitext.test_case &...
        elltool.core.test.mlunit.EllMinkBodyPlotT
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    properties (Access=protected)
        isInv
    end
    %
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
        function self = EllMinkATC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self =...
               self@elltool.core.test.mlunit.EllMinkBodyPlotT(varargin{:});
        end
        function self = testMink3EllSimpleOptions(self)
            testFirEll = self.ellipsoid(2*eye(2));
            testSecEll = self.ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = self.ellipsoid([1 0; 0 2]);
            testForthEll = self.ellipsoid([0, -1, 3].', 3*eye(3));
            testFifthEll = self.ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            testSixthEll = self.ellipsoid([1 0 0; 0 2 0; 0 0 1]);
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
            self.minkFillAndShade(testFirstEllMat,...
                testSecEllMat);
            self.minkFillAndShade(testThirdEllMat,...
                testForthEllMat);
            self.minkColor(testFirstEllMat,testSecEllMat,2);
            self.minkColor(testThirdEllMat,testForthEllMat,1);
            self.minkProperties(testFirstEllMat,...
                testSecEllMat);
            self.minkProperties(testThirdEllMat,...
                testForthEllMat);
            self.fMink(testFirstEllMat,testSecEllMat,'showAll',true);
            self.fMink(testThirdEllMat,testForthEllMat,'showAll',true);
        end
        
    end
end