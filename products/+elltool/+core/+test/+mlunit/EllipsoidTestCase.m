classdef EllipsoidTestCase < mlunitext.test_case
     properties (Access=private)
        testDataRootDir
     end
     methods
        function self=EllipsoidTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = testDistance(self)
            
            global  ellOptions;
            load(strcat(self.testDataRootDir,filesep,'testEllEllRMat.mat'),...
                 'testOrth50Mat','testOrth100Mat','testOrth3Mat','testOrth2Mat');
            %
            %testing vector-ellipsoid distance
            %
            %distance between ellipsoid and two vectors
            testEllipsoid = ellipsoid([1,0,0;0,5,0;0,0,10]);
            testPointMat = [3,0,0; 5,0,0].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunit.assert_equals(1, (abs(testResVec(1)-2)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-4)<ellOptions.abs_tol));
            %
            %distance between ellipsoid and point in the ellipsoid
            %and point on the boader of the ellipsoid
            testEllipsoid = ellipsoid([1,2,3].',4*eye(3,3));
            testPointMat = [2,3,2; 1,2,5].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunit.assert_equals(1, testResVec(1)==-1 && testResVec(2)==0);
            %           
            %distance between two ellipsoids and two vectors
            testEllipsoidVec = [ellipsoid([5,2,0;2,5,0;0,0,1]),...
                ellipsoid([0,0,5].',[4, 0, 0; 0, 9 , 0; 0,0, 25])];
            testPointMat = [0,0,5; 0,5,5].';
            testResVec = distance(testEllipsoidVec, testPointMat);
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-2)<ellOptions.abs_tol));
            %
            %distance between two ellipsoids and a vector
            testEllipsoidVec = [ellipsoid([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                ellipsoid([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            testResVec = distance(testEllipsoidVec, testPointVec);
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-1)<ellOptions.abs_tol));
            %
            %negative test: matrix Q of ellipsoid has very large
            %eigenvalues.
            testEllipsoid = ellipsoid([1e+15,0;0,1e+15]);
            testPointVec = [3e+15,0].';
            self.runAndCheckError('distance(testEllipsoid, testPointVec)',...
                'notSecant');
            %
            %random ellipsoid matrix, low dimension case
            nDim=2;
            testEllMat=diag(1:2);
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=ellipsoid(testEllMat);
            testPoint=testOrth2Mat*[10;zeros(nDim-1,1)];
            testRes=distance(testEllipsoid, testPoint);
            mlunit.assert_equals(1,abs(testRes-9)<ellOptions.abs_tol);
            %
            %high dimensional tests with rotated ellipsoids
            nDim=50;
            testEllMat=diag(nDim:-1:1);
            testEllMat=testOrth50Mat*testEllMat*testOrth50Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=ellipsoid(testEllMat);
            testPoint=testOrth50Mat*[zeros(nDim-1,1);10];
            testRes=distance(testEllipsoid, testPoint);
            mlunit.assert_equals(1,abs(testRes-9)<ellOptions.abs_tol);
            
            %distance between two ellipsoids with random matrices and two vectors
            testEll1Mat=[5,2,0;2,5,0;0,0,1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[4,0,0;0,9,0;0,0,25];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[0;0;5];
            testEllipsoidVec = [ellipsoid(testEll1Mat),...
                ellipsoid(testEll2CenterVec,testEll2Mat)];
            testPointMat = testOrth3Mat*([0,0,5; 0,5,5].');
            testResVec = distance(testEllipsoidVec, testPointMat);
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-2)<ellOptions.abs_tol));
            %
            %
            %
            %
            %Testing ellipsoid-ellipsoid distance
            %
            %distance between two ellipsoids
            testEllipsoid1 = ellipsoid([25,0;0,9]);
            testEllipsoid2 = ellipsoid([10;0],[4,0;0,9]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-3)<ellOptions.abs_tol));
            %    
            testEllipsoid1 = ellipsoid([0,-15,0].',[25,0,0;0,100,0;0,0,9]);
            testEllipsoid2 = ellipsoid([0,7,0].',[9,0,0;0,25,0;0,0,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-7)<ellOptions.abs_tol));
            %
            % case of ellipses with common center
            testEllipsoid1 = ellipsoid([1 2 3].',[1,2,5;2,5,3;5,3,100]);
            testEllipsoid2 = ellipsoid([1,2,3].',[1,2,7;2,10,5;7,5,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes)<ellOptions.abs_tol));
            %
            % distance between two pairs of ellipsoids 
            testEllipsoid1Vec=[ellipsoid([0, -6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,-4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testEllipsoid2Vec=[ellipsoid([0, 6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunit.assert_equals(1, (abs(testResVec(1)-8)<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-5)<ellOptions.abs_tol));
            %            
            % distance between two ellipsoids and an ellipsoid 
            testEllipsoidVec=[ellipsoid([0, 0, 0].',[9,0,0; 0,25,0; 0,0, 1]),...
                ellipsoid([-5,0,0].',[9,0,0; 0, 25,0; 0,0,1])];
            testEllipsoid=ellipsoid([5, 0, 0].',[25,0,0; 0,100,0; 0,0, 1]);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunit.assert_equals(1, (abs(testResVec(1))<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-2)<ellOptions.abs_tol));
            %
            %distance between two ellipsoids of high dimensions
            nDim=100;
            testEllipsoid1=ellipsoid(diag(1:2:2*nDim));
            testEllipsoid2=ellipsoid([5;zeros(nDim-1,1)],diag(1:nDim));
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1,abs(testRes-3)<ellOptions.abs_tol);
            %
            %distance between two vectors of ellipsoids of rather high
            %dimension (12<=nDim<=26) with matrices that have nonzero non
            %diagonal elements
            load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
                 'testEllipsoid1Vec','testEllipsoid2Vec','testAnswVec','nEllVec');
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunit.assert_equals(ones(1,nEllVec),...
                 abs(testResVec-testAnswVec)<ellOptions.abs_tol);
            %
            %distance between two ellipsoids and an ellipsoid (of 3-dimension), 
            %all matrices with nonzero nondiagonal elements 
            testEll1Mat=[9,0,0; 0,25,0; 0,0, 1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[9,0,0; 0, 25,0; 0,0,1];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[-5;0;0];
            testEll3Mat=[25,0,0; 0,100,0; 0,0, 1];
            testEll3Mat=testOrth3Mat*testEll3Mat*testOrth3Mat.';
            testEll3Mat=0.5*(testEll3Mat+testEll3Mat.');
            testEll3CenterVec=testOrth3Mat*[5;0;0];
            testEllipsoidVec=[ellipsoid(testEll1Mat),...
                ellipsoid(testEll2CenterVec,testEll2Mat)];
            testEllipsoid=ellipsoid(testEll3CenterVec,testEll3Mat);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunit.assert_equals(1, (abs(testResVec(1))<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-2)<ellOptions.abs_tol));
            %
            %distance between two ellipsoids of high dimensions and random
            %matrices
            nDim=100;
            testEll1Mat=diag(1:2:2*nDim);
            testEll1Mat=testOrth100Mat*testEll1Mat*testOrth100Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=diag([25;(1:(nDim-1)).']);
            testEll2Mat=testOrth100Mat*testEll2Mat*testOrth100Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth100Mat*[9;zeros(nDim-1,1)];            
            testEllipsoid1=ellipsoid(testEll1Mat);
            testEllipsoid2=ellipsoid(testEll2CenterVec,testEll2Mat);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1,abs(testRes-3)<ellOptions.abs_tol);
            %
            %
            %
            %distance between an ellipsoid (with nonzeros nondiagonal elements)
            %and a hyperplane in 2 dimensions
            testEllMat=[9 0; 0 4];
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllCenterVec=testOrth2Mat*[0;5];
            testHypVVec=testOrth2Mat*[0;1];
            testHypC=0;
            testEllipsoid=ellipsoid(testEllCenterVec,testEllMat);
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunit.assert_equals(1,abs(testRes-3)<ellOptions.abs_tol);
            %
            %distance between an ellipsoid (with nonzero nondiagonal elements)
            %and a hyperplane in 3 dimensions
            testEllMat=[100,0,0;0,25,0;0,0,9];
            testEllMat=testOrth3Mat*testEllMat*testOrth3Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testHypVVec=testOrth3Mat*[0;1;0];
            testHypC=10;
            testEllipsoid=ellipsoid(testEllMat);
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunit.assert_equals(1,abs(testRes-5)<ellOptions.abs_tol);
            %
            %distance between two high dimensional ellipsoids (with nonzero
            %nondiagonal elements) and a hyperplane
            nDim=100;
            testEll1Mat=diag(1:nDim);
            testEll1Mat=testOrth100Mat*testEll1Mat*testOrth100Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll1CenterVec=testOrth100Mat*[-8;zeros(nDim-1,1)];    
            testEll2Mat=diag([25;(1:(nDim-1)).']);
            testEll2Mat=testOrth100Mat*testEll2Mat*testOrth100Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth100Mat*[10;zeros(nDim-1,1)];    
            testHypVVec=testOrth100Mat*[1;zeros(nDim-1,1)];
            testHypC=0;
            testEllipsoid=[ellipsoid(testEll1CenterVec,testEll1Mat),...
                ellipsoid(testEll2CenterVec,testEll2Mat)];
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunit.assert_equals(1,abs(testRes(1)-7)<ellOptions.abs_tol&&...
                abs(testRes(2)-5)<ellOptions.abs_tol);   
            
            %distance where two ellipsoids have one common point 
            % according to existing precision policy ellOptions.abs_tol
            testEll1=ellipsoid([1+1e-20 0].',[1 0; 0 1]);
            testEll2=ellipsoid([-1 0].',[1 0;0 1]);
            testRes=distance(testEll1,testEll2);
            mlunit.assert_equals(1,abs(testRes)<ellOptions.abs_tol);   
            
            %
            %
            %DISTANCE FROM VECTOR TO ELLIPSOID 
            %IN ELLIPSOID METRIC
            %
            % Test#1. Distance between an ellipsoid and a vector.
            testEllipsoid = ellipsoid([1,0,0;0,5,0;0,0,10]);
            testPointVec = [3,0,0].';
            testRes = distance(testEllipsoid, testPointVec,1);
            ansRes = ellVecDistanceCVX(testEllipsoid, testPointVec,1);
            mlunit.assert_equals(1, (abs(testRes-ansRes)<ellOptions.abs_tol));
            %
            % Test#2. Distance between an ellipsoid and a vector.
            testEllipsoid = ellipsoid([2,0,0;0,5,0;0,0,10]);
            testPointVec = [3,0,0].';
            testRes = distance(testEllipsoid, testPointVec,1);
            ansRes = ellVecDistanceCVX(testEllipsoid, testPointVec,1);
            mlunit.assert_equals(1, (abs(testRes-ansRes)<ellOptions.abs_tol));
            %
            %Test#3 
            % Distance between two ellipsoids and a vector
            testEllipsoidVec = [ellipsoid([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                ellipsoid([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            testResVec = distance(testEllipsoidVec, testPointVec,1);
            ansResVec(1)=ellVecDistanceCVX(testEllipsoidVec(1), testPointVec,1);
            ansResVec(2)=ellVecDistanceCVX(testEllipsoidVec(2), testPointVec,1);
            mlunit.assert_equals(1, (abs(testResVec(1)-ansResVec(1))<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-ansResVec(2))<ellOptions.abs_tol));
            %
            %Test#4.
            % Random ellipsoid matrix, low dimension case.
            nDim=2;
            testEllMat=diag(1:2);
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=ellipsoid(testEllMat);
            testPointVec=testOrth2Mat*[10;zeros(nDim-1,1)];
            testRes=distance(testEllipsoid, testPointVec,1);
            ansRes = ellVecDistanceCVX(testEllipsoid, testPointVec,1);
            mlunit.assert_equals(1,abs(testRes-ansRes)<ellOptions.abs_tol);
            %
            %Test#5.
            % Distance between two ellipsoids with random matrices and two vectors
            testEll1Mat=[5,2,0;2,5,0;0,0,1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[4,0,0;0,9,0;0,0,25];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[0;0;5];
            testEllipsoid1=ellipsoid(testEll1Mat);
            testEllipsoid2=ellipsoid(testEll2CenterVec,testEll2Mat);
            testEllipsoidVec = [testEllipsoid1,testEllipsoid2];
            testPointMat = testOrth3Mat*([0,0,5; 0,5,5].');
            testResVec = distance(testEllipsoidVec, testPointMat,1);
            ansResVec(1)=distance(testEllipsoid1,testPointMat(:,1),1);
            ansResVec(2)=distance(testEllipsoid2,testPointMat(:,2),1);
            mlunit.assert_equals(1, (abs(testResVec(1)-ansResVec(1))<ellOptions.abs_tol) &&...
                (abs(testResVec(2)-ansResVec(2))<ellOptions.abs_tol));
            %
%             %DISTANCE FROM ELLIPSOID TO ELLIPSOID 
%             %IN ELLIPSOID METRIC
%             %
%             % Test#1.
%             % Distance between two ellipsoids
%             testEllipsoid1 = ellipsoid([25,0;0,9]);
%             testEllipsoid2 = ellipsoid([10;0],[4,0;0,9]);
%             testRes=distance(testEllipsoid1,testEllipsoid2,1);
%             ansRes=ellEllDistanceCVX(testEllipsoid1,testEllipsoid2,1);
%             mlunit.assert_equals(1, (abs(testRes-ansRes)<ellOptions.abs_tol));
        end
    end
end

function distEll=ellVecDistanceCVX(ellObj,vectorVec,flag)
    [ellCenVec ellQMat]=double(ellObj);
    ellQMat=ellQMat\eye(size(ellQMat));
    ellQMat=0.5*(ellQMat+ellQMat.');
    ellDims = dimension(ellObj);
    maxDim   = max(max(ellDims));
    cvx_begin sdp
        variable x(maxDim, 1)
        if flag
            fDist = (x - vectorVec)'*ellQMat*(x - vectorVec);
        else
            fDist = (x - vectorVec)'*(x - vectorVec);
        end
        minimize(fDist)
        subject to
            x'*ellQMat*x + 2*(-ellQMat*ellCenVec)'*x + (ellCenVec'*ellQMat*ellCenVec - 1) <= 0
    cvx_end
    distEll = sqrt(fDist);
end
function distEllEll=ellEllDistanceCVX(ellObj1,ellObj2,flag)
%     [ellCenVec ellQMat]=double(ellObj);
%     ellQMat=ellQMat\eye(size(ellQMat));
%     ellQMat=0.5*(ellQMat+ellQMat.');
%     ellDims = dimension(ellObj);
%     maxDim   = max(max(ellDims));
    dims1 = dimension(ellObj1);
    dims2 = dimension(ellObj2);
    mn1   = min(min(dims1));
    mn2   = min(min(dims2));
    mx1   = max(max(dims1));
    mx2   = max(max(dims2));
    [q, Q] = double(ellObj1);
    [r, R] = double(ellObj2);
    Qi     = ell_inv(Q);
    Qi     = 0.5*(Qi + Qi');
    Ri     = ell_inv(R);
    Ri     = 0.5*(Ri + Ri');
    cvx_begin sdp
            variable x(mx1, 1)
            variable y(mx1, 1)
            if flag
                f = (x - y)'*Qi*(x - y);
            else
                f = (x - y)'*(x - y);
            end
            minimize(f)
            subject to
                x'*Qi*x + 2*(-Qi*q)'*x + (q'*Qi*q - 1) <= 0
                y'*Ri*y + 2*(-Ri*r)'*y + (r'*Ri*r - 1) <= 0
        cvx_end

        distEllEll = f;
end