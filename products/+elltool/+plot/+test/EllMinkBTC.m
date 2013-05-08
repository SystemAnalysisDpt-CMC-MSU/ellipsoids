classdef EllMinkBTC < elltool.plot.test.EllMinkBodyPlotT
%$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    methods
        function self = EllMinkBTC(varargin)
            self = self@elltool.plot.test.EllMinkBodyPlotT(varargin{:});
        end
        function self = minkdiffSimpleOptions(self,fMink)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([2 0; 0 1]);
            testForthEll = ellipsoid([0, -1, 3].', 0.5*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            self = minkFillAndShade(self,fMink,testSecEll,testFirEll);
            self = minkFillAndShade(self,fMink,testFifthEll,testForthEll);
            self = minkColor(self,fMink,testSecEll,testFirEll,2);
            self = minkColor(self,fMink,testFifthEll,testForthEll,1);
            self = minkColor(self,fMink,testFirEll,testThirdEll,2);
            self = minkProperties(self,fMink,testSecEll,testFirEll);
            self = minkProperties(self,fMink,testFifthEll,testForthEll);
            self = minkProperties(self,fMink,testFirEll,testThirdEll);
        end
    end
end