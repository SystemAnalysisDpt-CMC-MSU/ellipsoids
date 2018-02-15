classdef EllMinksumPlotTC < elltool.core.test.mlunit.EllMinkATC&...
        elltool.core.test.mlunit.EllMinkBTC
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
        function self = EllMinksumPlotTC(varargin)
            self = ...
               self@elltool.core.test.mlunit.EllMinkATC(varargin{:});
           self =...
               self@elltool.core.test.mlunit.EllMinkBTC(varargin{:});
           self.fMink = @minksum;
           self.isInv = false;
        end
        function self = tear_down(self,varargin)
            close all;
        end
        function self = test2d(self)
            testFirEll = self.ellipsoid( [9 2;2 4]);
            testSecEll = self.ellipsoid(eye(2));
            check(testFirEll,testSecEll);
            check2(testFirEll,testSecEll);
            function check(testFirEll,testSecEll)
                import elltool.conf.Properties;
                ABS_TOL = 10^(-10);
                [~,boundPointsMat] = minksum(testFirEll,testSecEll);
                [lGridMat] = gras.geom.circlepart(...
                    Properties.getNPlot2dPoints);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                rhoDiffVec = supp1Mat+supp2Mat;
                sup = max(lGridMat*boundPointsMat(:,1:end-1),[],2);
                absDiff = max(abs(sup'-rhoDiffVec));
                mlunitext.assert_equals(true,absDiff < ABS_TOL,...
                    sprintf(['absolute difference (%.17g) is greater'...
                    ' than the specified tolerance (%.17g)'],...
                    absDiff,ABS_TOL));
            end
            function check2(testFirEll,testSecEll)
                import elltool.conf.Properties;
                ABS_TOL = 10^(-10);
                [lGridMat] = gras.geom.circlepart(...
                    Properties.getNPlot2dPoints);
                rotAngle = pi/4;
                rotMat = [cos(rotAngle) sin(rotAngle) ;...
                    -sin(rotAngle) cos(rotAngle)];
                firstMat = rotMat.'*testFirEll.double*rotMat;
                firstMat(1,2) = firstMat(2,1);
                testThirdEll = self.ellipsoid(firstMat);
                secMat = rotMat*testSecEll.double*rotMat.';
                secMat(1,2) = secMat(2,1);
                testForthEll = self.ellipsoid(secMat);
                [~,boundPoints1Mat] = minksum(testFirEll,testSecEll);
                [~,boundPoints2Mat] = minksum(testThirdEll,testForthEll);
                boundPoints2Mat = (boundPoints2Mat.'*rotMat.').';
                sup1 = max(lGridMat*boundPoints1Mat(:,1:end-1),[],2);
                sup2 = max(lGridMat*boundPoints2Mat(:,1:end-1),[],2);
                mlunitext.assert_equals(max(abs(sup2-sup1)) < ABS_TOL,1);
            end
        end
        function self = test3d(self)
            testFirEll = self.ellipsoid([9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = self.ellipsoid(eye(3));
            check(testFirEll,testSecEll);
            function check(testFirEll,testSecEll)
                ABS_TOL = 10^(-1);
                [lGridMat, ~] = gras.geom.tri.spheretri(3);
                rotAngle = 3*pi/2;
                rotMat = [cos(rotAngle) sin(rotAngle) 0;...
                    -sin(rotAngle) cos(rotAngle) 0;0 0 1];
                firstMat = rotMat.'*testFirEll.double*rotMat;
                firstMat(1,2) = firstMat(2,1);
                firstMat(1,3) = firstMat(3,1);
                firstMat(2,3) = firstMat(3,2);
                testThirdEll = self.ellipsoid(firstMat);
                secondMat = rotMat*testSecEll.double*rotMat.';
                secondMat(1,2) = secondMat(2,1);
                secondMat(1,3) = secondMat(3,1);
                secondMat(2,3) = secondMat(3,2);
                testForthEll = self.ellipsoid(secondMat);
                [~,boundPoints1Mat] = minksum(testFirEll,testSecEll);
                [~,boundPoints2Mat] = minksum(testThirdEll,testForthEll);
                boundPoints2Mat = (boundPoints2Mat.'*rotMat.').';
                sup1 = max(lGridMat*boundPoints1Mat(:,1:end-1),[],2);
                sup2 = max(lGridMat*boundPoints2Mat(:,1:end-1),[],2);
                mlunitext.assert_equals(max(abs(sup2-sup1)) < ABS_TOL,1);
            end
        end
    end
end