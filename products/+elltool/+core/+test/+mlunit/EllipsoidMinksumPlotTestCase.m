classdef EllipsoidMinksumPlotTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
        
    end
    %
    methods
        function self = EllipsoidMinksumPlotTestCase(varargin)
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
            testThirdEll = ellipsoid([1 0; 0 0]);
            testForthEll = ellipsoid([0, -1, 3].', 1.5*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            testSixthEll = ellipsoid([1 0 0; 0 0 0; 0 0 1]);
            self = testMinkFillAndShade(self,@minksum,testFirEll,testSecEll);
            self = testMinkFillAndShade(self,@minksum,testFirEll,[testSecEll,testThirdEll]);
            self = testMinkFillAndShade(self,@minksum,testForthEll,testFifthEll);
            self = testMinkFillAndShade(self,@minksum,testForthEll,[testFifthEll testSixthEll]);
            self = testMinkColor(self,@minksum,testFirEll,testSecEll,2);
            self = testMinkColor(self,@minksum,testFirEll,[testSecEll,testThirdEll],2);
            self = testMinkColor(self,@minksum,testForthEll,testFifthEll,1);
            self = testMinkColor(self,@minksum,testForthEll,[testFifthEll testSixthEll],1); 
            self = testMinkProperties(self,@minksum,testFirEll,testSecEll);
            self = testMinkProperties(self,@minksum,testFirEll,[testSecEll,testThirdEll]);
            self = testMinkProperties(self,@minksum,testForthEll,testFifthEll);
            self = testMinkProperties(self,@minksum,testForthEll,[testFifthEll testSixthEll]); 
        end
        
    end
end