classdef GenEllipsoidSpecialTC < mlunitext.test_case
    %$Author: Egor Grachev <egorgrachev.msu@gmail.com>$
    %$Date: 2013-12-5 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department 2013 $
    properties (Access=private)
        testDataRootDir
    end
    properties
        ellFactoryObj
    end
    
    methods
        function self = GenEllipsoidSpecialTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,...
                'TestData',...
                filesep,shortClassName];          
        end
        function self = set_up_param(self, ellFactoryObj)
            self.ellFactoryObj = ellFactoryObj;
        end
        function setUpCheckSettings(self)
            import elltool.conf.Properties;
            Properties.checkSettings();
        end;
        function flexAssert(varargin)
            IS_ASSERTION_ON = true;
            if (IS_ASSERTION_ON)
                mlunitext.assert_equals(varargin{2:end});
            end;
        end;
        
        function self = testSqrtm(self)
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 1.01*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = isEqual(self.ellFactoryObj.create(test1Mat), self.ellFactoryObj.create(test2Mat));
            mlunitext.assert_equals(false, isEq);
            ansStr = ...
                '\(1).Q-->.*\(1.010000e\-05).*tolerance.\(1.000000e\-05)';
            checkRep();
            %            
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 0.5*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = isEqual(self.ellFactoryObj.create(test1Mat),...
                self.ellFactoryObj.create(test2Mat));
            mlunitext.assert_equals(true, isEq);
            ansStr = '';
            checkRep();
            %
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = isEqual(self.ellFactoryObj.create(test1Mat),...
                self.ellFactoryObj.create(test2Mat));
            mlunitext.assert_equals(false, isEq);
            mlunitext.assert_equals(false, isEq);
            ansStr = ...
                '\(1).Q-->.*\(1.000000e\-05).*tolerance.\(1.000000e\-05)';
            checkRep();
            function checkRep()
                isRepEq = isequal(reportStr, ansStr);
                if ~isRepEq
                    isRepEq = ~isempty(regexp(reportStr, ansStr, 'once'));
                end
                mlunitext.assert_equals(isRepEq, true);
            end
        end
        
        function self = testToStruct(self)
            centerCVec{1} = [1 2 3];
            shapeMatCVec{1} = eye(3);
            centerCVec{2} = [2 3 4];
            shapeMatCVec{2} = ones(3);
            centerCVec{3} = [1 0];
            shapeMatCVec{3} = [3 1; 1 2];
            centerCVec{4} = [1 0 0 0];
            shapeMatCVec{4} = diag([3 2 1 0]);
            for iElem = 1 : 4
                ellVec(iElem) = self.ellFactoryObj.create(centerCVec{iElem}', shapeMatCVec{iElem});
                transposedCenterCVec{iElem} = centerCVec{iElem}';
            end
            SEllVec = struct('centerVec', transposedCenterCVec, 'shapeMat', shapeMatCVec);
            ObtainedEllStruct = ellVec(1).toStruct();
            isOk = isequal(ObtainedEllStruct, SEllVec(1));
            ObtainedEllStructVec = ellVec.toStruct();
            isOk = isOk && isequal(ObtainedEllStructVec, SEllVec);
            mlunitext.assert_equals(true, isOk);
        end

        function self = testEq(self)
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            
            testMat = eye(2);
            self.checkEllEqual(self.ellFactoryObj.create(testMat), self.ellFactoryObj.create(testMat), true, '');
            
            test1Mat = eye(2);
            test2Mat = eye(2) + MAX_TOL;
            self.checkEllEqual(self.ellFactoryObj.create(test1Mat), self.ellFactoryObj.create(test2Mat), true, '');
            
            test1Mat = eye(2);
            test2Mat = eye(2) - 0.99*MAX_TOL;
            self.checkEllEqual(self.ellFactoryObj.create(test1Mat), self.ellFactoryObj.create(test2Mat), true, '');
            
            test1Mat = 100*eye(2);
            test2Mat = 100*eye(2) - 0.99*MAX_TOL;
            self.checkEllEqual(self.ellFactoryObj.create(test1Mat), self.ellFactoryObj.create(test2Mat), true, '');
            %
            %test for maxTolerance
            firstMat = eye(2);
            secMat = eye(2)+1;
            secVec = [1;0];
            maxTol = 1;
            ell1 = self.ellFactoryObj.create(firstMat);
            ell2 = self.ellFactoryObj.create(secVec,secMat);
            [isOk,reportStr]=ell1.isEqual(ell2);
            mlunitext.assert(~isOk,reportStr);
            %
            %
            testEll = self.ellFactoryObj.create(eye(2));
            testEll2 = self.ellFactoryObj.create([1e-3, 0].', eye(2));
            mDim = 10;
            nDim = 15;
            testEllArr = repmat(testEll, mDim, nDim);
            isEqualArr = true(mDim, nDim);
            isnEqualArr = ~isEqualArr;
            mlunitext.assert_equals(isEqualArr, testEll.eq(testEllArr));
            mlunitext.assert_equals(isEqualArr, testEllArr.eq(testEll));
            mlunitext.assert_equals(isnEqualArr, testEll2.eq(testEllArr));
            mlunitext.assert_equals(isnEqualArr, testEllArr.eq(testEll2));
            
            testEll2Arr = repmat(testEll2, mDim, nDim);
            mlunitext.assert_equals(isEqualArr, testEllArr.eq(testEllArr));
            mlunitext.assert_equals(isnEqualArr, testEll2Arr.eq(testEllArr));
            
            self.runAndCheckError...
                ('eq([testEll, testEll2], [testEll; testEll2])','wrongSizes');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidZeros2 ...
                testEllipsoidZeros3 testEllipsoidEmpty] = self.createTypicalEll(1);
            [testEllHighDim1 testEllHighDim2] = self.createTypicalHighDimEll(1);
            
            
            self.checkEllEqual(testEllHighDim1, testEllHighDim1, true, '');
            
            self.checkEllEqual(testEllHighDim1, testEllHighDim2, false, ...
                '\(1).Q-->.*\(2.316625e\+00).*tolerance.\(1.000000e\-05)');
            
            [testEllHighDim1 testEllHighDim2] = self.createTypicalHighDimEll(2);
            self.checkEllEqual(testEllHighDim1, testEllHighDim1, true, '');
            
            
            self.checkEllEqual(testEllHighDim1, testEllHighDim2, false, ...
                '\(1).Q-->.*\(2.316625e\+00).*tolerance.\(1.000000e\-05)');
            
            [testEllHighDim1 testEllHighDim2] = self.createTypicalHighDimEll(3);
            self.checkEllEqual(testEllHighDim1, testEllHighDim1, true, '');
            
            self.checkEllEqual(testEllHighDim1, testEllHighDim2, false, ...
                '\(1).Q-->.*\(2.316625e\+00).*tolerance.\(1.000000e\-05)');
            
            
            self.checkEllEqual(testEllipsoid1, testEllipsoid1, true, '');
            
            self.checkEllEqual(testEllipsoid2, testEllipsoid1, false, ...
                '\(1).q-->.*\(1.000000e\+00).*tolerance.\(1.000000e\-05)');
            
            self.checkEllEqual(testEllipsoid3, testEllipsoid2, false, ...
                '\(1).Q-->.*\(4.142136e\-01).*tolerance.\(1.000000e\-05)');
            
            
            self.checkEllEqual(testEllipsoid3, testEllipsoid2, false, ...
                '\(1).Q-->.*\(4.142136e\-01).*tolerance.\(1.000000e\-05)');
            
            ansStr = sprintf('(1).Q-->Different sizes (left: [2 2], right: [3 3])\n(1).q-->Different sizes (left: [2 1], right: [3 1])');
            self.checkEllEqual(testEllipsoidZeros2, testEllipsoidZeros3, false, ansStr);
            
            
            ansStr = sprintf('(1).Q-->Different sizes (left: [2 2], right: [0 0])\n(1).q-->Different sizes (left: [2 1], right: [0 0])');
            self.checkEllEqual(testEllipsoidZeros2, testEllipsoidEmpty, false, ansStr);
            
            
            self.checkEllEqual(testEllipsoidEmpty, testEllipsoidEmpty, true, '');
            
            testNotEllipsoid = [];
            %'==: both arguments must be ellipsoids.'
            self.runAndCheckError('eq(testEllipsoidEmpty, testNotEllipsoid)','wrongInput:emptyArray');
            
            %'==: sizes of ellipsoidal arrays do not match.'
            self.runAndCheckError('eq([testEllipsoidEmpty testEllipsoidEmpty], [testEllipsoidEmpty; testEllipsoidEmpty])','wrongSizes');
            
            
            
            ansStr = sprintf('(1).Q-->Different sizes (left: [2 2], right: [3 3])\n(1).q-->Different sizes (left: [2 1], right: [3 1])');
            self.checkEllEqual([testEllipsoidZeros2 testEllipsoidZeros3], [testEllipsoidZeros3 testEllipsoidZeros3], [false, true], ansStr);
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
            testEllipsoid = self.ellFactoryObj.create([1,0,0;0,5,0;0,0,10]);
            testPointMat = [3,0,0; 5,0,0].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunitext.assert_equals(true, (abs(testResVec(1)-2)<absTol) &&...
                (abs(testResVec(2)-4)<absTol));
            %
            %distance between ellipsoid and point in the ellipsoid
            %and point on the boader of the ellipsoid
            testEllipsoid = self.ellFactoryObj.create([1,2,3].',4*eye(3,3));
            testPointMat = [2,3,2; 1,2,5].';
            testResVec = distance(testEllipsoid, testPointMat);
            mlunitext.assert_equals(true, testResVec(1)==-1 && testResVec(2)==0);
            %
            %distance between two ellipsoids and two vectors
            testEllipsoidVec = [self.ellFactoryObj.create([5,2,0;2,5,0;0,0,1]),...
                self.ellFactoryObj.create([0,0,5].',[4, 0, 0; 0, 9 , 0; 0,0, 25])];
            testPointMat = [0,0,5; 0,5,5].';
            testResVec = distance(testEllipsoidVec, testPointMat);
            mlunitext.assert_equals(true, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %distance between two ellipsoids and a vector
            testEllipsoidVec = [self.ellFactoryObj.create([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                self.ellFactoryObj.create([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            testResVec = distance(testEllipsoidVec, testPointVec);
            mlunitext.assert_equals(true, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-1)<absTol));
            %
            %negative test: matrix shapeMat of ellipsoid has very large
            %eigenvalues.
            testEllipsoid = self.ellFactoryObj.create([1e+15,0;0,1e+15]);
            testPointVec = [3e+15,0].';
            self.runAndCheckError('distance(testEllipsoid, testPointVec)',...
                'notSecant');
            %
            %random ellipsoid matrix, low dimension case
            nDim=2;
            testEllMat=diag(1:2);
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=self.ellFactoryObj.create(testEllMat);
            testPoint=testOrth2Mat*[10;zeros(nDim-1,1)];
            testRes=distance(testEllipsoid, testPoint);
            mlunitext.assert_equals(true,abs(testRes-9)<absTol);
            %
            %high dimensional tests with rotated ellipsoids
            nDim=50;
            testEllMat=diag(nDim:-1:1);
            testEllMat=testOrth50Mat*testEllMat*testOrth50Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=self.ellFactoryObj.create(testEllMat);
            testPoint=testOrth50Mat*[zeros(nDim-1,1);10];
            testRes=distance(testEllipsoid, testPoint);
            mlunitext.assert_equals(true,abs(testRes-9)<absTol);
            
            %distance between two ellipsoids with random matrices and two vectors
            testEll1Mat=[5,2,0;2,5,0;0,0,1];
            testEll1Mat=testOrth3Mat*testEll1Mat*testOrth3Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=[4,0,0;0,9,0;0,0,25];
            testEll2Mat=testOrth3Mat*testEll2Mat*testOrth3Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth3Mat*[0;0;5];
            testEllipsoidVec = [self.ellFactoryObj.create(testEll1Mat),...
                self.ellFactoryObj.create(testEll2CenterVec,testEll2Mat)];
            testPointMat = testOrth3Mat*([0,0,5; 0,5,5].');
            testResVec = distance(testEllipsoidVec, testPointMat);
            mlunitext.assert_equals(true, (abs(testResVec(1)-4)<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %
            %
            %
            %Testing ellipsoid-ellipsoid distance
            %
            %distance between two ellipsoids
            testEllipsoid1 = self.ellFactoryObj.create([25,0;0,9]);
            testEllipsoid2 = self.ellFactoryObj.create([10;0],[4,0;0,9]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true, (abs(testRes-3)<absTol));
            %
            testEllipsoid1 = self.ellFactoryObj.create([0,-15,0].',[25,0,0;0,100,0;0,0,9]);
            testEllipsoid2 = self.ellFactoryObj.create([0,7,0].',[9,0,0;0,25,0;0,0,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true, (abs(testRes-7)<absTol));
            %
            % case of ellipses with common center
            testEllipsoid1 = self.ellFactoryObj.create([1 2 3].',[1,2,5;2,5,3;5,3,100]);
            testEllipsoid2 = self.ellFactoryObj.create([1,2,3].',[1,2,7;2,10,5;7,5,100]);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true, (abs(testRes)<absTol));
            %
            % distance between two pairs of ellipsoids
            testEllipsoid1Vec=[self.ellFactoryObj.create([0, -6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                self.ellFactoryObj.create([0,0,-4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testEllipsoid2Vec=[self.ellFactoryObj.create([0, 6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                self.ellFactoryObj.create([0,0,4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunitext.assert_equals(true, (abs(testResVec(1)-8)<absTol) &&...
                (abs(testResVec(2)-5)<absTol));
            %
            % distance between two ellipsoids and an ellipsoid
            testEllipsoidVec=[self.ellFactoryObj.create([0, 0, 0].',[9,0,0; 0,25,0; 0,0, 1]),...
                self.ellFactoryObj.create([-5,0,0].',[9,0,0; 0, 25,0; 0,0,1])];
            testEllipsoid=self.ellFactoryObj.create([5, 0, 0].',[25,0,0; 0,100,0; 0,0, 1]);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunitext.assert_equals(true, (abs(testResVec(1))<absTol) &&...
                (abs(testResVec(2)-2)<absTol));
            %
            %distance between two ellipsoids of high dimensions
            nDim=100;
            testEllipsoid1=self.ellFactoryObj.create(diag(1:2:2*nDim));
            testEllipsoid2=self.ellFactoryObj.create([5;zeros(nDim-1,1)],diag(1:nDim));
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true,abs(testRes-3)<absTol);
            %
            %distance between two vectors of ellipsoids of rather high
            %dimension (12<=nDim<=26) with matrices that have nonzero non
            %diagonal elements
%             load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
%                 'testEllipsoid1Vec','testEllipsoid2Vec','testAnswVec','nEllVec');
            load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
                'testEllipsoid1Struct','testEllipsoid2Struct','testAnswVec','nEllVec');
            testEllipsoid1Vec = self.ellFactoryObj.create.fromStruct(testEllipsoid1Struct);
            testEllipsoid2Vec = self.ellFactoryObj.create.fromStruct(testEllipsoid2Struct);
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec);
            mlunitext.assert_equals(ones(1,nEllVec),...
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
            testEllipsoidVec=[self.ellFactoryObj.create(testEll1Mat),...
                self.ellFactoryObj.create(testEll2CenterVec,testEll2Mat)];
            testEllipsoid=self.ellFactoryObj.create(testEll3CenterVec,testEll3Mat);
            testResVec=distance(testEllipsoidVec,testEllipsoid);
            mlunitext.assert_equals(true, (abs(testResVec(1))<absTol) &&...
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
            testEllipsoid1=self.ellFactoryObj.create(testEll1Mat);
            testEllipsoid2=self.ellFactoryObj.create(testEll2CenterVec,testEll2Mat);
            testRes=distance(testEllipsoid1,testEllipsoid2);
            mlunitext.assert_equals(true,abs(testRes-3)<absTol);
            %
            %
            %
            %
            % distance between single ellipsoid and array of ellipsoids
%             load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
%                 'testEllArr','testDistResArr');
            load(strcat(self.testDataRootDir,filesep,'testEllEllDist.mat'),...
                'testEllStruct','testDistResArr');
            testEllArr = self.ellFactoryObj.create.fromStruct(testEllStruct);
            testEll = self.ellFactoryObj.create(eye(2));
            resArr = distance(testEll, testEllArr);
            isOkArr = abs(resArr - testDistResArr) <= elltool.conf.Properties.getAbsTol();
            mlunitext.assert(all(isOkArr(:)));
            %distance between an ellipsoid (with nonzeros nondiagonal elements)
            %and a hyperplane in 2 dimensions
            testEllMat=[9 0; 0 4];
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllCenterVec=testOrth2Mat*[0;5];
            testHypVVec=testOrth2Mat*[0;1];
            testHypC=0;
            testEllipsoid=self.ellFactoryObj.create(testEllCenterVec,testEllMat);
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunitext.assert_equals(true,abs(testRes-3)<absTol);
            %
            %distance between an ellipsoid (with nonzero nondiagonal elements)
            %and a hyperplane in 3 dimensions
            testEllMat=[100,0,0;0,25,0;0,0,9];
            testEllMat=testOrth3Mat*testEllMat*testOrth3Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testHypVVec=testOrth3Mat*[0;1;0];
            testHypC=10;
            testEllipsoid=self.ellFactoryObj.create(testEllMat);
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunitext.assert_equals(true,abs(testRes-5)<absTol);
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
            testEllipsoid=[self.ellFactoryObj.create(testEll1CenterVec,testEll1Mat),...
                self.ellFactoryObj.create(testEll2CenterVec,testEll2Mat)];
            testHyp=hyperplane(testHypVVec,testHypC);
            testRes=distance(testEllipsoid,testHyp);
            mlunitext.assert_equals(true,abs(testRes(1)-7)<absTol&&...
                abs(testRes(2)-5)<absTol);
            %distance where two ellipsoids have one common point
            % according to existing precision policy elltool.conf.Properties.getAbsTol()
            testEll1=self.ellFactoryObj.create([1+1e-20 0].',[1 0; 0 1]);
            testEll2=self.ellFactoryObj.create([-1 0].',[1 0;0 1]);
            testRes=distance(testEll1,testEll2);
            mlunitext.assert_equals(true,abs(testRes)<elltool.conf.Properties.getAbsTol());
            %negative test: ellipsoid and hyperplane have different dimensions
            testEll = self.ellFactoryObj.create(eye(2));
            testHyp = hyperplane(eye(3));
            self.runAndCheckError('distance(testEll, testHyp)',...
                'wrongInput');
            %
            %
            %DISTANCE FROM VECTOR TO ELLIPSOID
            %IN ELLIPSOID METRIC
            %
            % Test#1. Distance between an ellipsoid and a vector.
            testEllipsoid = self.ellFactoryObj.create([1,0,0;0,5,0;0,0,10]);
            testPointVec = [3,0,0].';
            %
            testRes = distance(testEllipsoid, testPointVec,true);
            ansRes = self.ellVecDistanceCVX(testEllipsoid, testPointVec,true);
            mlunitext.assert_equals(true, (abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol()));
            %
            % Test#2. Distance between an ellipsoid and a vector.
            testEllipsoid = self.ellFactoryObj.create([2,0,0;0,5,0;0,0,10]);
            testPointVec = [3,0,0].';
            %
            testRes = distance(testEllipsoid, testPointVec,true);
            ansRes = self.ellVecDistanceCVX(testEllipsoid, testPointVec,true);
            mlunitext.assert_equals(true, (abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol()));
            %
            %Test#3
            % Distance between two ellipsoids and a vector
            testEllipsoidVec = [self.ellFactoryObj.create([5,5,0].',[1,0,0;0,5,0;0,0,10]),...
                self.ellFactoryObj.create([0,10,0].',[10, 0, 0; 0, 16 , 0; 0,0, 5])];
            testPointVec = [0,5,0].';
            %
            testResVec = distance(testEllipsoidVec, testPointVec,true);
            ansResVec(1)=self.ellVecDistanceCVX(testEllipsoidVec(1), testPointVec,true);
            ansResVec(2)=self.ellVecDistanceCVX(testEllipsoidVec(2), testPointVec,true);
            mlunitext.assert_equals(true, (abs(testResVec(1)-ansResVec(1))<elltool.conf.Properties.getAbsTol()) &&...
                (abs(testResVec(2)-ansResVec(2))<elltool.conf.Properties.getAbsTol()));
            %
            %Test#4.
            % Random ellipsoid matrix, low dimension case.
            nDim=2;
            testEllMat=diag(1:2);
            testEllMat=testOrth2Mat*testEllMat*testOrth2Mat.';
            testEllMat=0.5*(testEllMat+testEllMat.');
            testEllipsoid=self.ellFactoryObj.create(testEllMat);
            testPointVec=testOrth2Mat*[10;zeros(nDim-1,1)];
            %
            testRes=distance(testEllipsoid, testPointVec,true);
            ansRes = self.ellVecDistanceCVX(testEllipsoid, testPointVec,true);
            mlunitext.assert_equals(true,abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol());
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
            testEllipsoid1=self.ellFactoryObj.create(testEll1Mat);
            testEllipsoid2=self.ellFactoryObj.create(testEll2CenterVec,testEll2Mat);
            testEllipsoidVec = [testEllipsoid1,testEllipsoid2];
            testPointMat = testOrth3Mat*([0,0,5; 0,5,5].');
            %
            testResVec = distance(testEllipsoidVec, testPointMat,true);
            ansResVec(1)=distance(testEllipsoid1,testPointMat(:,1),true);
            ansResVec(2)=distance(testEllipsoid2,testPointMat(:,2),true);
            mlunitext.assert_equals(true, all(abs(testResVec-ansResVec)<...
                elltool.conf.Properties.getAbsTol()));
            %
            %DISTANCE FROM ELLIPSOID TO ELLIPSOID
            %IN ELLIPSOIDAL METRIC
            %
            % Test#1.
            % Distance between two ellipsoids
            testEllipsoid1 = self.ellFactoryObj.create([25,0;0,9]);
            testEllipsoid2 = self.ellFactoryObj.create([10;0],[4,0;0,9]);
            testRes=distance(testEllipsoid1,testEllipsoid2,true);
            ansRes=self.ellEllDistanceCVX(testEllipsoid1,testEllipsoid2,true);
            mlunitext.assert_equals(true, (abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol()));
            %
            % Test#2.
            % Distance between two ellipsoids of high dimensions and random
            % matrices
            nDim=100;
            testEll1Mat=diag(1:2:2*nDim);
            testEll1Mat=testOrth100Mat*testEll1Mat*testOrth100Mat.';
            testEll1Mat=0.5*(testEll1Mat+testEll1Mat.');
            testEll2Mat=diag([25;(1:(nDim-1)).']);
            testEll2Mat=testOrth100Mat*testEll2Mat*testOrth100Mat.';
            testEll2Mat=0.5*(testEll2Mat+testEll2Mat.');
            testEll2CenterVec=testOrth100Mat*[9;zeros(nDim-1,1)];
            testEllipsoid1=self.ellFactoryObj.create(testEll1Mat);
            testEllipsoid2=self.ellFactoryObj.create(testEll2CenterVec,testEll2Mat);
            %
            testRes=distance(testEllipsoid1,testEllipsoid2,true);
            ansRes=self.ellEllDistanceCVX(testEllipsoid1,testEllipsoid2,true);
            mlunitext.assert_equals(true,abs(testRes-ansRes)<elltool.conf.Properties.getAbsTol());
            %
            % Test#3.
            % Distance between two ellipsoids and an ellipsoid (of 3-dimension),
            % all matrices with nonzero nondiagonal elements
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
            testEllipsoidVec=[self.ellFactoryObj.create(testEll1Mat),...
                self.ellFactoryObj.create(testEll2CenterVec,testEll2Mat)];
            testEllipsoid=self.ellFactoryObj.create(testEll3CenterVec,testEll3Mat);
            %
            testResVec=distance(testEllipsoidVec,testEllipsoid,true);
            ansResVec(1)=distance(testEllipsoidVec(1),testEllipsoid,true);
            ansResVec(2)=distance(testEllipsoidVec(2),testEllipsoid,true);
            mlunitext.assert_equals(true, all(abs(testResVec-ansResVec)<...
                elltool.conf.Properties.getAbsTol()));
            %
            % Test #4.
            % distance between two pairs of ellipsoids
            testEllipsoid1Vec=[self.ellFactoryObj.create([0, -6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                self.ellFactoryObj.create([0,0,-4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            testEllipsoid2Vec=[self.ellFactoryObj.create([0, 6, 0].',[100,0,0; 0,4,0; 0,0, 25]),...
                self.ellFactoryObj.create([0,0,4.5].',[100,0,0; 0, 25,0; 0,0,4])];
            %
            testResVec=distance(testEllipsoid1Vec,testEllipsoid2Vec,true);
            ansResVec(1)=distance(testEllipsoid1Vec(1),testEllipsoid2Vec(1),true);
            ansResVec(2)=distance(testEllipsoid1Vec(2),testEllipsoid2Vec(2),true);
            mlunitext.assert_equals(true, all(abs(testResVec-ansResVec)<...
                elltool.conf.Properties.getAbsTol()));
        end
        
        function checkEllEqual(self, testEll1Vec, testEll2Vec, isEqRight, ansStr)
            [isEq, reportStr] = isEqual(testEll1Vec, testEll2Vec);
            mlunitext.assert_equals(isEq, isEqRight, reportStr);
            isRepEq = isequal(reportStr, ansStr);
            if ~isRepEq
                isRepEq = ~isempty(regexp(reportStr, ansStr, 'once'));
            end
            mlunitext.assert_equals(isRepEq, true);
        end
        
        function [varargout] = createTypicalEll(self, flag)
            switch flag
            case 1
                varargout{1} = self.ellFactoryObj.create([0; 0], [1 0; 0 1]);
                varargout{2} = self.ellFactoryObj.create([1; 0], [1 0; 0 1]);
                varargout{3} = self.ellFactoryObj.create([1; 0], [2 0; 0 1]);
                varargout{4} = self.ellFactoryObj.create([0; 0], [0 0; 0 0]);
                varargout{5} = self.ellFactoryObj.create([0; 0; 0], [0 0 0 ;0 0 0; 0 0 0]);
                varargout{6} = self.ellFactoryObj.create;
                varargout{7} = self.ellFactoryObj.create([2; 1], [3 1; 1 1]);
                varargout{8} = self.ellFactoryObj.create([1; 1], [1 0; 0 1]);
            case 2
                varargout{1} = self.ellFactoryObj.create([0; 0], [1 0; 0 1]);
                varargout{2} = self.ellFactoryObj.create([0; 0], [2 0; 0 2]);
                varargout{3} = self.ellFactoryObj.create([0; 0], [4 2; 2 4]);
                varargout{4} = self.ellFactoryObj.create;
                otherwise
            end
        end
        
        function [varargout] = createTypicalHighDimEll(self, flag)
            switch flag
                case 1
                    varargout{1} = self.ellFactoryObj.create(diag(1:0.5:6.5));
                    varargout{2} = self.ellFactoryObj.create(diag(11:0.5:16.5));
                case 2
                    varargout{1} = self.ellFactoryObj.create(diag(1:0.5:10.5));
                    varargout{2} = self.ellFactoryObj.create(diag(11:0.5:20.5));
                case 3
                    varargout{1} = self.ellFactoryObj.create(diag(1:0.1:10.9));
                    varargout{2} = self.ellFactoryObj.create(diag(11:0.1:20.9));
                case 4
                    varargout{1} = diag(1:0.5:6.5);
                    varargout{2} = diag(11:0.5:16.5);
                case 5
                    varargout{1} = diag(1:0.5:10.5);
                    varargout{2} = diag(11:0.5:20.5);
                case 6
                    varargout{1} = diag(1:0.1:10.9);
                    varargout{2} = diag(11:0.1:20.9);
                otherwise
            end
        end
    end
end