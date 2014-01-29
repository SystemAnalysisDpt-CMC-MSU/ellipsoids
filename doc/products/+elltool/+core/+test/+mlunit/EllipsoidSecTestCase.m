classdef EllipsoidSecTestCase < mlunitext.test_case
%$Author: Igor Samokhin <igorian.vmk@gmail.com> $
%$Date: 2012-11-02 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $

     properties (Access=private)
        testDataRootDir
     end
     methods
        function self=EllipsoidSecTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,...
                'TestData', filesep,shortClassName];
        end
        function self = testIsContainedInIntersection (self)
            [test1Ell, test2Ell] = createTypicalEll(1);
            compareForIsCII(test1Ell, [test1Ell test2Ell], 'i', 1);
            compareForIsCII(test1Ell, [test1Ell test2Ell], [], 0);
            [test1Ell, test2Ell] = createTypicalEll(2);
            compareForIsCII(test1Ell, [test1Ell test2Ell], 'i', 1);
            compareForIsCII(test1Ell, [test1Ell test2Ell], 'u', 0);
            [test1Ell, test2Ell] = createTypicalEll(3);
            compareForIsCII(test1Ell, [test1Ell test2Ell], 'i', -1);
            compareForIsCII(test1Ell, [test1Ell test2Ell], 'u', 0);
            [test1Ell, test2Ell] = createTypicalEll(4);
            compareForIsCII([test1Ell test2Ell], test1Ell, 'i', 0);
            compareForIsCII([test1Ell test2Ell], [test1Ell test2Ell],...
                [], 0);
            [test1Ell, test2Ell] = createTypicalHighDimEll(7);
            compareForIsCII([test1Ell test2Ell], test1Ell, 'i', 0);
            compareForIsCII([test1Ell test2Ell], [test1Ell test2Ell],...
                [], 0);
            compareForIsCII([test1Ell test2Ell], [test1Ell test2Ell],...
                'u', 0);
        end
        function self = testIsBadDirection(self)
            [test1Ell, test2Ell] = createTypicalEll(5);
            absTol=min(test1Ell.getAbsTol(),test2Ell.getAbsTol());
            aMat = [diag(ones(6, 1)), [1; 2; 3; 3; 4; 5]];
            isTestResVec = isbaddirection(test1Ell, test2Ell, aMat,...
                absTol);
            isTestRes = any(isTestResVec);
            mlunitext.assert_equals(false, isTestRes);
            [test1Ell, test2Ell] = createTypicalEll(6);
            compareExpForIsBadDir(test1Ell, test2Ell, [1, -1; 0, 0], ...
                [1, -1; 2, 3],absTol);
            [test1Ell, test2Ell] = createTypicalEll(7);
            compareExpForIsBadDir(test1Ell, test2Ell,...
            [1, -1, 1000, 1000; 0, 0, 0.5, 0.5; 0, 0, -0.5, -1],...
            [1, -1, 0, 0; 1, -2, 1, 2; 7, 3, 2, 1],absTol);
            [test1Ell, test2Ell, aMat, bMat] = createTypicalHighDimEll(8);
            compareExpForIsBadDir(test1Ell, test2Ell, aMat, bMat,absTol);
        end
        function self = testMinkmp_ea(self)
            compareAnalyticForMinkMp(true, false, 8, 5, 0, [])
            compareAnalyticForMinkMp(true, false, 9, 5, 5, true)
            compareAnalyticForMinkMp(true, false, 10, 5, 2, true)
            compareAnalyticForMinkMp(true, true, 9, 100, 100, true)
        end
        function self = testMinkmp_ia(self)
            compareAnalyticForMinkMp(false, false, 8, 5, 0, [])
            compareAnalyticForMinkMp(false, false, 9, 5, 5, true)
            compareAnalyticForMinkMp(false, false, 10, 5, 2, true)
            compareAnalyticForMinkMp(false, true, 9, 100, 100, true)
        end
        function self = testMinksum_ea(self)
            compareAnalyticForMinkSum(true, false, 11, 5, 5, true)
            compareAnalyticForMinkSum(true, false, 12, 5, 5, true)
            compareAnalyticForMinkSum(true, false, 13, 5, 5, true)
            compareAnalyticForMinkSum(true, true, 10, 100, 100, true)
        end
        function self = testMinksum_ia(self)
            compareAnalyticForMinkSum(false, false, 11, 5, 5, true)
            compareAnalyticForMinkSum(false, false, 12, 5, 5, true)
            compareAnalyticForMinkSum(false, false, 13, 5, 5, true)
            compareAnalyticForMinkSum(false, true, 10, 100, 100, true)
        end
        
        function self=testRepmat(self)     
            %
            testEll1=ellipsoid([16 0;0 25]);
            testEll2=ellipsoid([9 0; 0 4]);
            testDir1Vec=[10;1]/realsqrt(101);
            testDir2Vec=[1;1]/realsqrt(2);
            testDirMat=[testDir1Vec, testDir2Vec];
            %
            %Minkdiff_ia, minkdiff_ea work incorrectly
            %
            check(@minkdiff_ia,false);
            check(@minkdiff_ea,false);
            %
            %All other functions work correctly by luck...
            %
            check(@minkpm_ea,false);
            check(@minkpm_ia,false);
            %
            fMmpEA=@(fEll,sEll,dMat)minkmp_ea(fEll,sEll,...
                ellipsoid(eye(2)),dMat);
            fMmpIA=@(fEll,sEll,dMat)minkmp_ia(fEll,sEll,...
                ellipsoid(eye(2)),dMat);
            check(fMmpEA,false);
            check(fMmpIA,false);
            %
            %Hyperplane
            %
            arrSizeVec=[2,2,3,2];
            testNormArr=zeros(arrSizeVec);
            testNormArr(1,:)=1;
            testNormArr(2,:)=0;
            testHypArr=hyperplane(testNormArr,2);
            %
            testHyp=hyperplane([1;0],1);
            %
            isParrArr=isparallel(testHypArr,testHyp);
            isParr2Arr=isparallel(testHyp,testHypArr);
            mlunitext.assert_equals(true,...
                all(isParrArr(:))&&all(isParr2Arr(:)));
            
            function check(fMethod,isTrue)
            resEll1=fMethod(testEll1,testEll2, testDir1Vec);
            resEll2=fMethod(testEll1,testEll2, testDir2Vec);
            resEllVec=fMethod(testEll1,testEll2, testDirMat);
            isEq1=eq(resEll1,resEllVec(1));
            isEq2=eq(resEll2,resEllVec(2));
            isEq3=eq(resEll1,resEll2);
            isEq21=eq(resEll2,resEllVec(1));
            %
            % testEll1 and testEll2 are not the same
            mlunitext.assert_equals(true,~isEq3);
            % 
            % testEll2 equals testEllVec(1)
            mlunitext.assert_equals(isTrue,isEq21);
            %
            mlunitext.assert_equals(~isTrue, isEq1 && isEq2);
            end
        end
        
        function self = testMinkdiff_ea(self)
            [testEllipsoid1 ~] = createTypicalEll(14);
            testEllipsoid2 = ellipsoid([1; 0], eye(2));
            testEllipsoid3 = ellipsoid([1; 2], [1 0; 0 1]);
            testNotEllipsoid = [];
            
            testLVec = [0; 1];
            resEll = minkdiff_ea(testEllipsoid1, testEllipsoid2, testLVec);
            ansEll = ellipsoid([-1; 0], [0 0; 0 0]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            testLVec = [1; 1];
            %'MINKDIFF_EA: first and second arguments must be single ellipsoids.'
            self.runAndCheckError('minkdiff_ea(testEllipsoid1, testNotEllipsoid, testLVec)','wrongInput');
            
            %'MINKDIFF_EA: first and second arguments must be single ellipsoids.'
            self.runAndCheckError('minkdiff_ea([2*testEllipsoid1 2*testEllipsoid1], [testEllipsoid3 testEllipsoid3], testLVec)','wrongInput');
            
            testLVec = [1; 1; 1];
            %'MINKDIFF_EA: dimension of the direction vectors must be the same as dimension of ellipsoids.'
            self.runAndCheckError('minkdiff_ea(2*testEllipsoid1, testEllipsoid3, testLVec)','wrongSizes');
            
            testEllipsoid1 = ellipsoid([0; 0], [17 8; 8 17]);
            testEllipsoid2 = ellipsoid([1; 2], [13 12; 12 13]);
            testLVec = [1; 1];
            resEll = minkdiff_ea(testEllipsoid1, testEllipsoid2, testLVec);
            ansEll = ellipsoid([-1; -2], [2 -2; -2 2]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllHighDim1 testEllHighDim2 testLVec] = createTypicalHighDimEll(1);
            resEll = minkdiff_ea(testEllHighDim1, testEllHighDim2, testLVec);
            ansEll = ellipsoid(zeros(12, 1), eye(12));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllHighDim1 testEllHighDim2 testLVec] = createTypicalHighDimEll(2);
            resEll = minkdiff_ea(testEllHighDim1, testEllHighDim2, testLVec);
            ansEll = ellipsoid(zeros(20, 1), eye(20));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);

            [testEllHighDim1 testEllHighDim2 testLVec] = createTypicalHighDimEll(3);
            resEll = minkdiff_ea(testEllHighDim1, testEllHighDim2, testLVec);
            ansEll = ellipsoid(zeros(100, 1), eye(100));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            testEllipsoid1 = ellipsoid(eye(3));
            testEllipsoid2 = ellipsoid(diag([4, 9, 25]));
            testLVec = [1; 0; 0];
            resEll = minkdiff_ea(testEllipsoid2, testEllipsoid1, testLVec);
            ansEll = ellipsoid([0; 0; 0], diag([1, 4, 16]));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
        end 
        
        function self = testMinkdiff_ia(self)          
            [testEllipsoid1 ~] = createTypicalEll(14);
            testEllipsoid2 = ellipsoid([0; 1], eye(2));
            testEllipsoid3 = ellipsoid([0; 0], [4 0; 0 1]);
            testNotEllipsoid = [];
            
            testLVec = [0; 1];
            resEll = minkdiff_ia(testEllipsoid1, testEllipsoid2, testLVec);
            ansEll = ellipsoid([0; -1], [0 0; 0 0]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            resEll = minkdiff_ia(testEllipsoid3, testEllipsoid2, testLVec);
            ansEll = ellipsoid([0; -1], [0 0; 0 0]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            testLVec = [1; 0];
            resEll = minkdiff_ia(2*testEllipsoid1, testEllipsoid1, testLVec);
            ansEll = ellipsoid([0; 0], [1 0; 0 1]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            testLVec = [1; 1];
            %'MINKDIFF_IA: first and second arguments must be single ellipsoids.'
            self.runAndCheckError('minkdiff_ia(testEllipsoid1, testNotEllipsoid, testLVec)','wrongInput');
            
            %'MINKDIFF_IA: first and second arguments must be single ellipsoids.'
            self.runAndCheckError('minkdiff_ia([testEllipsoid1 testEllipsoid1], [testEllipsoid3 testEllipsoid3], testLVec)','wrongInput');
            
            testLVec = [1; 1; 1];
            %'MINKDIFF_IA: dimension of the direction vectors must be the same as dimension of ellipsoids.'
            self.runAndCheckError('minkdiff_ia(testEllipsoid3, testEllipsoid1, testLVec)','wrongSizes');
            
            [testEllHighDim1 testEllHighDim2 testLVec] = createTypicalHighDimEll(1);
            resEll = minkdiff_ia(testEllHighDim1, testEllHighDim2, testLVec);
            ansEll = ellipsoid(zeros(12, 1), eye(12));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllHighDim1 testEllHighDim2 testLVec] = createTypicalHighDimEll(2);
            resEll = minkdiff_ia(testEllHighDim1, testEllHighDim2, testLVec);
            ansEll = ellipsoid(zeros(20, 1), eye(20));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
 
            [testEllHighDim1 testEllHighDim2 testLVec] = createTypicalHighDimEll(3);
            resEll = minkdiff_ia(testEllHighDim1, testEllHighDim2, testLVec);
            ansEll = ellipsoid(zeros(100, 1), eye(100));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            testEllipsoid1 = ellipsoid(eye(3));
            testEllipsoid2 = ellipsoid(diag([4, 9, 16]));
            testLVec = [1; 0; 0];
            resEll = minkdiff_ia(testEllipsoid2, testEllipsoid1, testLVec);
            ansEll = ellipsoid([0; 0; 0], diag([1, 3.5, 7]));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
        end
        
        function self = testMinkpm_ea(self)
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(15);
            resEll = minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
            ansEll = ellipsoid(4, 1);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
            resEll = minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
            ansEll = ellipsoid([3; 1], [2 0; 0 2]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(17);
            resEll = minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
            ansEll = ellipsoid([3; 1; 0], [2 0 0; 0 2 0; 0 0 2]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(18);
            %'MINKPM_EA: first and second arguments must be ellipsoids.'
            self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(19);
            %'MINKPM_EA: first and second arguments must be ellipsoids.'
            self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
            %'MINKPM_EA: second argument must be single ellipsoid.'
            self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], [testEllipsoid3 testEllipsoid3], testLVec)', 'wrongInput');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(20);
            %'MINKPM_EA: all ellipsoids must be of the same dimension.'
            self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(21);
            %'MINKPM_EA: all ellipsoids must be of the same dimension.'
            self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
             
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(22);
            %'MINKPM_EA: dimension of the direction vectors must be the same as dimension of ellipsoids.'
            self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
            
            [testEllHighDim1 testLVec] = createTypicalHighDimEll(4);
            resEll = minkpm_ea([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
            ansEll = ellipsoid(zeros(12, 1), eye(12));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllHighDim1 testLVec] = createTypicalHighDimEll(5);
            resEll = minkpm_ea([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
            ansEll = ellipsoid(zeros(20, 1), eye(20));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllHighDim1 testLVec] = createTypicalHighDimEll(6);
            resEll = minkpm_ea([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
            ansEll = ellipsoid(zeros(100, 1), eye(100));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
        end
        
        function self = testMinkpm_ia(self)            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(15);
            resEll = minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
            ansEll = ellipsoid(4, 1);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
            resEll = minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
            ansEll = ellipsoid([3; 1], [2 0; 0 2]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(17);
            resEll = minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
            ansEll = ellipsoid([3; 1; 0], [2 0 0; 0 2 0; 0 0 2]);
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(18);
            %'MINKPM_IA: first and second arguments must be ellipsoids.'
            self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(19);
            %'MINKPM_IA: first and second arguments must be ellipsoids.'
            self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
            %'MINKPM_IA: second argument must be single ellipsoid.'
            self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], [testEllipsoid3 testEllipsoid3], testLVec)', 'wrongInput');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(20);
            %'MINKPM_IA: all ellipsoids must be of the same dimension.'
            self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
            
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(21);
            %'MINKPM_IA: all ellipsoids must be of the same dimension.'
            self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
             
            [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(22);
            %'MINKPM_IA: dimension of the direction vectors must be the same as dimension of ellipsoids.'
            self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
            
            [testEllHighDim1 testLVec] = createTypicalHighDimEll(4);
            resEll = minkpm_ia([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
            ansEll = ellipsoid(zeros(12, 1), eye(12));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllHighDim1 testLVec] = createTypicalHighDimEll(5);
            resEll = minkpm_ia([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
            ansEll = ellipsoid(zeros(20, 1), eye(20));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
            
            [testEllHighDim1 testLVec] = createTypicalHighDimEll(6);
            resEll = minkpm_ia([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
            ansEll = ellipsoid(zeros(100, 1), eye(100));
            [isEq, reportStr] = isEqual(resEll, ansEll);
            mlunitext.assert_equals(true, isEq, reportStr);
        end
        %
        %
        function self = testIsInside(self)
            ell1Arr = ellipsoid.fromRepMat(eye(2),[2 2 2]);
            ell2Arr = ellipsoid.fromRepMat(2*eye(2),[2 2]);
            ell2Arr(:,:,2) = ellipsoid.fromRepMat([1; 0],0.7*eye(2),[2 2]);
            expRes1Arr = true(2);
            expRes1Arr(:,:,2) = false(2);
            expRes2Arr = false(2,2,2);
            %
            myTestIsInside(ell1Arr,ell2Arr,expRes1Arr);
            %
            myTestIsInside(ell1Arr(1),ell2Arr,expRes1Arr);
            %
            myTestIsInside(ell1Arr,ell2Arr(2,2,2),expRes2Arr);
            %
            self.runAndCheckError('isInside(ell1Arr(1:2),ell2Arr)',...
                'wrongInput');
            %
            self.runAndCheckError('isInside(ellipsoid(eye(3)),ell2Arr)',...
                'wrongInput');
            badEllVec = [ellipsoid(eye(2)), ellipsoid(eye(3))];
            self.runAndCheckError('isInside(badEllVec,ell1Arr(1))',...
                'wrongInput');
            %
            self.runAndCheckError('isInside(ell1Arr,hyperplane())',...
                'wrongInput');
        end
     end
end

function myTestIsInside(ell1Arr,ell2Arr, expResVec)
    resVec = isInside(ell1Arr,ell2Arr);
    mlunitext.assert(all(resVec == expResVec));
end

function [varargout] = createTypicalEll(flag)
    switch flag
        case 1
            varargout{1} = ellipsoid([2; 1], [4, 1; 1, 1]);
            varargout{2} = ell_unitball(2);
        case 2
            varargout{1} = ellipsoid([2; 1; 0], ...
                [4, 1, 1; 1, 2, 1; 1, 1, 5]);
            varargout{2} = ell_unitball(3);
        case 3
            varargout{1} = ellipsoid([5; 5; 5], ...
                [4, 1, 1; 1, 2, 1; 1, 1, 5]);
            varargout{2} = ell_unitball(3);
        case 4
            varargout{1} = ellipsoid([5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6]);
            varargout{2} = ell_unitball(4);    
        case 5
            varargout{1} = ell_unitball(6);
            varargout{2} = ellipsoid(zeros(6, 1), diag(0.5 * ones(6, 1)));
        case 6
            varargout{1} = ellipsoid([5; 0], diag([4, 1]));
            varargout{2} = ellipsoid([0; 0], diag([1 / 8, 1/ 2]));
        case 7
            varargout{1} = ellipsoid([0; 0; 0], diag([4, 1, 1]));
            varargout{2} = ellipsoid([0; 0; 0], ...
                diag([1 / 8, 1/ 2, 1 / 2]));
        case 8
            varargout{1} = [3; 3; 8; 3; 23];
            varargout{2} = diag(ones(1, 5));
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = [6.5; 1; 1; 1; 1];
            varargout{5} = diag([5, 2, 2, 2, 2]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = [3; 3; 65; 4; 23];
            varargout{8} = diag([13, 3, 2, 2, 2]);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = [3; 8; 3; 2; 6];
            varargout{10} = diag([7, 2, 6, 2, 2]);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
        case 9
            varargout{1} = [3; 3; 8; 3; 23];
            varargout{2} = diag(ones(1, 5));
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = [6.5; 1; 1; 1; 1];
            varargout{5} = diag([0.25, 0.25, 0.25, 0.25, 0.25]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = [3; 3; 65; 4; 23];
            varargout{8} = diag([13, 3, 2, 2, 2]);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = [3; 8; 3; 2; 6];
            varargout{10} = diag([7, 2, 6, 2, 2]);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
        case 10
            varargout{1} = [3; 76; 8; 3; 23];
            varargout{2} = diag([3, 5, 6, 2, 7]);
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = [6.5; 1.345; 1.234; 114; 241];
            varargout{5} = diag([2, 3, 1.5, 0.6, 2]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = [7; 33; 45; 42; 3];
            varargout{8} = diag([3, 34, 23, 22, 21]);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = [32; 81; 36; -2325; -6];
            varargout{10} = diag([34, 12, 8, 17, 7]);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
        case 11
            varargout{1} = [3; 61; 2; 34; 3];
            varargout{2} = diag(5 * ones(1, 5));
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = 0;
            varargout{4} = 0;
            varargout{5} = 0;
            varargout{6} = 0;
            varargout{7} = test0Ell;
        case 12
            varargout{1} = [3; 61; 2; 34; 3];
            varargout{2} = diag(5 * ones(1, 5));
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = [31; 34; 51; 42; 3];
            varargout{4} = diag([13, 3, 22, 2, 24]);
            test1Ell = ellipsoid(varargout{3}, varargout{4});
            varargout{5} = [3; 8; 23; 12; 6];
            varargout{6} = diag([7, 6, 6, 8, 2]);
            test2Ell = ellipsoid(varargout{5}, varargout{6});
            varargout{7} = [test0Ell, test1Ell, test2Ell];
        case 13    
            varargout{1} = [32; 0; 8; 1; 23];
            varargout{2} = diag([3, 5, 6, 5, 2]);
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = [7; 3; 5; 42; 3];
            varargout{4} = diag([32, 34, 23, 12, 21]);
            test1Ell = ellipsoid(varargout{3}, varargout{4});
            varargout{5} = [32; 81; 36; -25; -62];
            varargout{6} = diag([4, 12, 1, 1, 75]);
            test2Ell = ellipsoid(varargout{5}, varargout{6});
            varargout{7} = [test0Ell, test1Ell, test2Ell];
        case 14
            varargout{1} = ellipsoid([0; 0], [1 0; 0 1]);
            varargout{2} = ellipsoid([1; 0], [1 0; 0 1]);
            varargout{3} = ellipsoid([1; 0], [2 0; 0 1]);
            varargout{4} = ellipsoid([0; 0], [0 0; 0 0]);
            varargout{5} = ellipsoid([0; 0; 0], [0 0 0 ;0 0 0; 0 0 0]);
            varargout{6} = ellipsoid;
        case 15
            varargout{1} = ellipsoid(2, 1);
            varargout{2} = ellipsoid(3, 1);
            varargout{3} = ellipsoid(1, 1);
            varargout{4} = 1;
        case 16
            varargout{1} = ellipsoid([1; 0], [2 0; 0 2]);
            varargout{2} = ellipsoid([2; 0], [1 0; 0 1]);
            varargout{3} = ellipsoid([0; -1], [1 0; 0 1]);
            varargout{4} = [1; 0];
        case 17
            varargout{1} = ellipsoid([1; 0; -1], [2 0 0; 0 2 0; 0 0 2]);
            varargout{2} = ellipsoid([2; 0; 2], [1 0 0; 0 1 0; 0 0 1]);
            varargout{3} = ellipsoid([0; -1; 1], [1 0 0; 0 1 0; 0 0 1]);
            varargout{4} = [1; 0; 0];
        case 18
            varargout{1} = ellipsoid([1; 0; -1], [2 0 0; 0 2 0; 0 0 2]);
            varargout{2} = ellipsoid([2; 0; 2], [1 0 0; 0 1 0; 0 0 1]);
            varargout{3} = [];
            varargout{4} = [1; 0; 0];
        case 19
            varargout{1} = [];
            varargout{2} = [];
            varargout{3} = ellipsoid([0; -1; 1], [1 0 0; 0 1 0; 0 0 1]);
            varargout{4} = [1; 0; 0];
        case 20
            varargout{1} = ellipsoid([1; 0; -1], [2 0 0; 0 2 0; 0 0 2]);
            varargout{2} = ellipsoid([2; 0], eye(2));
            varargout{3} = ellipsoid([0; -1; 1], [1 0 0; 0 1 0; 0 0 1]);
            varargout{4} = [1; 0; 0];
        case 21
            varargout{1} = ellipsoid([1; 0; -1], [2 0 0; 0 2 0; 0 0 2]);
            varargout{2} = ellipsoid([2; 0; 2], [1 0 0; 0 1 0; 0 0 1]);
            varargout{3} = ellipsoid([2; 0], eye(2));
            varargout{4} = [1; 0; 0];
        case 22
            varargout{1} = ellipsoid([1; 0; -1], [2 0 0; 0 2 0; 0 0 2]);
            varargout{2} = ellipsoid([2; 0; 2], [1 0 0; 0 1 0; 0 0 1]);
            varargout{3} = ellipsoid([2; 0; 0], eye(3));
            varargout{4} = [1; 0];
        otherwise
    end
end

function [varargout] = createTypicalHighDimEll(flag)
    switch flag
        case 1
            varargout{1} = ellipsoid(4*eye(12));
            varargout{2} = ellipsoid(eye(12));
            varargout{3} = [1 zeros(1, 11)]';
        case 2
            varargout{1} = ellipsoid(4*eye(20));
            varargout{2} = ellipsoid(eye(20));
            varargout{3} = [1 zeros(1, 19)]';
        case 3
            varargout{1} = ellipsoid(4*eye(100));
            varargout{2} = ellipsoid(eye(100));
            varargout{3} = [1 zeros(1, 99)]';
        case 4
            varargout{1} = ellipsoid(eye(12));
            varargout{2} = [1 zeros(1, 11)]';
        case 5
            varargout{1} = ellipsoid(eye(20));
            varargout{2} = [1 zeros(1, 19)]';
        case 6
            varargout{1} = ellipsoid(eye(100));
            varargout{2} = [1 zeros(1, 99)]';
        case 7
            varargout{1} = ellipsoid( zeros(100, 1), diag([5 * ones(1, 50), 2 * ones(1, 50)]));
            varargout{2} = ellipsoid( ones(100, 1), diag([0.2 * ones(1, 50), 0.5 * ones(1, 50)]));
        case 8
            varargout{1} = ellipsoid( zeros(100, 1), diag([5 * ones(1, 50), 2 * ones(1, 50)]));
            varargout{2} = ellipsoid( ones(100, 1), diag([0.2 * ones(1, 50), 0.5 * ones(1, 50)]));
            varargout{3} = eye(100, 50);
            varargout{4} = [zeros(50); eye(50)];        
        case 9
            varargout{1} = rand(100, 1);
            varargout{2} = diag([5 * ones(1, 50), 2 * ones(1, 50)]);
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = rand(100, 1);
            varargout{5} = diag([0.5 * ones(1, 50), 0.2 * ones(1, 50)]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = rand(100, 1);
            varargout{8} = diag(10 * rand(1, 100) + 0.5);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = rand(100, 1);
            varargout{10} = diag(10 * rand(1, 100) + 0.5);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
        case 10
            varargout{1} = rand(100, 1);
            varargout{2} = diag(10 * rand(1, 100) + 0.3);
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = rand(100, 1);
            varargout{4} = diag(10 * rand(1, 100) + 0.3);
            test1Ell = ellipsoid(varargout{3}, varargout{4});
            varargout{5} = rand(100, 1);
            varargout{6} = diag(10 * rand(1, 100) + 0.3);
            test2Ell = ellipsoid(varargout{5}, varargout{6});
            varargout{7} = [test0Ell, test1Ell, test2Ell];    
        otherwise
    end
end
function analyticResEllVec = calcExpMinkMp(isExtApx, nDirs, aMat,...
    e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, qVec, qMat)
    analyticResVec = e0Vec - qVec + e1Vec + e2Vec;
    analyticResEllVec(nDirs) = ellipsoid;
    for iDir = 1 : nDirs
        lVec = aMat(:, iDir);
        if (isExtApx == 1) % minkmp_ea
            supp1Mat = realsqrt(e0Mat);
            supp1Mat = 0.5 * (supp1Mat + supp1Mat.');
            supp1Vec = supp1Mat * lVec;
            supp2Mat = realsqrt(qMat);
            supp2Mat = 0.5 * (supp2Mat + supp2Mat.');
            supp2Vec = supp2Mat * lVec;
            [unitaryU1Mat, ~, unitaryV1Mat] = svd(supp1Vec);
            [unitaryU2Mat, ~, unitaryV2Mat] = svd(supp2Vec);
            sMat = unitaryU1Mat * unitaryV1Mat * ...
                unitaryV2Mat.' * unitaryU2Mat.';
            sMat = real(sMat);
            qStarMat = supp1Mat - sMat * supp2Mat;
            qPlusMat = qStarMat.' * qStarMat;
            qPlusMat = 0.5 * (qPlusMat + qPlusMat.');
            aDouble = realsqrt(dot(lVec, qPlusMat * lVec));
            a1Double = realsqrt(dot(lVec, e1Mat * lVec));
            a2Double = realsqrt(dot(lVec, e2Mat * lVec));
            analyticResMat = (aDouble + a1Double + a2Double) .* ...
                ( qPlusMat ./ aDouble + e1Mat ./ a1Double + ...
                e2Mat ./ a2Double);
        else % minkmp_ia
            pDouble  = (realsqrt(dot(lVec, e0Mat * lVec))) / ...
                (realsqrt(dot(lVec, qMat * lVec)));
            qMinusMat  = (1 - (1 / pDouble)) * e0Mat + ...
                (1 - pDouble) * qMat;
            qMinusMat = 0.5 * (qMinusMat + qMinusMat.');
            supp1Mat = sqrtm(qMinusMat);
            supp2Mat = sqrtm(e1Mat);
            supp3Mat = sqrtm(e2Mat);
            supp1lVec = supp1Mat * lVec;
            supp2lVec = supp2Mat * lVec;
            supp3lVec = supp3Mat * lVec;
            [unitaryU1Mat, ~, unitaryV1Mat] = svd(supp1lVec);
            [unitaryU2Mat, ~, unitaryV2Mat] = svd(supp2lVec);
            [unitaryU3Mat, ~, unitaryV3Mat] = svd(supp3lVec);
            s2Mat = unitaryU1Mat * unitaryV1Mat * unitaryV2Mat.' * ...
                unitaryU2Mat.';
            s2Mat = real(s2Mat);
            s3Mat = unitaryU1Mat * unitaryV1Mat * unitaryV3Mat.' * ...
                unitaryU3Mat.';
            s3Mat = real(s3Mat);
            qStarMat = supp1Mat + s2Mat * supp2Mat + s3Mat * supp3Mat;
            analyticResMat = qStarMat' * qStarMat;
        end
            analyticResEllVec(1, iDir) = ellipsoid(analyticResVec, ...
                analyticResMat);
    end
end
function analyticResEllVec = calcExpMinkSum(isExtApx, nDirs, aMat, ...
    e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat)
    analyticResVec = e0Vec + e1Vec + e2Vec;
    analyticResEllVec(nDirs) = ellipsoid;
    for iDir = 1 : nDirs
        lVec = aMat(:, iDir);
        if isExtApx % minksum_ea
            a0Double = realsqrt(dot(lVec, e0Mat * lVec));
            a1Double = realsqrt(dot(lVec, e1Mat * lVec));
            a2Double = realsqrt(dot(lVec, e2Mat * lVec));
            analyticResMat = (a0Double + a1Double + a2Double) .* ...
                ( e0Mat ./ a0Double + e1Mat ./ a1Double + ...
                e2Mat ./ a2Double);
        else % minksum_ia
            supp1Mat = sqrtm(e0Mat);
            supp2Mat = sqrtm(e1Mat);
            supp3Mat = sqrtm(e2Mat);
            supp1lVec = supp1Mat * lVec;
            supp2lVec = supp2Mat * lVec;
            supp3lVec = supp3Mat * lVec;
            [unitaryU1Mat, ~, unitaryV1Mat] = svd(supp1lVec);
            [unitaryU2Mat, ~, unitaryV2Mat] = svd(supp2lVec);
            [unitaryU3Mat, ~, unitaryV3Mat] = svd(supp3lVec);
            s2Mat = unitaryU1Mat * unitaryV1Mat * unitaryV2Mat.' ...
                * unitaryU2Mat.';
            s2Mat = real(s2Mat);
            s3Mat = unitaryU1Mat * unitaryV1Mat * unitaryV3Mat.' * ...
                unitaryU3Mat.';
            s3Mat = real(s3Mat);
            qStarMat = supp1Mat + s2Mat * supp2Mat + s3Mat * supp3Mat;
            analyticResMat = qStarMat.' * qStarMat;
        end 
        analyticResEllVec(1, iDir) = ellipsoid(analyticResVec, analyticResMat);
    end
end
function compareForIsCII(test1EllVec, test2EllVec, myString, myResult)
    if isempty(myString)
        testRes = doesIntersectionContain(test1EllVec, test2EllVec);
    else
        testRes = doesIntersectionContain(test1EllVec, test2EllVec, 'mode', myString);
    end
    mlunitext.assert_equals(myResult, testRes);
end
function compareExpForIsBadDir(test1Ell, test2Ell, a1Mat, a2Mat,absTol)
    isTestResVec = isbaddirection(test1Ell, test2Ell, a1Mat,absTol);
    isTestRes = all(isTestResVec);
    mlunitext.assert_equals(true, isTestRes);
    isTestResVec = isbaddirection(test1Ell, test2Ell, a2Mat,absTol);
    isTestRes = any(isTestResVec);
    mlunitext.assert_equals(false, isTestRes);
end
function compareAnalyticForMinkMp(isEA, isHighDim, indTypicalExample, ...
    nDirs, nGoodDirs, myResult)
    if isHighDim % createTypicalHighDimEll
        [e0Vec, e0Mat, test0Ell, qVec, qMat, qEll, e1Vec, e1Mat, e2Vec, ...
            e2Mat, aEllVec] = createTypicalHighDimEll(indTypicalExample);
    else % createTypicalEll
        [e0Vec, e0Mat, test0Ell, qVec, qMat, qEll, e1Vec, e1Mat, ...
            e2Vec, e2Mat, aEllVec] = createTypicalEll(indTypicalExample);
    end
    aMat = diag(ones(1, nDirs));
    if isEA % minkmp_ea
        testRes = minkmp_ea(test0Ell, qEll, aEllVec, aMat);
    else % minkmp_ia
        testRes = minkmp_ia(test0Ell, qEll, aEllVec, aMat);
    end
    if ~isempty(myResult)
        analyticResEllVec = calcExpMinkMp(isEA, nGoodDirs, aMat, e0Vec, ...
            e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, qVec, qMat);
        [isEqVec, reportStr] = isEqual(analyticResEllVec, testRes);
        isEq = all(isEqVec);
        mlunitext.assert_equals(true, isEq, reportStr);
    else
        mlunitext.assert_equals(myResult, testRes);
    end
end
function compareAnalyticForMinkSum(isEA, isHighDim, indTypicalExample, ...
    nDirs, nGoodDirs, myResult)
    if isHighDim % createTypicalHighDimEll
        [e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, aEllVec] = ...
            createTypicalHighDimEll(indTypicalExample);
    else % createTypicalEll
        [e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, aEllVec] = ...
            createTypicalEll(indTypicalExample);
    end
    aMat = diag(ones(1, nDirs));
    if isEA % minksum_ea
        testRes = minksum_ea(aEllVec, aMat);
    else % minksum_ia
        testRes = minksum_ia(aEllVec, aMat);
    end
    if ~isHighDim && (indTypicalExample == 11)
        test0Ell = ellipsoid(e0Vec, e0Mat);
        analyticResEllVec = [test0Ell, test0Ell, test0Ell, test0Ell, ...
            test0Ell];
        [isEqVec, reportStr] = isEqual(analyticResEllVec, testRes);
        isEq = all(isEqVec);
        mlunitext.assert_equals(true, isEq, reportStr);
   else
        analyticResEllVec = calcExpMinkSum(isEA, nGoodDirs, aMat, e0Vec,...
            e0Mat, e1Vec, e1Mat, e2Vec, e2Mat);
        [isEqVec, reportStr] = isEqual(analyticResEllVec, testRes);
        isEq = all(isEqVec);
        mlunitext.assert_equals(myResult, isEq, reportStr);
    end
end
