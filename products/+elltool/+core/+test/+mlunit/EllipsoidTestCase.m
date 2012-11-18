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
            
            import elltool.conf.Properties;
            load(strcat(self.testDataRootDir,filesep,'testEllEllRMat.mat'),...
                 'testOrth50Mat','testOrth100Mat','testOrth3Mat','testOrth2Mat');
            %
            %testing vector-ellipsoid distance
            %
            %distance between ellipsoid and two vectors
            absTol = Properties.getAbsTol();
            testEllipsoid = ellipsoid([1,0,0;0,5,0;0,0,10]);
            testPointMat = [3,0,0; 5,0,0].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunit.assert_equals(1, (abs(testResVec(1)-2)<absTol) &&...
                (abs(testResVec(2)-4)<absTol));
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
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %distance between two ellipsoids and a vector
            testEllipsoidVec = [ellipsoid([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                ellipsoid([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            testResVec = distance(testEllipsoidVec, testPointVec);
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-1)<absTol));
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
            mlunit.assert_equals(1,abs(testRes-9)<absTol);
            %
            %high dimensional tests with rotated ellipsoids
            nDim=50;
            testEllMat=diag(nDim:-1:1);
            testEllMat=testOrth50Mat*testEllMat*testOrth50Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=ellipsoid(testEllMat);
            testPoint=testOrth50Mat*[zeros(nDim-1,1);10];
            testRes=distance(testEllipsoid, testPoint);
            mlunit.assert_equals(1,abs(testRes-9)<absTol);
            
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
            mlunit.assert_equals(1, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
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
            mlunit.assert_equals(1, (abs(testRes-3)<absTol));
            %    
            testEllipsoid1 = ellipsoid([0,-15,0].',[25,0,0;0,100,0;0,0,9]);
            testEllipsoid2 = ellipsoid([0,7,0].',[9,0,0;0,25,0;0,0,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes-7)<absTol));
            %
            % case of ellipses with common center
            testEllipsoid1 = ellipsoid([1 2 3].',[1,2,5;2,5,3;5,3,100]);
            testEllipsoid2 = ellipsoid([1,2,3].',[1,2,7;2,10,5;7,5,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1, (abs(testRes)<absTol));
            %
            % distance between two pairs of ellipsoids 
            testEllipsoid1Vec=[ellipsoid([0, -6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,-4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testEllipsoid2Vec=[ellipsoid([0, 6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                ellipsoid([0,0,4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunit.assert_equals(1, (abs(testResVec(1)-8)<absTol) &&...
                (abs(testResVec(2)-5)<absTol));
            %            
            % distance between two ellipsoids and an ellipsoid 
            testEllipsoidVec=[ellipsoid([0, 0, 0].',[9,0,0; 0,25,0; 0,0, 1]),...
                ellipsoid([-5,0,0].',[9,0,0; 0, 25,0; 0,0,1])];
            testEllipsoid=ellipsoid([5, 0, 0].',[25,0,0; 0,100,0; 0,0, 1]);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunit.assert_equals(1, (abs(testResVec(1))<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %distance between two ellipsoids of high dimensions
            nDim=100;
            testEllipsoid1=ellipsoid(diag(1:2:2*nDim));
            testEllipsoid2=ellipsoid([5;zeros(nDim-1,1)],diag(1:nDim));
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunit.assert_equals(1,abs(testRes-3)<absTol);
            %
            %distance between two vectors of ellipsoids of rather high
            %dimension (12<=nDim<=26) with matrices that have nonzero non
            %diagonal elements
            load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
                 'testEllipsoid1Vec','testEllipsoid2Vec','testAnswVec','nEllVec');
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunit.assert_equals(ones(1,nEllVec),...
                 abs(testResVec-testAnswVec)<absTol);
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
            mlunit.assert_equals(1, (abs(testResVec(1))<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
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
            mlunit.assert_equals(1,abs(testRes-3)<absTol);
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
            mlunit.assert_equals(1,abs(testRes-3)<absTol);
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
            mlunit.assert_equals(1,abs(testRes-5)<absTol);
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
            mlunit.assert_equals(1,abs(testRes(1)-7)<absTol&&...
                abs(testRes(2)-5)<absTol);          
            %distance where two ellipsoids have one common point 
            % according to existing precision policy elltool.conf.Properties.getAbsTol()
            testEll1=ellipsoid([1+1e-20 0].',[1 0; 0 1]);
            testEll2=ellipsoid([-1 0].',[1 0;0 1]);
            testRes=distance(testEll1,testEll2);
            mlunit.assert_equals(1,abs(testRes)<elltool.conf.Properties.getAbsTol());   
            
        end
        function self = testPropertyGetters(self)
            ellCenter = [1;1];
            ellMat = eye(2);
            testAbsTol = 1;
            testRelTol = 2;
            testNPlot2dPoints = 3;
            testNPlot3dPoints = 4;
            args = {ellCenter,ellMat, 'absTol',testAbsTol,'relTol',testRelTol,...
                             'nPlot2dPoints',testNPlot2dPoints,...
                             'nPlot3dPoints',testNPlot3dPoints};
           %%
            ellArr = [ellipsoid(args{:}),ellipsoid(args{:});...
                           ellipsoid(args{:}),ellipsoid(args{:})];
            ellArr(:,:,2) = [ellipsoid(args{:}),ellipsoid(args{:});...
                           ellipsoid(args{:}),ellipsoid(args{:})];
            sizeArr = size(ellArr);
            testAbsTolArr = repmat(testAbsTol,sizeArr);
            testRelTolArr = repmat(testRelTol,sizeArr);
            testNPlot2dPointsArr = repmat(testNPlot2dPoints,sizeArr);
            testNPlot3dPointsArr = repmat(testNPlot3dPoints,sizeArr);
            %%
            isOkArr = (testAbsTolArr == ellArr.getAbsTol()) &(testRelTolArr == ellArr.getRelTol()) &...
               (testNPlot2dPointsArr == ellArr.getNPlot2dPoints()) &...
               (testNPlot3dPointsArr == ellArr.getNPlot3dPoints());
            isOk = all(isOkArr(:));
            mlunit.assert(isOk);            
        end
        function self = testEllipsoid(self)
            %Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testCenterVec, testShapeMat]=double(testEllipsoid);
            isTestRes=isempty(testCenterVec)&&isempty(testShapeMat);
            mlunit.assert_equals(true, isTestRes);
            
            %One argument
            testEllipsoid=ellipsoid(diag([1 4 9 16]));
            [testCenterVec, testShapeMat]=double(testEllipsoid);
            isTestDiagMat=testShapeMat==diag([1 4  9 16]);
            isTestRes=(numel(testCenterVec)==4) && all(testCenterVec(:)==0)&& all(isTestDiagMat(:));
            mlunit.assert_equals(true, isTestRes);
            
            %Two arguments
            fCheckForTestEllipsoidAndDouble([1; 2; -1],[2.5 -1.5 0; -1.5 2.5 0; 0 0 9]);
            fCheckForTestEllipsoidAndDouble(-2*ones(5,1),9*eye(5,5));
            
            %High-dimensional ellipsoids
            fCheckForTestEllipsoidAndDouble(diag(1:12));
            fCheckForTestEllipsoidAndDouble((0:0.1:2).',diag(0:10:200));
            fCheckForTestEllipsoidAndDouble(10*rand(100,1), diag(50*rand(1,100)));
            
            %Check wrong inputs
            self.runAndCheckError('ellipsoid([1 1],eye(2,2))','wrongInput:wrongCenter');
            self.runAndCheckError('ellipsoid([1 1;0 1])','wrongInput:wrongMat');
            self.runAndCheckError('ellipsoid([-1 0;0 -1])','wrongInput:wrongMat');
            self.runAndCheckError('ellipsoid([1;1],eye(3,3))','wrongInput:dimsMismatch');
            
            self.runAndCheckError('ellipsoid([1 -i;-i 1])','wrongInput:imagArgs');
            self.runAndCheckError('ellipsoid([1+i;1],eye(2,2))','wrongInput:imagArgs');
            self.runAndCheckError('ellipsoid([1;0],(1+i)*eye(2,2))','wrongInput:imagArgs');
        end
        function self = testDouble(self)
            %Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testCenterVec, testShapeMat]=double(testEllipsoid);
            isTestRes=isempty(testCenterVec)&&isempty(testShapeMat);
            mlunit.assert_equals(true, isTestRes);
            
            %Chek for one output argument
            testEllipsoid=ellipsoid(-ones(5,1),eye(5,5));
            testShapeMat=double(testEllipsoid);
            isTestEyeMat=testShapeMat==eye(5,5);
            isTestRes=all(isTestEyeMat(:));
            mlunit.assert_equals(true, isTestRes);
            
            %Chek for two output arguments
            fCheckForTestEllipsoidAndDouble(-(1:10)',eye(10,10));
            
            %High-dimensional ellipsoids
            fCheckForTestEllipsoidAndDouble(diag(1:12));
            fCheckForTestEllipsoidAndDouble((0:0.1:2).', diag(0:0.01:0.2));
            fCheckForTestEllipsoidAndDouble(10*rand(100,1), diag(50*rand(1,100)));  
        end
        function self = testParameters(self)
            %Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testCenterVec, testShapeMat]=parameters(testEllipsoid);
            isTestRes=isempty(testCenterVec)&&isempty(testShapeMat);
            mlunit.assert_equals(true, isTestRes);
            
            %Chek for one output argument
            testEllipsoid=ellipsoid(-ones(5,1),eye(5,5));
            testShapeMat=parameters(testEllipsoid);
            isTestEyeMat=testShapeMat==eye(5,5);
            isTestRes=all(isTestEyeMat(:));
            mlunit.assert_equals(true, isTestRes);
            
            %Chek for two output arguments
            fCheckForTestParameters(-(1:10)',eye(10,10));
            
            %High-dimensional ellipsoids
            fCheckForTestParameters(diag(1:12));
            fCheckForTestParameters((0:0.1:2).', diag(0:0.01:0.2));
            fCheckForTestParameters(10*rand(100,1), diag(50*rand(1,100)));
        end
        function self = testDimension(self)
            %Chek for one output argument
            %Case 1: Empty ellipsoid
            testEllipsoid=ellipsoid;
            testRes = dimension(testEllipsoid);
            mlunit.assert_equals(0, testRes);
            %Case 2: Not empty ellipsoid
            testEllipsoid=ellipsoid(0);
            testRes = dimension(testEllipsoid);
            mlunit.assert_equals(1, testRes);
            
            testEllipsoid=ellipsoid(eye(5,5));
            testRes = dimension(testEllipsoid);
            mlunit.assert_equals(5, testRes);
            
            %Chek for two output arguments
            %Case 1: Empty ellipsoid
            testEllipsoid=ellipsoid;
            [testDim, testRank]= dimension(testEllipsoid);
            isTestRes=(testDim==0)&&(testRank==0);
            mlunit.assert_equals(true, isTestRes);
            
            %Case 2: Not empty ellipsoid
            testEllipsoid=ellipsoid(ones(4,1), eye(4,4));
            [testDim, testRank]= dimension(testEllipsoid);
            isTestRes=(testDim==4)&&(testRank==4);
            mlunit.assert_equals(true, isTestRes);
            
            testAMat=[ 3 1;0 1; -2 1];
            testEllipsoid=ellipsoid(testAMat*(testAMat'));
            [testDim, testRank]= dimension(testEllipsoid);
            isTestRes=(testDim==3)&&(testRank==2);
            mlunit.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(1:15)), ...
                ellipsoid(rand(20,1),diag(1:20))];
            testDimsVec = dimension(testEllVec);
            isTestRes = all( testDimsVec == [12 15 20] );
            mlunit.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid, ellipsoid(rand(50,1),9*eye(50,50));
                         ellipsoid, ellipsoid(repmat([diag(0:0.1:5) diag(0:0.1:5)],2,1)), ellipsoid(zeros(30,30))];
            [testDimMat, testRankMat] = dimension(testEllMat);
            isTestDimMat = (testDimMat == [21 0 50; 0 102 30]);
            isTestRankMat = (testRankMat == [20 0 50; 0 50 0]);
            isTestRes = all( isTestDimMat(:)) && all( isTestRankMat(:));
            mlunit.assert_equals(true, isTestRes);
        end
        function self = testIsDegenerate(self)
            %Empty ellipsoid
            self.runAndCheckError('isdegenerate(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Not degerate ellipsoid
            testEllipsoid=ellipsoid(ones(6,1),eye(6,6));
            isTestRes = isdegenerate(testEllipsoid);
            mlunit.assert_equals(false, isTestRes);
            
            %Degenerate ellipsoids
            testEllipsoid=ellipsoid(ones(6,1),zeros(6,6));
            isTestRes = isdegenerate(testEllipsoid);
            mlunit.assert_equals(true, isTestRes);
            
            testAMat=[ 3 1;0 1; -2 1];
            testEllipsoid=ellipsoid(testAMat*(testAMat.'));
            isTestRes=isdegenerate(testEllipsoid);
            mlunit.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:22)), ellipsoid((0:0.1:1.4).',diag(1:15)), ...
                ellipsoid(rand(21,1),diag(0:20))];
            isTestDegVec = isdegenerate(testEllVec);
            isTestRes = all( isTestDegVec == [false false true] );
            mlunit.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid(eye(40,40)), ellipsoid(rand(50,1),9*eye(50,50));
                         ellipsoid(diag(10:2:40)), ellipsoid(repmat([diag(0:0.1:5) diag(0:0.1:5)],2,1)), ellipsoid(zeros(30,30))];
            isTestDegMat = isdegenerate(testEllMat);
            isTestMat = ( isTestDegMat == [true false false; false true true] );
            isTestRes = all( isTestMat(:));
            mlunit.assert_equals(true, isTestRes);
        end
        function self = testIsEmpty(self)
            %Chek realy empty ellipsoid
            testEllipsoid=ellipsoid;
            isTestRes = isempty(testEllipsoid);
            mlunit.assert_equals(true, isTestRes);
            
            %Chek not empty ellipsoid
            testEllipsoid=ellipsoid(eye(10,1),eye(10,10));
            isTestRes = isempty(testEllipsoid);
            mlunit.assert_equals(false, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:22)), ellipsoid((0:0.1:1.4).',diag(1:15)), ...
                ellipsoid(rand(21,1),diag(0:20)), ellipsoid, ellipsoid, ellipsoid(zeros(40,40))];
            isTestEmpVec = isempty(testEllVec);
            isTestRes = all( isTestEmpVec == [false false false true true false] );
            mlunit.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid(eye(40,40)), ellipsoid;
                         ellipsoid, ellipsoid(repmat([diag(0:0.1:5) diag(0:0.1:5)],2,1)), ellipsoid(zeros(30,30))];
            isTestEmpMat = isempty(testEllMat);
            isTestMat = ( isTestEmpMat == [false false true;true false false] );
            isTestRes = all( isTestMat(:));
            mlunit.assert_equals(true, isTestRes);
        end
        function self = testMaxEig(self)
            %Check empty ellipsoid
            self.runAndCheckError('maxeig(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            testEllipsoid1=ellipsoid([1; 1], zeros(2,2));
            testEllipsoid2=ellipsoid(zeros(2,2));
            isTestRes=(maxeig(testEllipsoid1)==0)&&(maxeig(testEllipsoid2)==0);
            mlunit.assert_equals(true, isTestRes);
            
            %Check on diaganal matrix
            testEllipsoid=ellipsoid(diag(1:0.2:5.2));
            isTestRes=(maxeig(testEllipsoid)==5.2);
            mlunit.assert_equals(true, isTestRes);
            
            %Check on not diaganal matrix
            testEllipsoid=ellipsoid([1 1 -1; 1 4 -3; -1 -3 9]);
            isTestRes=( (maxeig(testEllipsoid)-max(eig([1 1 -1; 1 4 -3; -1 -3 9])))<=eps );
            mlunit.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(0.1:0.1:1.5)), ...
                ellipsoid(rand(20,1),diag(1:20))];
            testMaxEigVec = maxeig(testEllVec);
            isTestRes = all( testMaxEigVec == [12 1.5 20] );
            mlunit.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0:0.1:2).',diag(0:0.01:0.2)), ellipsoid(-10*ones(41,1),diag(20:10:420)), ellipsoid(rand(50,1),9*eye(50,50));
                         ellipsoid(5*eye(10,10)), ellipsoid(diag(0:0.0001:0.01)), ellipsoid(zeros(30,30))];
            testMaxEigMat = maxeig(testEllMat);
            isTestMat = (testMaxEigMat == [0.2 420 9; 5 0.01 0]);
            isTestRes = all( isTestMat(:));
            mlunit.assert_equals(true, isTestRes);
        end
        function self = testMinEig(self)
            %Check empty ellipsoid
            self.runAndCheckError('mineig(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            testEllipsoid1=ellipsoid([-2; -2], zeros(2,2));
            testEllipsoid2=ellipsoid(zeros(2,2));
            isTestRes=(mineig(testEllipsoid1)==0)&&(mineig(testEllipsoid2)==0);
            mlunit.assert_equals(true, isTestRes);
            
            %Check on diaganal matrix
            testEllipsoid=ellipsoid(diag(4:-0.2:1.2));
            isTestRes=(mineig(testEllipsoid)==1.2);
            mlunit.assert_equals(true, isTestRes);
            
            %Check on not diaganal matrix
            testEllipsoid=ellipsoid([1 1 -1; 1 4 -4; -1 -4 9]);
            isTestRes=( (mineig(testEllipsoid)-min(eig([1 1 -1; 1 4 -3; -1 -3 9])))<=eps );
            mlunit.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(0.1:0.1:1.5)), ...
                ellipsoid(rand(21,1),diag(0:20))];
            testMinEigVec = mineig(testEllVec);
            isTestRes = all( testMinEigVec == [1 0.1 0] );
            mlunit.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0.1:0.1:2).',diag(0.01:0.01:0.2)), ellipsoid(-10*ones(41,1),diag(20:10:420)), ellipsoid(rand(50,1),9*eye(50,50));
                         ellipsoid(repmat(diag(1:20),2,2)), ellipsoid(diag(0.0001:0.0001:0.01)), ellipsoid(zeros(30,30))];
            testMinEigMat = mineig(testEllMat);
            isTestMat = (testMinEigMat == [0.01 20 9; 0 0.0001 0]);
            isTestRes = all( isTestMat(:));
            mlunit.assert_equals(true, isTestRes);
        end
        function self = testTrace(self)
            %Empty ellipsoid
            self.runAndCheckError('trace(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Not empty ellipsoid
            testEllipsoid=ellipsoid(zeros(10,1),eye(10,10));
            isTestRes=trace(testEllipsoid)==10;
            mlunit.assert_equals(true, isTestRes);
            
            testEllipsoid=ellipsoid(-eye(3,1),[1 0 1; 0 0 0; 1 0 2 ]);
            isTestRes=trace(testEllipsoid)==3;
            mlunit.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids
            testEllVec = [ellipsoid(diag(1:12)), ellipsoid((0:0.1:1.4).',diag(0.1:0.1:1.5)), ...
                ellipsoid(rand(21,1),diag(0:20))];
            testTraceVec = trace(testEllVec);
            isTestRes = all( testTraceVec == [78 12 210] );
            mlunit.assert_equals(true, isTestRes);
            
            testEllMat= [ellipsoid((0.1:0.1:2).',diag(0.01:0.01:0.2)), ellipsoid(-10*ones(41,1),diag(20:10:420)),...
                ellipsoid(rand(50,1),9*eye(50,50));   ellipsoid(repmat(diag(1:20),2,2)),...
                ellipsoid(diag(0.0001:0.0001:0.01)), ellipsoid(zeros(30,30))];
            testTraceMat = trace(testEllMat);
            isTestMat = ( testTraceMat == [sum(0.01:0.01:0.2) sum(20:10:420) 9*50; 2*sum(1:20) sum(0.0001:0.0001:0.01) 0] );
            isTestRes = all( isTestMat(:));
            mlunit.assert_equals(true, isTestRes);
        end
        function self = testVolume(self)
            import elltool.conf.Properties;
            absTol = Properties.getAbsTol();
            %Check empty ellipsoid
            self.runAndCheckError('volume(ellipsoid)','wrongInput:emptyEllipsoid');
            
            %Check degenerate ellipsoid
            testEllipsoid=ellipsoid([1 0 0;0 1 0;0 0 0]);
            isTestRes=volume(testEllipsoid)==0;
            mlunit.assert_equals(true, isTestRes);
            
            %Check dim=1 with two different centers
            testEllipsoid1=ellipsoid(2,1);
            testEllipsoid2=ellipsoid(1);
            isTestRes=(volume(testEllipsoid1)==2)&&(volume(testEllipsoid2)==2);
            mlunit.assert_equals(true, isTestRes);
            
            %Check dim=2 with two different centers
            testEllipsoid1=ellipsoid([1; -1],eye(2,2));
            testEllipsoid2=ellipsoid(eye(2,2));
            isTestRes=( (volume(testEllipsoid1)-pi)<=absTol )&&( (volume(testEllipsoid2)-pi)<=absTol );
            mlunit.assert_equals(true, isTestRes);
            
            %Chek dim=3 with not diaganal matrix
            testEllipsoid=ellipsoid([1 1 -1; 1 4 -3; -1 -3 9]);
            isTestRes=( (volume(testEllipsoid)-(8*sqrt(5)*pi/3)<=absTol ) );
            mlunit.assert_equals(true, isTestRes);
            
            %Check dim=5
            testEllipsoid=ellipsoid(4*ones(5,1),eye(5,5));
            isTestRes=( (volume(testEllipsoid)-(256*pi*pi/15)<=absTol ) );
            mlunit.assert_equals(true, isTestRes);
            
            %Check dim=6
            testEllipsoid=ellipsoid(-ones(6,1),diag([1, 4, 9, 16,1, 25]));
            isTestRes=( (volume(testEllipsoid)-(20*pi*pi*pi)<=absTol ) );
            mlunit.assert_equals(true, isTestRes);
            
            %High-dimensional ellipsoids            
            testEllMat= [ellipsoid((0.1:0.1:2).',diag(0.01:0.01:0.2)), ellipsoid(-10*ones(13,1),diag(0.1:0.1:1.3));             
                         ellipsoid(rand(20,1),9*diag(0:19)), ellipsoid(diag(1:21));
                         ellipsoid(diag(0.1:0.1:10)), ellipsoid(diag(0:0.0001:0.01))];
            testVolMat = volume(testEllMat); 
            testRightVolMat = [(pi^6)*sqrt(prod(0.01:0.01:0.2))/prod(1:6), (pi^6)*(2^7)*sqrt(prod(0.1:0.1:1.3))/prod(1:2:13);
                               0,                                          (pi^10)*(2^11)*sqrt(prod(1:21))/prod(1:2:21);
                               (pi^50)*sqrt(prod(0.1:0.1:10))/prod(1:50), 0];
            
            isTestEqMat = (testVolMat-testRightVolMat)<=absTol;
            isTestRes = all(isTestEqMat(:));
            mlunit.assert_equals(true, isTestRes);
        end
        function self = disabletestMinkMP(self)
            import elltool.conf.Properties;
            absTol = Properties.getAbsTol();
            %1D case
            nDim=1;
            testEllipsoidMin=ellipsoid(2,4);
            testEllipsoidSub=ellipsoid(2,9);
            testEllipsoidSum1=ellipsoid(1,25);
            testEllipsoidSum2=ellipsoid(2,16);
            [testCenter testPointsVec]=minkmp(testEllipsoidMin,testEllipsoidSub,[testEllipsoidSum1,testEllipsoidSum2]);
            isTestRes = isempty(testCenter) && isempty(testPointsVec);
            mlunit.assert_equals(true, isTestRes);
            
            testEllipsoidMin=ellipsoid(2,4);
            testEllipsoidSub=ellipsoid(2,0);
            testEllipsoidSum=ellipsoid(1,0);
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                testEllipsoidSum, 1, 2, absTol);

            testEllipsoidMin=ellipsoid(4);
            testEllipsoidSub=ellipsoid(1);
            testEllipsoidSum=ellipsoid(0);
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                testEllipsoidSum, 0, 1, absTol);
            
            testEllipsoidMin=ellipsoid(4);
            testEllipsoidSub=ellipsoid(0);
            testEllipsoidSum=ellipsoid(0.25);
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                testEllipsoidSum, 0, 2.5, absTol);
            
            testEllipsoidMin=ellipsoid(1,4);
            testEllipsoidSub=ellipsoid(1,2.25);
            testEllipsoidSum1=ellipsoid(1,0);
            testEllipsoidSum2=ellipsoid(1,1);
            testEllipsoidSum3=ellipsoid(1,9);
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                [testEllipsoidSum1 testEllipsoidSum2 testEllipsoidSum3] , 3, 4.5,absTol);
            
            %2D case
            nDim=2;
            testEllipsoidMin=ellipsoid([2;2], 4*eye(2,2));
            testEllipsoidSub=ellipsoid([2;1], 16*eye(2,2));
            testEllipsoidSum1=ellipsoid([2;1], 25*eye(2,2));
            testEllipsoidSum2=ellipsoid([2;1], 36*eye(2,2));
            [testCenterVec testPointsMat]=minkmp(testEllipsoidMin,testEllipsoidSub,[testEllipsoidSum1, testEllipsoidSum2]);
            isTestRes = isempty(testCenterVec) && isempty( testPointsMat);
            mlunit.assert_equals(true, isTestRes);
            
            testEllipsoidMin=ellipsoid([2;2], 4*eye(2,2));
            testEllipsoidSub=ellipsoid([2;1], zeros(2,2));
            testEllipsoidSum=ellipsoid([2;1], zeros(2,2));
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                testEllipsoidSum, [2;2], 2,absTol);
            
            testEllipsoidMin=ellipsoid(4*eye(2,2));
            testEllipsoidSub=ellipsoid([1 0;0 0]);
            testEllipsoidSum=ellipsoid(zeros(2,2));
            [testCenterVec testPointsMat]=minkmp(testEllipsoidMin,testEllipsoidSub,testEllipsoidSum);
            testDistSqr1 = (testPointsMat(1,:)-1).*(testPointsMat(1,:)-1)+(testPointsMat(2,:)).*(testPointsMat(2,:));
            testDistSqr2 = (testPointsMat(1,:)+1).*(testPointsMat(1,:)+1)+(testPointsMat(2,:)).*(testPointsMat(2,:));
            isTestRes = all( testCenterVec==0 ) && all( (abs(testDistSqr1 - 4) <= 0.000001) | (abs(testDistSqr2 - 4) <= 0.000001) );
            mlunit.assert_equals(true, isTestRes);
            
            testEllipsoidMin=ellipsoid([4 0; 0 9]);
            testEllipsoidSub=ellipsoid(4*eye(2,2));
            testEllipsoidSum1=ellipsoid([1;0],eye(2,2));
            testEllipsoidSum2=ellipsoid([0;1],eye(2,2));
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                [testEllipsoidSum1, testEllipsoidSum2], [1;1], 2,absTol);
             
            testEllipsoidMin=ellipsoid([2;2], 4*eye(2,2));
            testEllipsoidSub=ellipsoid([2;1], eye(2,2));
            testEllipsoidSum1=ellipsoid([1;1], eye(2,2));
            testEllipsoidSum2=ellipsoid([1;0], 9*eye(2,2));
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
            [testEllipsoidSum1 testEllipsoidSum2], [2;2], 5,absTol);
            
            %3D case
            nDim=3;
            testEllipsoidMin=ellipsoid(eye(3,3));
            testEllipsoidSub=ellipsoid(2.25*eye(3,3));
            testEllipsoidSum1=ellipsoid([1;0;0], 25*eye(3,3));
            testEllipsoidSum2=ellipsoid([0;1;0], 36*eye(3,3));
            [testCenterVec testPointsMat]=minkmp(testEllipsoidMin,testEllipsoidSub,[testEllipsoidSum1, testEllipsoidSum2]);
            isTestRes = isempty(testCenterVec) && isempty( testPointsMat);
            mlunit.assert_equals(true, isTestRes);
            
            testEllipsoidMin=ellipsoid([1;1;1], diag([1,4,9]));
            testEllipsoidSub=ellipsoid([2;1;-1], zeros(3,3));
            testEllipsoidSum=ellipsoid([2;1;-1], zeros(3,3));
            [testCenterVec testPointsMat]=minkmp(testEllipsoidMin,testEllipsoidSub,testEllipsoidSum);
            testDistSqr = (testPointsMat(1,:)-testCenterVec(1)).*(testPointsMat(1,:)-testCenterVec(1)) +...
                (testPointsMat(2,:)-testCenterVec(2)).*(testPointsMat(2,:)-testCenterVec(2))/4+...
                (testPointsMat(3,:)-testCenterVec(3)).*(testPointsMat(3,:)-testCenterVec(3))/9;
            isTestRes = all( testCenterVec==1 ) && all( abs(testDistSqr - 1) <= absTol );
            mlunit.assert_equals(true, isTestRes);
            
            testEllipsoidMin=ellipsoid([1;1;1], 25*eye(3,3));
            testEllipsoidSub=ellipsoid([1;0;1], 4*eye(3,3));
            testEllipsoidSum=ellipsoid([0;-1;0], eye(3,3));
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                testEllipsoidSum, [0;0;0], 4,absTol);
            
            
            testEllipsoidMin=ellipsoid(diag([25,4,9]));
            testEllipsoidSub=ellipsoid(4*eye(3,3));
            testEllipsoidSum1=ellipsoid([1;0;-1], eye(3,3));
            testEllipsoidSum2=ellipsoid([0;1;2], eye(3,3));
            testEllipsoidSum3=ellipsoid(eye(3,3));
            fCheckBallsForTestMinkMP(nDim,testEllipsoidMin,testEllipsoidSub,...
                [testEllipsoidSum1 testEllipsoidSum2 testEllipsoidSum3], [1;1;1], 3, absTol);
        end
    end
end

function fCheckForTestEllipsoidAndDouble(qCenterVec, qShapeMat)
    if nargin < 2
        qShapeMat = qCenterVec;
        qCenterVec = zeros(size(qShapeMat,1),1);
        testEllipsoid=ellipsoid(qShapeMat);
    else
        testEllipsoid=ellipsoid(qCenterVec,qShapeMat);
    end
	[testCenterVec, testShapeMat]=double(testEllipsoid);
    try
    isTestCVec  = testCenterVec == qCenterVec;
	isTestEyeMat = testShapeMat == qShapeMat;
    catch
        isTestRes = false;
    end
	isTestRes = all(isTestCVec(:)) && all(isTestEyeMat(:));
	mlunit.assert_equals(true, isTestRes);    
end

function fCheckForTestParameters(qCenterVec, qShapeMat)
    if nargin < 2
        qShapeMat = qCenterVec;
        qCenterVec = zeros(size(qShapeMat,1),1);
        testEllipsoid=ellipsoid(qShapeMat);
    else
        testEllipsoid=ellipsoid(qCenterVec,qShapeMat);
    end
	[testCenterVec, testShapeMat]=parameters(testEllipsoid);
    try
    isTestCVec  = testCenterVec == qCenterVec;
	isTestEyeMat = testShapeMat == qShapeMat;
    catch
        isTestRes = false;
    end
	isTestRes = all(isTestCVec(:)) && all(isTestEyeMat(:));
	mlunit.assert_equals(true, isTestRes);    
end

function fCheckBallsForTestMinkMP(nDim,minEll,subEll,sumEllMat,centerVec,rad, tol)
    [testCenterVec testPointsMat]=minkmp(minEll,subEll,sumEllMat);
    switch nDim
        case 1
            isTestRes = (testCenterVec==centerVec) && all( (abs(testPointsMat-centerVec)-rad) <= tol);
        case 2
            testDistSqr = (testPointsMat(1,:)-centerVec(1)).*(testPointsMat(1,:)-centerVec(1))...
                +(testPointsMat(2,:)-centerVec(2)).*(testPointsMat(2,:)-centerVec(2));
            isTestRes = all( testCenterVec==centerVec ) && all( abs(testDistSqr - rad*rad) <= tol );
        case 3
            testDistSqr = (testPointsMat(1,:)-centerVec(1)).*(testPointsMat(1,:)-centerVec(1)) +...
                (testPointsMat(2,:)-centerVec(2)).*(testPointsMat(2,:)-centerVec(2))+...
                (testPointsMat(3,:)-centerVec(3)).*(testPointsMat(3,:)-centerVec(3));
            isTestRes = all( testCenterVec==centerVec ) && all( abs(testDistSqr - rad*rad) <= tol );
    end
    mlunit.assert(isTestRes);
end