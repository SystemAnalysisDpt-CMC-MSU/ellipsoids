classdef EllMinkATC < elltool.plot.test.EllMinkBodyPlotT
    %$Author: Ilya Lyubich <lubi4ig@gmail.com> $
%$Date: 2013-05-7 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    methods
        function self = EllMinkATC(varargin)
            self = self@elltool.plot.test.EllMinkBodyPlotT(varargin{:});
        end
        function self = minkmpSimpleOptions(self,fMink,isInv)
            testFirEll = ellipsoid(2*eye(2));
            testSecEll = ellipsoid([1, 0].', [9 2;2 4]);
            testThirdEll = ellipsoid([1 0; 0 2]);
            testForthEll = ellipsoid([0, -1, 3].', 3*eye(3));
            testFifthEll = ellipsoid([5,5,5]', [6 2 1; 2 4 3; 1 3 5]);
            testSixthEll = ellipsoid([1 0 0; 0 2 0; 0 0 1]);
            if isInv
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
            self = minkFillAndShade(self,fMink,testFirstEllMat,...
                testSecEllMat);
            self = minkFillAndShade(self,fMink,testThirdEllMat,...
                testForthEllMat);
            self = minkColor(self,fMink,testFirstEllMat,testSecEllMat,2);
            self = minkColor(self,fMink,testThirdEllMat,testForthEllMat,1); 
            self = minkProperties(self,fMink,testFirstEllMat,...
                testSecEllMat);
            self = minkProperties(self,fMink,testThirdEllMat,...
                testForthEllMat); 
            fMink(testFirstEllMat,testSecEllMat,'showAll',true);
            fMink(testThirdEllMat,testForthEllMat,'showAll',true);
        end
        function self = minkTest2d(self,fMink,fRhoDiff,isInv)
            testFirEll = ellipsoid([1, 0].', [9 2;2 4]);
            testSecEll = ellipsoid(eye(2));
            testThirdEll = ellipsoid([2 1;1 2]);
            testForthEll=ellipsoid(diag([0.8 0.1]));
            testFifthEll=ellipsoid(diag([1 2]));
            
            if isInv
                check(testFirEll, testThirdEll, testSecEll);
                check(testFifthEll,testForthEll,testSecEll);
            else
                check(testFirEll, testSecEll, testThirdEll);
                check(testFifthEll, testSecEll, testForthEll);
            end
            function check(testFirEll,testSecEll,testThirdEll)
                ABS_TOL = 10^(-2);
                POINTS_NUMBER = 200;
                [~,boundPoints] = ...
                    fMink(testFirEll,testSecEll,testThirdEll);
                [lGridMat] = gras.geom.circlepart(POINTS_NUMBER);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                [supp3Mat,~] = rho(testThirdEll, lGridMat.');
                rhoDiffVec = fRhoDiff(supp1Mat,supp2Mat,supp3Mat,lGridMat);
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunit.assert_equals(abs(supVec'-rhoDiffVec) ...
                    < ABS_TOL,ones(1,size(supVec,1)));      
           
            end
        end
        function self = minkTest3d(self,fMink,fRhoDiff,isInv)
            testFirEll = ellipsoid([1, 0, 0].', [9 2 0 ;2 4 0; 0 0 4]);
            testSecEll = ellipsoid(eye(3));
            testForthEll = ellipsoid(diag([1 2 1 ]));
            testFifthEll = ellipsoid(diag([0.8 0.1 0.1]));       
            testThirdEll = ellipsoid([2 1 0 ;1 2 0;0 0 1]);
            if isInv
                check(testFirEll, testSecEll, testThirdEll);
                check(testForthEll,testFifthEll,testSecEll);
            else
                check(testFirEll, testSecEll, testThirdEll);
                check(testForthEll,testSecEll,testFifthEll);
            end
            function check(testFirEll,testSecEll,testThirdEll)
                ABS_TOL = 10^(-1);
                [~,boundPoints] = fMink(testFirEll,testSecEll,...
                    testThirdEll);
                [lGridMat, ~] = gras.geom.tri.spheretri(3);
                [supp1Mat,~] = rho(testFirEll,lGridMat.');
                [supp2Mat,~] = rho(testSecEll,lGridMat.');
                [supp3Mat,~] = rho(testThirdEll, lGridMat.');
                rhoDiffVec = fRhoDiff(supp1Mat,supp2Mat,supp3Mat,lGridMat);
                supVec = max(lGridMat*boundPoints(:,1:end-1),[],2);
                mlunit.assert_equals(abs(supVec'-rhoDiffVec)...
                    < ABS_TOL,ones(1,size(supVec,1)));     
           
            end
        end
    end
end