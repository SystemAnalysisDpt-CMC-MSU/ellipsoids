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
            import gras.la.sqrtmpos;
            MAX_TOL = 1e-6;
            nDim = 1000;
            testMat = eye(nDim);
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert_equals(testMat, sqrtMat);
            sqrtMat = sqrtmpos(testMat);
            mlunit.assert_equals(testMat, sqrtMat);
            %
            nDim = 1000;
            testMat = diag(1:nDim);
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert_equals(sqrt(testMat), sqrtMat);
            sqrtMat = sqrtmpos(testMat);
            mlunit.assert_equals(sqrt(testMat), sqrtMat);
            %
            nDim = 2;
            testMat = [2, 1; 1, 2];
            vMat = [-1/sqrt(2), 1/sqrt(2); 1/sqrt(2), 1/sqrt(2)];
            dMat = diag([1, sqrt(3)]);
            sqrtTestMat = vMat*dMat*vMat';
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert_equals(sqrtTestMat, sqrtMat);
            sqrtMat = sqrtmpos(testMat);
            mlunit.assert_equals(sqrtTestMat, sqrtMat);
            %
            nDim = 3;
            testMat = [5, -4, 1; -4, 6, -4; 1, -4, 5];
            sqrtTestMat = [2, -1, 0; -1, 2, -1; 0, -1, 2];
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert(norm(sqrtmpos(sqrtTestMat, MAX_TOL) -...
                sqrtmpos(sqrtMat, MAX_TOL)) < MAX_TOL);
            %
            nDim = 15;
            load(strcat(self.testDataRootDir,...
                strcat(filesep, 'testSqrtm1_inp.mat')), 'testMat');
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert(norm(sqrtmpos(testMat, MAX_TOL)...
                -sqrtmpos(sqrtMat*sqrtMat', MAX_TOL))<MAX_TOL);
            %
            nDim = 15;
            load(strcat(self.testDataRootDir,...
                strcat(filesep, 'testSqrtm2_inp.mat')), 'testMat');
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert(norm(sqrtmpos(testMat,MAX_TOL) -...
                sqrtmpos(sqrtMat*sqrtMat')) < MAX_TOL);
            %
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 1.01*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            mlunit.assert(norm(sqrtmpos(test1Mat, MAX_TOL) -...
                sqrtmpos(test2Mat, MAX_TOL)) > MAX_TOL);
            %
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 0.5*MAX_TOL;
            test2Mat = test2SqrtMat*test2SqrtMat.';
            mlunit.assert(norm(sqrtmpos(test1Mat, MAX_TOL) -...
                sqrtmpos(test2Mat, MAX_TOL)) < MAX_TOL);
            %
            testMat = [1, 0; 0, -1];
            self.runAndCheckError('gras.la.sqrtmpos(testMat)',...
                'wrongInput');            
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
            %
            absTol=elltool.conf.Properties.getAbsTol();
            %
            fIsMatPosSemDef=@(qMat,absTol)ismatposdef(qMat,absTol,true);
            fIsMatPosDef=@(qMat,absTol)ismatposdef(qMat,absTol,false);
            check(@ismatposdef);
            check(fIsMatPosSemDef)
            check(fIsMatPosDef);
            %
            testMat=rand(10,10);
            mlunit.assert(fIsMatPosSemDef(testMat.'*testMat,absTol));
            %
            testMat=[1 5; 5 25];
            mlunit.assert(~ismatposdef(testMat,absTol));
            mlunit.assert(fIsMatPosSemDef(testMat,absTol));
            mlunit.assert(~fIsMatPosDef(testMat,absTol));
            %
            testMat=rand(10,10);
            testMat=-testMat.'*testMat;
            mlunit.assert(~fIsMatPosSemDef(testMat,absTol));
            %
            gras.la.ismatposdef(eye(3));
            %
            self.runAndCheckError('gras.la.ismatposdef(eye(3,5))',...
                'wrongInput:nonSquareMat');
            self.runAndCheckError('gras.la.ismatposdef([1 -1; 1 1])',...
                'wrongInput:nonSymmMat');
            %
            function check(fHandle)
                import gras.la.ismatposdef;
                %
                mlunit.assert(fHandle(1,absTol));
                %
                testMat=rand(10,10);
                isOk=fHandle(testMat.'*testMat,absTol);
                mlunit.assert(isOk);
                %
            end
        end
    end
    
end

