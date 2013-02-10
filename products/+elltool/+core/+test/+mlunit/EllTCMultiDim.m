classdef EllTCMultiDim < mlunitext.test_case

% $Author: Igor Samokhin, Lomonosov Moscow State University,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 31-January-2013, <igorian.vmk@gmail.com>$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2013 $
    
    properties (Access=private)
        testDataRootDir
     end
     methods
        function self=EllTCMultiDim(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function self = testDimension(self)
            %Chek for one output argument
            %1: Empty ellipsoid
            [testEllArray ansNumArray] = createTypicalArray(1);
            testRes = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testRes);
            %2: Not empty ellipsoid
            [testEllArray ansNumArray, ~] = createTypicalArray(2);
            testRes = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testRes);
            
            [testEllArray ansNumArray, ~] = createTypicalArray(3);
            testRes = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testRes);
            
            %Chek for two output arguments
            %1: Empty ellipsoid
            [testEllArray ansNumArray] = createTypicalArray(1);
            [testDim, testRank] = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testDim);
            mlunit.assert_equals(ansNumArray, testRank);
            
            
            %2: Not empty ellipsoid
            [testEllArray ansNumArray, ~] = createTypicalArray(2);
            [testDim, testRank] = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testDim);
            mlunit.assert_equals(ansNumArray, testRank);
            
            [testEllArray ansNumArray, ~] = createTypicalArray(3);
            [testDim, testRank] = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testDim);
            mlunit.assert_equals(ansNumArray, testRank);
            
            [testEllArray ansDimNumArray ansRankNumArray, ~] = ...
                createTypicalArray(4);
            [testDim, testRank] = dimension(testEllArray);
            mlunit.assert_equals(ansDimNumArray, testDim);
            mlunit.assert_equals(ansRankNumArray, testRank);
            [testEllArray ansDimNumArray ansRankNumArray] = ...
                createTypicalArray(5);
            [testDim, testRank] = dimension(testEllArray);
            mlunit.assert_equals(ansDimNumArray, testDim);
            mlunit.assert_equals(ansRankNumArray, testRank);
        end
        function self = testIsDegenerate(self)
            %Empty ellipsoid
            [testEllArray ~] = createTypicalArray(1);
            self.runAndCheckError('isdegenerate(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Not degerate ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(6);
            isTestRes = isdegenerate(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            %Degenerate ellipsoids
            [testEllArray isAnsArray] = createTypicalArray(7);
            isTestRes = isdegenerate(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            [testEllArray isAnsArray] = createTypicalArray(8);
            isTestRes = isdegenerate(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
        end
        function self = testIsEmpty(self)
            %Chek realy empty ellipsoid
            
            [testEllArray isAnsArray] = createTypicalArray(9);
            isTestRes = isempty(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            %Chek not empty ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(6);
            isTestRes = isempty(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            [testEllArray isAnsArray] = createTypicalArray(10);
            isTestRes = isempty(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
        end
        function self = testMaxEig(self)
            %Check empty ellipsoid
            [testEllArray ~] = createTypicalArray(1);
            self.runAndCheckError('maxeig(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(11);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~] = createTypicalArray(2);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ansNumArray, ~, ~] = createTypicalArray(12);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on not diaganal matrix
            [testEllArray, ansNumArray, ~, ~] = createTypicalArray(13);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
        end
        function self = testMinEig(self)
            %Check empty ellipsoid
            [testEllArray ~] = createTypicalArray(1);
            self.runAndCheckError('mineig(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(11);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~] = createTypicalArray(2);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ~, ansNumArray, ~] = createTypicalArray(12);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on not diaganal matrix
            [testEllArray, ~, ansNumArray, ~] = createTypicalArray(13);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
        end
        function self = testTrace(self)
            %Empty ellipsoid
            [testEllArray ~] = createTypicalArray(1);
            self.runAndCheckError('trace(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(11);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~] = createTypicalArray(2);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ~, ~, ansNumArray] = createTypicalArray(12);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on not diaganal matrix
            [testEllArray, ~, ~, ansNumArray] = createTypicalArray(13);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
        end
        function self = testVolume(self)
            %Empty ellipsoid
            [testEllArray ~] = createTypicalArray(1);
            self.runAndCheckError('volume(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate ellipsoid
            [testEllArray, ~, ~, ansDoubleArray] = createTypicalArray(4);
            [testDoubleArray] = volume(testEllArray);
            mlunit.assert_equals(ansDoubleArray, testDoubleArray);
            
            %Check dim=1 with two different centers
            [testEllArray, ~, ansDoubleArray] = createTypicalArray(2);
            [testDoubleArray] = volume(testEllArray);
            mlunit.assert_equals(ansDoubleArray, testDoubleArray);
            
            [testEllArray, ~, ansDoubleArray] = createTypicalArray(3);
            [testDoubleArray] = volume(testEllArray);
            mlunit.assert_equals(ansDoubleArray, testDoubleArray);
        end
%         function self = testNe(self)
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testEllipsoidZeros2 testEllipsoidZeros3 ...
%                 testEllipsoidEmpty] = createTypicalEll(1);
%             [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(1);
%             
%             testRes = ne(testEllHighDim1, testEllHighDim1);
%             mlunit.assert_equals(0, testRes);
%             
%             testRes = ne(testEllHighDim1, testEllHighDim2);
%             mlunit.assert_equals(1, testRes);
%             
%             [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(2);
%             
%             testRes = ne(testEllHighDim1, testEllHighDim1);
%             mlunit.assert_equals(0, testRes);
%             
%             testRes = ne(testEllHighDim1, testEllHighDim2);
%             mlunit.assert_equals(1, testRes);
%             
%             [testEllHighDim1 testEllHighDim2] = createTypicalHighDimEll(3);
%             
%             testRes = ne(testEllHighDim1, testEllHighDim1);
%             mlunit.assert_equals(0, testRes);
%             
%             testRes = ne(testEllHighDim1, testEllHighDim2);
%             mlunit.assert_equals(1, testRes);
%             
%             testRes = ne(testEllipsoid1, testEllipsoid1);
%             mlunit.assert_equals(0, testRes);
%                         
%             testRes = ne(testEllipsoid2, testEllipsoid1);
%             mlunit.assert_equals(1, testRes);    
%                   
%             testRes = ne(testEllipsoid3, testEllipsoid2);
%             mlunit.assert_equals(1, testRes);
%                        
%             testRes = ne(testEllipsoidZeros2, testEllipsoidZeros3);
%             mlunit.assert_equals(1, testRes);
%             
%             testRes = ne(testEllipsoidZeros2, testEllipsoidEmpty);
%             mlunit.assert_equals(1, testRes);
%            
%             testRes = ne(testEllipsoidEmpty, testEllipsoidEmpty);
%             mlunit.assert_equals(0, testRes);
%             
%             testRes = ne([testEllipsoidZeros2 testEllipsoidZeros3], [testEllipsoidZeros3 testEllipsoidZeros3]);
%             if (testRes == [1 0])
%                 testRes = 1;
%             else 
%                 testRes = 0;
%             end
%             mlunit.assert_equals(1, testRes);
%         end
     end
end
function [varargout] = createTypicalArray(flag)
    switch flag
        case 1
            arraySize = [2, 1, 3, 2, 1, 1, 4];
            myEllArray(2, 1, 3, 2, 1, 1, 4) = ellipsoid;
            ansNumArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansNumArray;
        case 2
            arraySize = [1, 2, 4, 3, 2, 1];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                1, 1, 1);
            ansNumArray = createObjectArray(arraySize, @diag, ...
                1, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySize, @diag, ...
                2, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
        case 3
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                eye(5), 1, 1);
            ansNumArray = createObjectArray(arraySize, @diag, ...
                5, 1, 1);
            volumeDouble = 8 * (pi ^ 2) / 15;
            ansVolumeDoubleArray = createObjectArray(arraySize, @diag, ...
                volumeDouble, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
        case 4
            arraySize = [2, 1, 3, 2, 1, 1, 4, 1, 1];
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            ansDimNumArray = createObjectArray(arraySize, @diag, ...
                5, 1, 1);
            ansRankNumArray = createObjectArray(arraySize, @diag, ...
                4, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansDimNumArray;
            varargout{3} = ansRankNumArray;
            varargout{4} = ansVolumeDoubleArray;
        case 5
            arraySize = [2, 1, 1, 2, 3, 3, 1, 1];
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            ansDimNumArray = createObjectArray(arraySize, @diag, ...
                100, 1, 1);
            ansRankNumArray = createObjectArray(arraySize, @diag, ...
                50, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansDimNumArray;
            varargout{3} = ansRankNumArray;
        case 6
            arraySize = [1, 2, 4, 3, 2];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                1, 1, 1);
            isAnsArray = createObjectArray(arraySize, @false, ...
                1, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = isAnsArray;
        case 7
            arraySize = [2, 1, 1, 1, 3, 1, 1];
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            isAnsArray = createObjectArray(arraySize, @true, ...
                1, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = isAnsArray;
        case 8
            arraySize = [1, 1, 2, 3, 1, 2, 1];
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySize, @true, ...
                1, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = isAnsArray;
        case 9
            arraySize = [2, 1, 1, 1, 1, 3, 1, 1];
            myEllArray(2, 1, 1, 1, 1, 3, 1, 1) = ellipsoid;
            isAnsArray = createObjectArray(arraySize, @true, ...
                1, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = isAnsArray;
        case 10
            arraySize = [1, 1, 1, 1, 1, 4, 1, 1, 3];
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySize, @false, ...
                1, 1, 1);
            myEllArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = ellipsoid;
            isAnsArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = true;
            varargout{1} = myEllArray;
            varargout{2} = isAnsArray;
        case 11
            arraySize = [1, 1, 2, 3, 2, 1, 1, 1, 4];
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag(zeros(1, 100)), 1, 1);
            ansNumArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansNumArray;
        case 12
            arraySize = [2, 3, 2, 1, 1, 1, 4, 1, 1];
            myMat = diag(0 : 1 : 100);
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySize, @diag, ...
                100, 1, 1);
            ansMinNumArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            ansTraceNumArray = createObjectArray(arraySize, @diag, ...
                sum(0 : 1 : 100), 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        case 13
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myMat = rand(10);
            myMat = myMat * myMat.';
            myEllArray = createObjectArray(arraySize, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySize, @diag, ...
                max(eig(myMat)), 1, 1);
            ansMinNumArray = createObjectArray(arraySize, @diag, ...
                min(eig(myMat)), 1, 1);
            ansTraceNumArray = createObjectArray(arraySize, @diag, ...
                trace(myMat), 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        
            
            
            %             case 12
%             arraySize = [1, 2, 2, 3, 1, 4];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 2, 1, 1);
%             varargout{1} = myEllArray;
%             varargout{2} = 1.1 * eye(2);
%         case 13
%             arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 5, 1, 1);
%             varargout{1} = myEllArray;
%             varargout{2} = 0.9 * eye(5);
%         case 14
%             arraySize = [2, 1, 2, 1, 3, 3];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 4, 1, 1);
%             myMat = 0.9 * eye(4);
%             myMat = [myMat, 1.1 * eye(4)];
%             varargout{1} = myEllArray;
%             varargout{2} = myMat;
%         case 15
%             myMat = eye(4);
%             arraySize = [2, 1, 2, 1, 3, 3];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 4, 1, 1);
%             myEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
%             myEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
%             myEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', myMat);
%             myEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', myMat);
%             myEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
%             myEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
%             myEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
%             myEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
%             myMat = [0.9 * eye(4), 1.9 * eye(4), zeros(4, 1)];
%             varargout{1} = myEllArray;
%             varargout{2} = myMat;
%         case 16
%             arraySize = [2, 2, 3, 1, 1, 1, 4];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 3, 1, 1);
%             myHpArray = createObjectArray(arraySize, @hyperplane, ... 
%                 [0, 0, 1].', 0, 2);
%             ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
%                 [1, 0, 0; 0, 1, 0; 0, 0, 0], 1, 1);
%             varargout{1} = myEllArray;
%             varargout{2} = myHpArray;    
%             varargout{3} = ansEllArray;
%         case 17
%             arraySize = [1, 2, 2, 3, 1, 4];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 2, 1, 1);
%             myHpArray = createObjectArray(arraySize, @hyperplane, ... 
%                 [0, 1].', 0, 2);
%             ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
%                 [1, 0; 0, 0], 1, 1);
%             varargout{1} = myEllArray;
%             varargout{2} = myHpArray;    
%             varargout{3} = ansEllArray;
%         case 18
%             arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 4, 1, 1);
%             myHpArray = createObjectArray(arraySize, @hyperplane, ... 
%                 [0, 0, 0, 1].', 0, 2);
%             ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
%                 [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 0], 1, 1);
%             varargout{1} = myEllArray;
%             varargout{2} = myHpArray;    
%             varargout{3} = ansEllArray;
%             varargout{4} = false(1, 1, 1, 1, 1, 7, 1, 1, 7);
%         case 19
%             myMat = diag(ones(1, 4));
%             arraySize = [2, 1, 1, 3, 3, 3];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 4, 1, 1);
%             myEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
%             myEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
%             myEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', myMat);
%             myEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', myMat);
%             myEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
%             myEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
%             myEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
%             myEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
%             myHpArray = createObjectArray(arraySize, @hyperplane, ... 
%                 [0, 0, 1, 0].', 0, 2);
%             myMat = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 0, 0; 0, 0, 0, 1];
%             ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
%                 myMat, 1, 1);
%             ansEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
%             ansEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
%             ansEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 0 0].', ...
%                 diag( zeros(1, 4)));
%             ansEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 0 0].', zeros(4));
%             ansEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
%             ansEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
%             ansEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
%             ansEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
%             varargout{1} = myEllArray;
%             varargout{2} = myHpArray;    
%             varargout{3} = ansEllArray;
%         case 20
%             arraySize = [2, 2, 3, 1, 1, 1, 4];
%             myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
%                 3, 1, 1);
%             myHpArray = createObjectArray(arraySize, @hyperplane, ... 
%                 [0, 0, 1].', -2, 2);
%             varargout{1} = myEllArray;
%             varargout{2} = myHpArray;    
%             varargout{3} = 'degenerateEllipsoid';
        otherwise
    end
end
function objectArray = createObjectArray(arraySize, func, firstArg, ...
    secondArg, nArg)
    nElems = prod(arraySize, 2);
    switch nArg
        case 0 
            objectCArray = cellfun(func, ...
                'UniformOutput', false);
        case 1
            firstArgCArray = repmat({firstArg}, 1, nElems);
            objectCArray = cellfun(func, firstArgCArray, ...
                'UniformOutput', false);
        case 2
            firstArgCArray = repmat({firstArg}, 1, nElems);
            secondArgCArray = repmat({secondArg}, 1, nElems);
            objectCArray = cellfun(func, firstArgCArray, secondArgCArray, ...
                'UniformOutput', false);
        otherwise
    end
    objectArray = reshape([objectCArray{:}], arraySize);
end