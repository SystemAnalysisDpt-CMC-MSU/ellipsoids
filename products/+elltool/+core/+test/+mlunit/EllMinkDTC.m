classdef EllMinkDTC <   elltool.core.test.mlunit.EllMinkATC
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
    %$Date: 2013-05-7 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    properties (Access=private)
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
    properties (Access=protected)
        fRhoDiff2d,fRhoDiff3d
    end
    methods
        function self = EllMinkDTC(varargin)
            self = self@ elltool.core.test.mlunit.EllMinkATC(varargin{:});
        end
        function self = testMink2d(self)
            testFirEll = self.ellipsoid([1, 0].', [9 2;2 4]);
            testSecEll = self.ellipsoid(eye(2));
            testThirdEll = self.ellipsoid([2 1;1 2]);
            testForthEll=self.ellipsoid(diag([0.8 0.1]));
            testFifthEll=self.ellipsoid(diag([1 2]));
            
            if self.isInv
                check(testFirEll, testThirdEll, testSecEll);
                check(testFifthEll,testForthEll,testSecEll);
            else
                check(testFirEll, testSecEll, testThirdEll);
                check(testFifthEll, testSecEll, testForthEll);
            end
            function check(testFirEll,testSecEll,testThirdEll)
                import elltool.conf.Properties;
                ABS_TOL = 10^(-2);
                POINTS_NUMBER = Properties.getNPlot2dPoints;
                [~,boundPoints] = ...
                    self.fMink(testFirEll,testSecEll,testThirdEll);
                [lGridMat] = gras.geom.circlepart(POINTS_NUMBER);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                [supp3Mat,~] = rho(testThirdEll, lGridMat.');
                rhoDiffVec = self.fRhoDiff2d(supp1Mat,supp2Mat,supp3Mat,lGridMat);
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunitext.assert_equals(abs(supVec'-rhoDiffVec) ...
                    < ABS_TOL,ones(1,size(supVec,1)));
                
            end
        end
        function self = testMink3d(self)
            testFirEll = self.ellipsoid([1, 0, 0].', [9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = self.ellipsoid(eye(3));
            testForthEll = self.ellipsoid(diag([1 2 1 ]));
            testFifthEll = self.ellipsoid(diag([0.8 0.1 0.1]));
            testThirdEll = self.ellipsoid([2 1 0 ;1 2 0;0 0 1]);
            if self.isInv
                check(testFirEll, testSecEll, testThirdEll);
                check(testForthEll,testFifthEll,testSecEll);
            else
                check(testFirEll, testSecEll, testThirdEll);
                check(testForthEll,testSecEll,testFifthEll);
            end
            function check(testFirEll,testSecEll,testThirdEll)
                ABS_TOL = 10^(-1);
                [~,boundPoints] = self.fMink(testFirEll,testSecEll,...
                    testThirdEll);
                [lGridMat, ~] = gras.geom.tri.spheretri(3);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                [supp3Mat,~] = rho(testThirdEll, lGridMat.');
                rhoDiffVec = self.fRhoDiff3d(supp1Mat,supp2Mat,supp3Mat,lGridMat);
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunitext.assert_equals(abs(supVec'-rhoDiffVec)...
                    < ABS_TOL,ones(1,size(supVec,1)));
            end
        end
    end
end