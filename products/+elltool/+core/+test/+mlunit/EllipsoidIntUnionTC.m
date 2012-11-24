classdef EllipsoidIntUnionTC < mlunitext.test_case

% $Author: Vadim Kaushanskiy, Moscow State University by M.V. Lomonosov,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 28-October-2012, <vkaushanskiy@gmail.com>$
    properties (Access=private)
        testDataRootDir
    end
 
    methods
        function self = EllipsoidIntUnionTC(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
    
        end
        
        function flexAssert(varargin)
            IS_ASSERTION_ON = true;
            if (IS_ASSERTION_ON)
                mlunit.assert_equals(varargin{2:end});
            end;
        end;
        
        
        function self = testContains(self)
            testEll1Vec = ellipsoid(eye(3));
            testEll2Vec = ellipsoid([10, 0, 5]', [1, 0, 0; 0, 0, 0; 0, 0, 1]);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(0, testResVec);
            
            testEll1Vec = ellipsoid(eye(3));
            testEll2Vec = ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 1]);
            %testResVec = contains(testEll1Vec, testEll2Vec);
            %mlunit.assert_equals(1, testResVec);
            
            testEll1Vec = ellipsoid(eye(3));
            testEll2Vec = ellipsoid(eye(3));
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(1, testResVec);
            
            testEll1Vec = ellipsoid(eye(3));
            testEll2Vec = ellipsoid([1e-4, 1e-4, 0]', eye(3));
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(0, testResVec);
            
            testEll1Vec = ellipsoid(4*eye(2));
            testEll2Vec = ellipsoid([1, 0]', eye(2));
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(1, testResVec);
            
            
            testEll1Vec = ellipsoid(eye(2));
            testEll2Vec = ellipsoid(zeros(2));
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(1, testResVec);
            
            testEll1Vec = ellipsoid(eye(2));
            testEll2Vec = ellipsoid([1, 0; 0, 0]);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(1, testResVec);
            
            testEll1Vec = ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 1]);
            testEll2Vec = ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 0]);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(1, testResVec);
            
        end
        
        function self = testEq(self)
            import elltool.conf.Properties;
            
            MAX_TOL = Properties.getRelTol();
            
            
            testMat = eye(2);
            [isEq, reportStr] = eq(ellipsoid(testMat), ellipsoid(testMat));
            mlunit.assert_equals(1, isEq);
            mlunit.assert_equals('', reportStr);
            
            
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 1.01*MAX_TOL; 
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = eq(ellipsoid(test1Mat), ellipsoid(test2Mat));
            mlunit.assert_equals(0, isEq);
            mlunit.assert_equals('(1).Q-->Max. difference (1.010000e-05) is greater than the specified tolerance(1.000000e-05)', reportStr);
            
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + 0.5*MAX_TOL; 
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = eq(ellipsoid(test1Mat), ellipsoid(test2Mat));            
            mlunit.assert_equals(1, isEq);
            mlunit.assert_equals('', reportStr);
            
            test1Mat = eye(2);
            test2SqrtMat = eye(2) + MAX_TOL; 
            test2Mat = test2SqrtMat*test2SqrtMat.';
            [isEq, reportStr] = eq(ellipsoid(test1Mat), ellipsoid(test2Mat)); 
            mlunit.assert_equals(0, isEq);
            mlunit.assert_equals(reportStr, '(1).Q-->Max. difference (1.000000e-05) is greater than the specified tolerance(1.000000e-05)');
           
            test1Mat = eye(2);
            test2Mat = eye(2) + MAX_TOL;
            [isEq, reportStr] = eq(ellipsoid(test1Mat), ellipsoid(test2Mat)); 
            mlunit.assert_equals(1, isEq);
            mlunit.assert_equals('', reportStr);
            
            test1Mat = eye(2);
            test2Mat = eye(2) - 0.99*MAX_TOL;
            [isEq, reportStr] = eq(ellipsoid(test1Mat), ellipsoid(test2Mat)); 
            mlunit.assert_equals(1, isEq);
            mlunit.assert_equals('', reportStr);
            
            test1Mat = 100*eye(2);
            test2Mat = 100*eye(2) - 0.99*MAX_TOL;
            [isEq, reportStr] = eq(ellipsoid(test1Mat), ellipsoid(test2Mat)); 
            mlunit.assert_equals(1, isEq);
            mlunit.assert_equals('', reportStr);
            
            testEll = ellipsoid(eye(2));
            testEll2 = ellipsoid([1e-3, 0].', eye(2));
            mDim = 10;
            nDim = 15;
            testEllArr = repmat(testEll, mDim, nDim);
            isEqualArr = true(mDim, nDim);
            isnEqualArr = ~isEqualArr;
            mlunit.assert_equals(isEqualArr, testEll.eq(testEllArr));
            mlunit.assert_equals(isEqualArr, testEllArr.eq(testEll));
            mlunit.assert_equals(isnEqualArr, testEll2.eq(testEllArr));
            mlunit.assert_equals(isnEqualArr, testEllArr.eq(testEll2));
            
            testEll2Arr = repmat(testEll2, mDim, nDim);
            mlunit.assert_equals(isEqualArr, testEllArr.eq(testEllArr));
            mlunit.assert_equals(isnEqualArr, testEll2Arr.eq(testEllArr));
            
            self.runAndCheckError('eq([testEll, testEll2], [testEll; testEll2])','wrongSizes');

            
            
        end
        
        function self = testIsInternal(self)
            nDim = 100;
            testEllVec = ellipsoid(zeros(nDim, 1), eye(nDim));
            testPointVec = zeros(nDim, 1);
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);
            
            testPointVec(nDim) = 1;
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);
            
            for iDim = 1:nDim
                testPointVec(iDim) = 1 / sqrt(nDim);
            end;
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);
            
            testPointVec = ones(nDim, 1);
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(0, testResVec);
            
            for iDim = 1:nDim
                testPointVec(iDim) = 1 / sqrt(nDim);
            end;
            testPointVec(1) = testPointVec(1) + 1e-4;
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(0, testResVec);
            
            
            
            nDim = 3;
            testEllVec = ellipsoid(zeros(nDim, 1), [1, 0, 0; 0, 2, 0; 0, 0, 0]);
            testPointVec = [0.3, -0.8, 0].';
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(1, testResVec);
            
            testPointVec = [0.3, -0.8, 1e-3].';
            testResVec = isinternal(testEllVec, testPointVec);
            self.flexAssert(0, testResVec);
            
            nDim = 2;
        
            testEllVec(1) = ellipsoid(zeros(nDim, 1), eye(nDim));
            testEllVec(2) = ellipsoid([2, 0].', eye(nDim));
            testPointVec = [1, 0; 2, 0].';
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert([1, 1], testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([1, 0], testResVec);
            
            for iNum = 1:1000
                testEllVec(iNum) = ellipsoid(eye(2));
            end;
            testPointVec = [0, 0].';
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert(1, testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert(1, testResVec);
            
            
        end
        function self = testPolar(self)

           nDim = 100;
           testEllVec = ellipsoid(zeros(nDim, 1), eye(nDim));
           polarEllipsoid = polar(testEllVec);
           self.flexAssert(1, eq(testEllVec, polarEllipsoid));
           
           nDim = 100;
           testSingEllVec = ellipsoid(zeros(nDim, 1), zeros(nDim));
           self.runAndCheckError('polar(testSingEllVec)','degenerateEllipsoid');

           nDim = 3;
           testSingEllVec = ellipsoid(zeros(nDim, 1), [1, 0, 0; 0, 2, 0; 0, 0, 0]);
           self.runAndCheckError('polar(testSingEllVec)','degenerateEllipsoid');
           
           nDim = 2;
           testEllVec = ellipsoid(zeros(nDim, 1), [2, 0; 0, 1]);
           polarEllVec = polar(testEllVec);
           ansEllVec = ellipsoid(zeros(nDim, 1), [0.5, 0; 0, 1]);
           self.flexAssert(1, eq(polarEllVec, ansEllVec));
           
           
           nDim = 2;
           testEllVec = ellipsoid([0, 0.5].', eye(2));
           polarEllVec = polar(testEllVec);
           ansEllVec = ellipsoid([0, -2/3].', [4/3, 0; 0, 16/9]);
           self.flexAssert(1, eq(polarEllVec, ansEllVec));
        end
        function self = testIntersect(self)
            %problem is infeasible
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([2, 2].', eye(nDim));
            testHyperplane = hyperplane([1, 0].', 10);
            testResVec = intersect(testEllVec, testHyperplane, 'i');
            self.flexAssert(-1, testResVec);
            
            testEllVec_2 = ellipsoid(eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(-1, testResVec);
            
            
            %empty intersection
            
            %with ellipsoid
            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testEllVec_2 = ellipsoid([1000, -1000].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(0, testResVec);
            
            %degenerate ellipsoid
            nDim = 3;
            testEllVec = ellipsoid(eye(nDim));
            testEllVec_2 = ellipsoid([1, 0, 0; 0, 0, 0; 0, 0, 1]);
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(1, testResVec);
         
            nDim = 3;
            testEllVec = ellipsoid(eye(nDim));
            testEllVec_2 = ellipsoid([10, 0, 0].', [1, 0, 0; 0, 0, 0; 0, 0, 1]);
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(0, testResVec);
            %with hyperplane
           
            nDim = 2;
            testEllVec = ellipsoid([1000, -1000].', eye(nDim));
            testHyperPlane = hyperplane([1, 0].', 10);
            testResVec = intersect(testEllVec, testHyperPlane);
            self.flexAssert(0, testResVec);
            
            %two ellipsoids
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0].', eye(nDim));
            testEllVec_2 = ellipsoid([100, -100].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(0, testResVec);
            %intersection is not empty
            
            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testResVec = intersect(testEllVec, testEllVec);
            self.flexAssert(1, testResVec);
            
            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testEllVec_2 = ellipsoid([2, 0].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(1, testResVec);
            
            
            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testEllVec_2 = ellipsoid([1, 0].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2);
            self.flexAssert(1, testResVec);
            
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0].', eye(nDim));
            testEllVec_2 = ellipsoid([0, 1].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'i');
            self.flexAssert(1, testResVec);
            
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([2, 0].', eye(nDim));
            testEllVec_2 = ellipsoid([1, 1].', eye(nDim));
            testResVec = intersect(testEllVec, testEllVec_2, 'u');
            self.flexAssert(1, testResVec);
            
            %hyperplane
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([2, 0].', eye(nDim));
            testHp = hyperplane([1, 0].', 1);
            testResVec = intersect(testEllVec, testHp, 'i');
            self.flexAssert(1, testResVec);
            testResVec = intersect(testEllVec, testHp, 'u');
            self.flexAssert(1, testResVec);
            
  
        end

        function self = testEllintersectionIa(self)
            nDim = 10;
            nArr = 15;
            eyeEllipsoid = ellipsoid(eye(nDim));
            for iArr = 1:nArr
                testEllVec(iArr) = eyeEllipsoid;
            end;
            resEllVec = ellintersection_ia(testEllVec);
            ansEllVec = eyeEllipsoid;
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            
            clear testEllVec;
            
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0].', eye(nDim));
            resEllVec = ellintersection_ia(testEllVec);

            ansEllVec = ellipsoid([0.5, 0]', [0.235394505823186, 0; 0, 0.578464829541428]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(testEllVec(1), resEllVec));
            self.flexAssert(1, contains(testEllVec(2), resEllVec));

            clear testEllVec;
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0].', eye(nDim));
            testEllVec(3) = ellipsoid([0, 1].', eye(nDim));
            resEllVec = ellintersection_ia(testEllVec);
            ansEllCenterVec =  [0.407334113249147, 0.407334108829435].';
            ansEllMat = [0.125814744141070, 0.053912566043053; 0.053912566043053, 0.125814738841440];
            ansEllVec = ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(testEllVec(1), resEllVec));
            self.flexAssert(1, contains(testEllVec(2), resEllVec));
            self.flexAssert(1, contains(testEllVec(3), resEllVec));
            
            
            clear testEllVec;
            nDim = 3;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0.5, -0.5].', [2, 0, 0; 0, 1, 0; 0, 0, 0.5]);
            testEllVec(3) = ellipsoid([0.5, 0.3, 1].', [0.5, 0, 0; 0, 0.5, 0; 0, 0, 2]);
            resEllVec = ellintersection_ia(testEllVec);
            
            ansEllCenterVec = [0.513846517075189, 0.321868721330990, -0.100393450228106].';
            ansEllMat = [0.156739727326948, -0.005159338786834, 0.011041318375176; -0.005159338786834, 0.161491682085078, 0.014052111019755; 0.011041318375176, 0.014052111019755, 0.062235791525665];
            ansEllVec = ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(testEllVec(1), resEllVec));
            self.flexAssert(1, contains(testEllVec(2), resEllVec));
            self.flexAssert(1, contains(testEllVec(3), resEllVec));

            clear testEllVec;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllintersection_inpSimple.mat')), 'testEllCenterVec', 'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellintersection_ia(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllintersection_outSimple.mat')), 'ansEllCenterVec', 'ansEllMat');
            ansEllVec = ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(testEllVec(1), resEllVec));
            self.flexAssert(1, contains(testEllVec(2), resEllVec));

            clear testEllVec;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllintersectionIa_inp.mat')), 'testEllCenterVec', 'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellintersection_ia(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllintersectionIa_out.mat')), 'ansEllCenterVec', 'ansEllMat');
            ansEllVec = ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(testEllVec(1), resEllVec));
            self.flexAssert(1, contains(testEllVec(2), resEllVec));
            
            clear testEllVec;
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([100, 0]', eye(nDim));
            self.runAndCheckError('ellintersection_ia(testEllVec)','cvxError');
            
        end
        function self = testEllunionEa(self)
            nDim = 10;

            nArr = 15;
            eyeEllipsoid = ellipsoid(eye(nDim));
            for iArr = 1:nArr
                testEllVec(iArr) = eyeEllipsoid;
            end;
            resEllVec = ellunion_ea(testEllVec);
            ansEllVec = eyeEllipsoid;
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            
            clear testEllVec;
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0].', eye(nDim));
            resEllVec = ellunion_ea(testEllVec);
              
            ansEllVec = ellipsoid([0.5, 0].', [2.389605510164642, 0; 0, 1.296535157845836]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(resEllVec, testEllVec(1)));
            self.flexAssert(1, contains(resEllVec, testEllVec(2)));
            
            clear testEllVec;
            nDim = 2;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0].', eye(nDim));
            testEllVec(3) = ellipsoid([0, 1].', eye(nDim));
            resEllVec = ellunion_ea(testEllVec);
            ansEllVec = ellipsoid([0.361900110249858, 0.361900133569072].', [2.713989398757731, -0.428437874833322;-0.428437874833322, 2.713989515632939]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(resEllVec, testEllVec(1)));
            self.flexAssert(1, contains(resEllVec, testEllVec(2)));
            self.flexAssert(1, contains(resEllVec, testEllVec(3)));
            
            
            nDim = 3;
            testEllVec(1) = ellipsoid(eye(nDim));
            testEllVec(2) = ellipsoid([1, 0.5, -0.5].', [2, 0, 0; 0, 1, 0; 0, 0, 0.5]);
            testEllVec(3) = ellipsoid([0.5, 0.3, 1].', [0.5, 0, 0; 0, 0.5, 0; 0, 0, 2]);
            resEllVec = ellunion_ea(testEllVec);

            ansEllShape = [3.214279075152898 0.597782711155458 -0.610826375241159; 0.597782711155458 1.826390617268878  -0.135640717373030;-0.610826375241159  -0.135640717373030 4.757741393980497];
            ansEllCenterVec = [0.678847905650305, 0.271345357930677, 0.242812593977658].';
            ansEllVec = ellipsoid(ansEllCenterVec, ansEllShape);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(1, contains(resEllVec, testEllVec(1)));
            self.flexAssert(1, contains(resEllVec, testEllVec(2)));
            self.flexAssert(1, contains(resEllVec, testEllVec(3)));
            
            clear testEllVec;
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllunion_inpSimple.mat')), 'testEllCenterVec', 'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellunion_ea(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllunion_outSimple.mat')), 'ansEllCenterVec', 'ansEllMat');
            ansEllVec = ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(1, contains(resEllVec, testEllVec(1)));
            self.flexAssert(1, contains(resEllVec, testEllVec(2)));
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            clear testEllVec;
            nDim = 15;
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllunionEa_inp.mat')), 'testEllCenterVec', 'testEllMat', 'testEllCenter2Vec', 'testEll2Mat');
            testEllVec(1) = ellipsoid(testEllCenterVec, testEllMat);
            testEllVec(2) = ellipsoid(testEllCenter2Vec, testEll2Mat);
            resEllVec = ellunion_ea(testEllVec);
            load(strcat(self.testDataRootDir, strcat(filesep, 'testEllunionEa_out.mat')), 'ansEllCenterVec', 'ansEllMat');
            ansEllVec = ellipsoid(ansEllCenterVec, ansEllMat);
            self.flexAssert(1, contains(resEllVec, testEllVec(1)));
            self.flexAssert(1, contains(resEllVec, testEllVec(2)));
            self.flexAssert(1, eq(resEllVec, ansEllVec));
        end
        function self = testHpIntersection(self)
            %empty intersection
            nDim = 2;
            testEllVec = ellipsoid([100, -100]', eye(nDim));
            testHpVec = hyperplane([0 -1]', 1);
            self.runAndCheckError('resEllVec = hpintersection(testEllVec, testHpVec)','degenerateEllipsoid');
            
            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testHpVec = hyperplane([1, 0].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([0, 0; 0, 1]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            
            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testHpVec = hyperplane([0, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([1, 0; 0, 0]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));

            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testHpVec = hyperplane([1, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([0.5, -0.5; -0.5, 0.5]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));

            nDim = 2;
            testEllVec = ellipsoid(eye(nDim));
            testHpVec = hyperplane([1, 0].', 1);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([1, 0].', [0, 0; 0, 0]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));

            nDim = 3;
            testEllVec = ellipsoid(eye(nDim));
            testHpVec = hyperplane([0, 0, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 0]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            
            nDim = 3;
            testEllVec = ellipsoid([3, 0, 0; 0, 2, 0; 0, 0, 4]);
            testHpVec = hyperplane([0, 1, 0].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([3, 0, 0; 0, 0, 0; 0, 0, 4]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));

            
            nDim = 3;
            testEllVec = ellipsoid(eye(3));
            testHpVec = hyperplane([1, 1, 1].', 0);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([2/3, -1/3, -1/3; -1/3, 2/3, -1/3; -1/3, -1/3, 2/3]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));

            
            
            nDim = 3;
            testEllVec = ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 4]);
            testHpVec = hyperplane([0, 0, 1].', 2);
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid([0, 0, 2].', [0, 0, 0; 0, 0, 0; 0, 0, 0]);
            self.flexAssert(1, eq(resEllVec, ansEllVec));

            nDim = 100;
            testEllVec = ellipsoid(eye(nDim));
            PlaneNorm = zeros(nDim, 1);
            PlaneNorm(1) = 1;
            testHpVec = hyperplane(PlaneNorm, 0);
            
            resEllVec = hpintersection(testEllVec, testHpVec);
            ansEllMat = eye(nDim);
            ansEllMat(1) = 0;
            ansEllVec = ellipsoid(zeros(nDim, 1), ansEllMat);
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            
            
            %two output arguments
            nDim = 2;
            testEllVec = ellipsoid([100, -100].', eye(nDim));
            testHpVec = hyperplane([0 -1].', 1);
            [resEllVec, isnIntersected] = hpintersection(testEllVec, testHpVec);
            ansEllVec = ellipsoid;
            self.flexAssert(1, eq(resEllVec, ansEllVec));
            self.flexAssert(true, isnIntersected);
            
            nDim = 2;
            testEllMat(1, 1) = ellipsoid([100, -100].', eye(nDim));
            testHpMat(1, 1) = hyperplane([0 -1].', 1);
            testEllMat(2, 2) = ellipsoid([100, -100].', eye(nDim));
            testHpMat(2, 2) = hyperplane([0 -1].', 1);
            testEllMat(1, 2) = ellipsoid(eye(nDim));
            testHpMat(1, 2) = hyperplane([0, 1].', 0);
            testEllMat(2, 1) = ellipsoid(eye(nDim));
            testHpMat(2, 1) = hyperplane([0, 1].', 0);
            [resEllMat, isnIntersected] = hpintersection(testEllMat, testHpMat);
            
            clear ansEllMat;
            ansEllMat(1, 1) = ellipsoid;
            ansEllMat(2, 2) = ellipsoid;
            ansEllMat(1, 2) = ellipsoid([1, 0; 0, 0]);
            ansEllMat(2, 1) = ellipsoid([1, 0; 0, 0]);
            ansIsnIntersectedMat = [true, false; false, true];
            self.flexAssert([1, 1; 1, 1], eq(resEllMat, ansEllMat));
            self.flexAssert(ansIsnIntersectedMat, isnIntersected);
            
            %wrong dimension
            for iDim = 1:2
                for jDim = 1:2
                    for kDim = 1:2
                        testEllArr(iDim, jDim, kDim) = ellipsoid(eye(3));
                    end;
                end;
            end;
            
            testHp = hyperplane([0, 0, 1].', 2);
            self.runAndCheckError('resEllVec = hpintersection(testEllArr, testHp)','wrongInput:wrongDim');
            
            for iDim = 1:2
                for jDim = 1:2
                    for kDim = 1:2
                        testHpArr(iDim, jDim, kDim) = hyperplane([0, 0, 1].', 2);
                    end;
                end;
            end;
            
            testEllVec = ellipsoid(eye(3));
            self.runAndCheckError('resEllVec = hpintersection(testEllVec, testHpArr)','wrongInput:wrongDim');
            
        end
        
        function self = testEllEnclose(self)
            pointsVec = [1, 0, -1, 0; 0, 1, 0, -1];
            resEllVec = ell_enclose(pointsVec);
            ansEllVec = ellipsoid([0, 0].', eye(2));
            mlunit.assert_equals(1, eq(resEllVec, ansEllVec));
            
            pointsVec = [2, 0, -2, 0; 0, 1/3, 0, -1/3];
            resEllVec = ell_enclose(pointsVec);
            ansEllVec = ellipsoid([0, 0].', [4, 0; 0, 1/9]);
            mlunit.assert_equals(1, eq(resEllVec, ansEllVec));
            
            pointsVec = [1/2, 0, 0, 0; 0, 0, 0, -3];
            resEllVec = ell_enclose(pointsVec);
            ansEllVec = ellipsoid([1/6, -1].', [1/9, 1/3; 1/3, 4]);
            mlunit.assert_equals(1, eq(resEllVec, ansEllVec));           
            
            phiAngleVec = 0:0.1:2*pi;
            psiAngleVec = 0:0.1:pi;
            pointsVec = zeros(3, numel(phiAngleVec)*numel(psiAngleVec));
            for iAngle = 1:numel(phiAngleVec)
                for jAngle = 1:numel(psiAngleVec)
                    pointsVec(1, (iAngle-1)*numel(psiAngleVec) + jAngle) = cos(phiAngleVec(iAngle))*sin(psiAngleVec(jAngle));
                    pointsVec(2, (iAngle-1)*numel(psiAngleVec) + jAngle) = sin(phiAngleVec(iAngle))*sin(psiAngleVec(jAngle));
                    pointsVec(3, (iAngle-1)*numel(psiAngleVec) + jAngle) = cos(psiAngleVec(jAngle));
                end
            end
            resEllVec = ell_enclose(pointsVec);
            ansEllVec = ellipsoid([0, 0, 0].', eye(3));
            mlunit.assert_equals(1, eq(resEllVec, ansEllVec));
            
        end
 
    end
        
end

