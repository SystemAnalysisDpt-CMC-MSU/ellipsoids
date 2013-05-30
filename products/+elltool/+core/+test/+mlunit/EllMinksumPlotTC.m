classdef EllMinksumPlotTC < elltool.core.test.mlunit.EllMinkATC&...
        elltool.core.test.mlunit.EllMinkBTC
 %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
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
            testFirEll = ellipsoid( [9 2;2 4]);
            testSecEll = ellipsoid(eye(2));
            check(testFirEll,testSecEll);
            check2(testFirEll,testSecEll);
            function check(testFirEll,testSecEll)
                ABS_TOL = 10^(-10);
                [~,boundPointsMat] = minksum(testFirEll,testSecEll);
                [lGridMat] = gras.geom.circlepart(200);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                rhoDiffVec = supp1Mat+supp2Mat;
                sup = max(lGridMat*boundPointsMat(:,1:end-1),[],2);
                mlunitext.assert_equals(abs(sup'-rhoDiffVec) < ABS_TOL,...
                    ones(1,size(sup,1)));
            end
            function check2(testFirEll,testSecEll)
                ABS_TOL = 10^(-10);
                [lGridMat] = gras.geom.circlepart(200);
                rotAngle = pi/4;
                rotMat = [cos(rotAngle) sin(rotAngle) ;...
                    -sin(rotAngle) cos(rotAngle)];
                firstMat = rotMat.'*testFirEll.double*rotMat;
                firstMat(1,2) = firstMat(2,1);
                testThirdEll = ellipsoid(firstMat);
                secMat = rotMat*testSecEll.double*rotMat.';
                secMat(1,2) = secMat(2,1);
                testForthEll = ellipsoid(secMat);
                [~,boundPoints1Mat] = minksum(testFirEll,testSecEll);
                [~,boundPoints2Mat] = minksum(testThirdEll,testForthEll);
                boundPoints2Mat = (boundPoints2Mat.'*rotMat.').';
                sup1 = max(lGridMat*boundPoints1Mat(:,1:end-1),[],2);
                sup2 = max(lGridMat*boundPoints2Mat(:,1:end-1),[],2);
                mlunitext.assert_equals(max(abs(sup2-sup1)) < ABS_TOL,1);
            end
        end
        function self = test3d(self)
            testFirEll = ellipsoid([9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = ellipsoid(eye(3));
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
                testThirdEll = ellipsoid(firstMat);
                secondMat = rotMat*testSecEll.double*rotMat.';
                secondMat(1,2) = secondMat(2,1);
                secondMat(1,3) = secondMat(3,1);
                secondMat(2,3) = secondMat(3,2);
                testForthEll = ellipsoid(secondMat);
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