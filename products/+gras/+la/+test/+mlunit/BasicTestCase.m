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
        function self=testSqrtMSimple(self)
            import gras.la.sqrtmpos;
            import gras.la.ismatposdef;
            import gras.gen.sqrtpos;
            self.runAndCheckError('gras.la.sqrtmpos(eye(2),-1)',...
                'wrongInput:absTolNegative');
            mlunitext.assert(isreal(sqrtmpos(diag([0 -0.001]),0.001)));
            %
            minEigVal=-0.001;
            absTol=0.001;
            %
            mlunitext.assert(isreal(sqrtmpos(diag([0 minEigVal]),absTol)));
            %
            inpMat=diag([0 2*minEigVal]);
            self.runAndCheckError('gras.la.sqrtmpos(inpMat,absTol)',...
                'wrongInput:notPosSemDef');
            %
            checkIsPos([0 2*minEigVal],false);
            checkIsPos([0 minEigVal],false);
            checkIsPos([0 minEigVal],true,true);
            checkIsPos([10 -2*minEigVal],true);
            checkIsPos([absTol -2*minEigVal],true,true);
            %
            function checkIsPos(eigVec,isPosExp,varargin)
                import gras.la.ismatposdef;
                import gras.la.sqrtmpos;
                import gras.gen.sqrtpos;
                inpMat=diag(eigVec);
                isPos=ismatposdef(inpMat,absTol,varargin{:});
                mlunitext.assert_equals(isPos,isPosExp);
                %
                isNotNeg=ismatposdef(inpMat,absTol,true);
                if isNotNeg
                    mlunitext.assert(isreal(sqrtmpos(inpMat,absTol)));
                    sqrtVec=sqrtpos(eigVec,absTol);
                    expSqrtVec=arrayfun(@(x)sqrtpos(x,absTol),eigVec);
                    mlunitext.assert(all(sqrtVec==expSqrtVec));
                    mlunitext.assert(isreal(sqrtVec));
                else
                    self.runAndCheckError('gras.la.sqrtmpos(inpMat,absTol)',...
                        'wrongInput:notPosSemDef');
                    self.runAndCheckError('gras.gen.sqrtpos(eigVec,absTol);',...
                        'wrongInput:negativeInput');
                end
            end
        end
        function self = testSqrtM(self)
            import gras.la.sqrtmpos;
            MAX_TOL = 1e-6;
            nDim = 100;
            testMat = eye(nDim);
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert_equals(testMat, sqrtMat);
            sqrtMat = sqrtmpos(testMat);
            mlunit.assert_equals(testMat, sqrtMat);
            %
            nDim = 100;
            testMat = diag(1:nDim);
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert_equals(sqrt(testMat), sqrtMat);
            sqrtMat = sqrtmpos(testMat);
            mlunit.assert_equals(sqrt(testMat), sqrtMat);
            %
            testMat = [2, 1; 1, 2];
            vMat = [-1/sqrt(2), 1/sqrt(2); 1/sqrt(2), 1/sqrt(2)];
            dMat = diag([1, sqrt(3)]);
            sqrtTestMat = vMat*dMat*vMat';
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert_equals(sqrtTestMat, sqrtMat);
            sqrtMat = sqrtmpos(testMat);
            mlunit.assert_equals(sqrtTestMat, sqrtMat);
            %
            testMat = [5, -4, 1; -4, 6, -4; 1, -4, 5];
            sqrtTestMat = [2, -1, 0; -1, 2, -1; 0, -1, 2];
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert(norm(sqrtmpos(sqrtTestMat, MAX_TOL) -...
                sqrtmpos(sqrtMat, MAX_TOL)) < MAX_TOL);
            %
            load(strcat(self.testDataRootDir,...
                strcat(filesep, 'testSqrtm1_inp.mat')), 'testMat');
            sqrtMat = sqrtmpos(testMat, MAX_TOL);
            mlunit.assert(norm(sqrtmpos(testMat, MAX_TOL)...
                -sqrtmpos(sqrtMat*sqrtMat', MAX_TOL))<MAX_TOL);
            %
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
        function testIsMatPosSimple(~)
            isOk=~gras.la.ismatposdef(zeros(2),1e-7);
            mlunit.assert(isOk);
            isOk=gras.la.ismatposdef(zeros(2),1e-7,true);
            mlunit.assert(isOk);
            isOk=~gras.la.ismatposdef(zeros(2),1e-7,false);
            mlunit.assert(isOk);
            isOk=~gras.la.ismatposdef(zeros(2));
            mlunit.assert(isOk);    
            isOk=gras.la.ismatposdef(zeros(2),0,true);
            mlunit.assert(isOk);              
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
            testMat=testMat.'*testMat;
            testMat=0.5*(testMat+testMat.');
            mlunit.assert(fIsMatPosSemDef(testMat.'*testMat,absTol));
            %
            testMat=[1 5; 5 25];
            mlunit.assert(~ismatposdef(testMat,absTol));
            mlunit.assert(fIsMatPosSemDef(testMat,absTol));
            mlunit.assert(~fIsMatPosDef(testMat,absTol));
            %
            gras.la.ismatposdef(eye(3));
            %
            self.runAndCheckError('gras.la.ismatposdef(eye(3,5))',...
                'wrongInput:nonSquareMat');
            self.runAndCheckError('gras.la.ismatposdef([1 -1; 1 1])',...
                'wrongInput:nonSymmMat');
            %
            %
            nTimes=50;
            for iInd=1:nTimes
                checkMultTimes();
            end
            %
            isPosOrSemDef=true;
            orth3Mat=...
                [-0.206734513608356,-0.439770172956299,0.873992583413099;
                0.763234588112547,0.486418086920488,0.425288617559045;
                -0.612155049306781,0.754983204908957,0.23508840021067];
            %
            diagVec=[1; 2; 3];
            checkDeterm(isPosOrSemDef);
            %
            diagVec=[1; -1; 3];
            checkDeterm(~isPosOrSemDef);
            %
            diagVec=[0;1; 1];
            checkDeterm(~isPosOrSemDef)
            %
            diagVec=[0; 1; 2];
            checkDeterm(isPosOrSemDef,true);
            %
            diagVec=[0; -1; 2];
            checkDeterm(~isPosOrSemDef,true);
            %
            diagVec=[-1; 1; -2];
            checkDeterm(~isPosOrSemDef,false);
            checkDeterm(~isPosOrSemDef,true);
            %
            function checkDeterm(isTrue,isSemPosDef)
                import gras.la.ismatposdef;
                testMat=orth3Mat.'*diag(diagVec)*orth3Mat;
                testMat=0.5*(testMat+testMat.');
                if nargin<2
                    isOk=ismatposdef(testMat,absTol);
                else
                    isOk=ismatposdef(testMat,absTol,isSemPosDef);
                end
                mlunit.assert_equals(isTrue,isOk);
            end
            %
            function check(fHandle)
                import gras.la.ismatposdef;
                %
                mlunit.assert(fHandle(1,absTol));
                %
                testMat=rand(10,10);
                testMat=testMat.'*testMat;
                [vMat,~]=eig(testMat);
                dMat=diag(1:10);
                testMat=vMat.'*dMat*vMat;
                testMat=0.5*(testMat.'+testMat);
                isOk=fHandle(testMat,absTol);
                mlunit.assert(isOk);
                %
            end
            %
            function checkMultTimes()
                import gras.la.ismatposdef;
                testMat=rand(5,5);
                testMat=testMat.'*testMat;
                [vMat,~]=eig(testMat);
                dMat=diag(1:5);
                testMat=vMat.'*dMat*vMat;
                testMat=-0.5*(testMat.'+testMat);
                isFalse=ismatposdef(testMat,absTol,true);
                % Check that ismatposdef return false with
                % isSemDefFlagOn=true and at the same time sqrtmpos throws
                % notPosSemDef error:
                mlunit.assert_equals(false,isFalse);
                self.runAndCheckError('gras.la.sqrtmpos(testMat,absTol)',...
                    'wrongInput:notPosSemDef');
            end
        end
    end
    
end

