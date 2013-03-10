classdef BasicTestCase < mlunitext.test_case
    % $Author: Vadim Kaushanskiy, Moscow State University by M.V. Lomonosov,
    % Faculty of Computational Mathematics and Cybernetics, System Analysis
    % Department, 1-November-2012, <vkaushanskiy@gmail.com>$
    properties (Access=private)
        testDataRootDir
    end
    
    methods
        function self = BasicTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
            
        end
        
        function self = testSqrtM(self)
            import gras.la.sqrtm;
            MAX_TOL = 1e-6;
            nDim = 1000;
            testMat = eye(nDim);
            sqrtMat = sqrtm(testMat);
            mlunit.assert_equals(testMat, sqrtMat);
            
            nDim = 1000;
            testMat = diag(1:nDim);
            sqrtMat = sqrtm(testMat);
            mlunit.assert_equals(sqrt(testMat), sqrtMat);
            
            nDim = 2;
            testMat = [2, 1; 1, 2];
            vMat = [-1/sqrt(2), 1/sqrt(2); 1/sqrt(2), 1/sqrt(2)];
            dMat = diag([1, sqrt(3)]);
            sqrtTestMat = vMat*dMat*vMat';
            sqrtMat = sqrtm(testMat);
            mlunit.assert_equals(sqrtTestMat, sqrtMat);
            
            nDim = 3;
            testMat = [5, -4, 1; -4, 6, -4; 1, -4, 5];
            sqrtTestMat = [2, -1, 0; -1, 2, -1; 0, -1, 2];
            sqrtMat = sqrtm(testMat);
            mlunit.assert(norm(sqrtm(sqrtTestMat)-sqrtm(sqrtMat)) < MAX_TOL);
            
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testSqrtm1_inp.mat')), 'testMat');
            sqrtMat = sqrtm(testMat);
            mlunit.assert(norm(sqrtm(testMat)-sqrtm(sqrtMat*sqrtMat'))<MAX_TOL);
            
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testSqrtm2_inp.mat')), 'testMat');
            sqrtMat = sqrtm(testMat);
            mlunit.assert(norm(sqrtm(testMat)-sqrtm(sqrtMat*sqrtMat')) < MAX_TOL);
            
            
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 1.01*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            mlunit.assert(norm(sqrtm(test1Mat) - sqrtm(test2Mat)) > MAX_TOL);
            
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 0.5*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            mlunit.assert(norm(sqrtm(test1Mat) - sqrtm(test2Mat)) < MAX_TOL);
            
        end
        
        function self = testIsMatSymm(self)
            import gras.la.ismatsymm;
            
            %scalar
            mlunit.assert( ismatsymm(2) );
            
            %diag matrix
            mlunit.assert( ismatsymm(diag(1:5)) );
            
            %nDim = 20, 100
            testAMat = rand(20,20);
            mlunit.assert( ismatsymm(testAMat*(testAMat')) );
            
            testAMat = 10*rand(100,100);
            mlunit.assert( ismatsymm(testAMat+(testAMat')) );
            
            %negative tests
            testAMat = [2 1;3 2];
            mlunit.assert( ~ismatsymm(testAMat) );
            
            testAMat = 10*rand(20,20)+diag(1:19,1);
            mlunit.assert( ~ismatsymm(testAMat) );
            
            self.runAndCheckError('gras.la.ismatsymm(eye(5,7))','wrongInput:nonSquareMat');
        end
        
        function self = testIsMatPosAndPosSemDef(self)
            import gras.la.ismatposdef;
            import gras.la.ismatpossemdef;
            %
            absTol=elltool.conf.Properties.getAbsTol();
            %
            check(@ismatposdef);
            check(@ismatpossemdef)
            %
            testMat=rand(10,10);
            mlunit.assert(ismatpossemdef(testMat.'*testMat,absTol));
            %
            testMat=[1 2; 1 2];
            mlunit.assert(~ismatposdef(testMat,absTol));
            mlunit.assert(ismatpossemdef(testMat,absTol));
            %
            testMat=rand(10,10);
            testMat=-testMat.'*testMat;
            mlunit.assert(~ismatpossemdef(testMat,absTol));
            %
            self.runAndCheckError('gras.la.ismatposdef(eye(3,5))',...
                'wrongInput:nonSquareMat');
            self.runAndCheckError('gras.la.ismatpossemdef(eye(3,5))',...
                'wrongInput:nonSquareMat');
            %
            function check(fHandle)
                import gras.la.ismatposdef;
                import gras.la.ismatpossemdef;
                %
                mlunit.assert(fHandle(1,absTol));
                %
                testMat=rand(10,10);
                mlunit.assert(fHandle(testMat.'*testMat,absTol));
                %
                testMat=[1 2;3 4];
                mlunit.assert(~fHandle(testMat,absTol));
                %
            end
        end
    end
    
end

