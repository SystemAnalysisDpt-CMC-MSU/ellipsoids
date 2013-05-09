classdef EllMinkBTC < mlunitext.test_case &...
        elltool.plot.test.EllMinkBodyPlotT
%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    properties (Access=public)
        fMinkOp
    end
    methods
        function self = EllMinkBTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            self = self@elltool.plot.test.EllMinkBodyPlotT(varargin{:});
        end
        function self = testMinkdiffSimpleOptions(self)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([2 0; 0 1]);
            testForthEll = ellipsoid([0, -1, 3].', 0.5*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            self = minkFillAndShade(self,self.fMinkOp,testSecEll,testFirEll);
            self = minkFillAndShade(self,self.fMinkOp,testFifthEll,testForthEll);
            self = minkColor(self,self.fMinkOp,testSecEll,testFirEll,2);
            self = minkColor(self,self.fMinkOp,testFifthEll,testForthEll,1);
            self = minkColor(self,self.fMinkOp,testFirEll,testThirdEll,2);
            self = minkProperties(self,self.fMinkOp,testSecEll,testFirEll);
            self = minkProperties(self,self.fMinkOp,testFifthEll,testForthEll);
            self = minkProperties(self,self.fMinkOp,testFirEll,testThirdEll);
        end
    end
end