classdef EllMinkBTC < mlunitext.test_case &...
        elltool.core.test.mlunit.EllMinkBodyPlotT
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
        function self = EllMinkBTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self =...
               self@elltool.core.test.mlunit.EllMinkBodyPlotT(varargin{:});
        end
        function self = testMink2EllSimpleOptions(self)
            testFirEll = self.ellipsoid(2*eye(2));
            testSecEll = self.ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = self.ellipsoid([2 0; 0 1]);
            testForthEll = self.ellipsoid([0, -1, 3].', 0.5*eye(3));
            testFifthEll = self.ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            self.minkFillAndShade(testSecEll,testFirEll);
            self.minkFillAndShade(testFifthEll,testForthEll);
            self.minkColor(testSecEll,testFirEll,2);
            self.minkColor(testFifthEll,testForthEll,1);
            self.minkColor(testFirEll,testThirdEll,2);
            self.minkProperties(testSecEll,testFirEll);
            self.minkProperties(testFifthEll,testForthEll);
            self.minkProperties(testFirEll,testThirdEll);
        end
    end
end