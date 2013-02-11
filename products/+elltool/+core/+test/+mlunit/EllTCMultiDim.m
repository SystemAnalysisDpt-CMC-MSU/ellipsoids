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
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(1);
            testRes = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testRes);
            %2: Not empty ellipsoid
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
            testRes = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testRes);
            
            [testEllArray ansNumArray, ~] = createTypicalArray(3);
            testRes = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testRes);
            
            %Chek for two output arguments
            %1: Empty ellipsoid
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(1);
            [testDim, testRank] = dimension(testEllArray);
            mlunit.assert_equals(ansNumArray, testDim);
            mlunit.assert_equals(ansNumArray, testRank);
            
            
            %2: Not empty ellipsoid
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
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
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
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
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('maxeig(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(11);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
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
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('mineig(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(11);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
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
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('trace(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(11);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
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
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('volume(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate ellipsoid
            [testEllArray, ~, ~, ansDoubleArray] = createTypicalArray(4);
            [testDoubleArray] = volume(testEllArray);
            mlunit.assert_equals(ansDoubleArray, testDoubleArray);
            
            %Check dim=1 with two different centers
            [testEllArray, ~, ansDoubleArray, ~] = createTypicalArray(2);
            [testDoubleArray] = volume(testEllArray);
            mlunit.assert_equals(ansDoubleArray, testDoubleArray);
            
            [testEllArray, ~, ansDoubleArray] = createTypicalArray(3);
            [testDoubleArray] = volume(testEllArray);
            mlunit.assert_equals(ansDoubleArray, testDoubleArray);
        end
        function self = testEq(self)
            [test1EllArray, ~, ansLogicalArray, ~] = createTypicalArray(1);
            [test2EllArray, ~, ~, ~] = createTypicalArray(1);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, '');

            [test1EllArray, ~, ~, ~] = createTypicalArray(2);
            [test2EllArray, ~, ~, ansLogicalArray] = createTypicalArray(2);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, '');
            
            [test1EllArray, test2EllArray, ansLogicalArray] = ...
                createTypicalArray(14);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, '');
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.eq(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.eq(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, reportStr] = ...
                createTypicalArray(15);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, reportStr);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.eq(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.eq(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, reportStr, ~] = ...
                createTypicalArray(16);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, reportStr);

            [test1EllArray, test2EllArray, ansLogicalArray, reportStr] = ...
                createTypicalArray(17);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, reportStr);
        end
        function self = testNe(self)
            [test1EllArray, ~, ansLogicalArray, ~] = createTypicalArray(1);
            [test2EllArray, ~, ~, ~] = createTypicalArray(1);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            

            [test1EllArray, ~, ~, ~] = createTypicalArray(2);
            [test2EllArray, ~, ~, ansLogicalArray] = createTypicalArray(2);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, ansLogicalArray] = ...
                createTypicalArray(14);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.ne(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.ne(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(15);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.ne(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.ne(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~, ~] = ...
                createTypicalArray(16);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(17);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
        end
        function self = testGe(self)
            [test1EllArray, ~, ~, errorStr] = createTypicalArray(1);
            [test2EllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('ge(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, ~, ~, ~] = createTypicalArray(2);
            [test2EllArray, ~, ~, ansLogicalArray] = createTypicalArray(2);
            testResArray = ge(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, ansLogicalArray] = ...
                createTypicalArray(14);
            testResArray = ge(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.ge(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.ge(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(15);
            testResArray = ge(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.ge(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.ge(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(16);
            self.runAndCheckError('ge(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(17);
            testResArray = ge(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
        end 
        function self = testGt(self)
            [test1EllArray, ~, ~, errorStr] = createTypicalArray(1);
            [test2EllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('gt(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, ~, ~, ~] = createTypicalArray(2);
            [test2EllArray, ~, ~, ansLogicalArray] = createTypicalArray(2);
            testResArray = gt(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, ansLogicalArray] = ...
                createTypicalArray(14);
            testResArray = gt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.gt(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.gt(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(15);
            testResArray = gt(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.gt(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.gt(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(16);
            self.runAndCheckError('gt(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(17);
            testResArray = gt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
        end
        function self = testLt(self)
            [test1EllArray, ~, ~, errorStr] = createTypicalArray(1);
            [test2EllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('lt(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, ~, ~, ~] = createTypicalArray(2);
            [test2EllArray, ~, ~, ansLogicalArray] = createTypicalArray(2);
            testResArray = lt(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, ansLogicalArray] = ...
                createTypicalArray(14);
            testResArray = lt(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.lt(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.lt(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(15);
            testResArray = lt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.lt(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.lt(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(16);
            self.runAndCheckError('lt(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(17);
            testResArray = lt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
        end
        function self = testLe(self)
            [test1EllArray, ~, ~, errorStr] = createTypicalArray(1);
            [test2EllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('le(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, ~, ~, ~] = createTypicalArray(2);
            [test2EllArray, ~, ~, ansLogicalArray] = createTypicalArray(2);
            testResArray = le(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, ansLogicalArray] = ...
                createTypicalArray(14);
            testResArray = le(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.le(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.le(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(15);
            testResArray = le(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.le(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.le(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(16);
            self.runAndCheckError('le(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(17);
            testResArray = le(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
        end
    end
end
function [varargout] = createTypicalArray(flag)
    switch flag
        case 1
            arraySize = [2, 1, 3, 2, 1, 1, 4];
            myEllArray(2, 1, 3, 2, 1, 1, 4) = ellipsoid;
            ansNumArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            ansLogicalArray = true(arraySize);
            errorStr = 'emptyEllipsoid';
            varargout{1} = myEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansLogicalArray;
            varargout{4} = errorStr;
        case 2
            arraySize = [1, 2, 4, 3, 2, 1];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                1, 1, 1);
            ansNumArray = createObjectArray(arraySize, @diag, ...
                1, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySize, @diag, ...
                2, 1, 1);
            ansLogicalArray = true(arraySize);
            varargout{1} = myEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
            varargout{4} = ansLogicalArray;
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
        case 14
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            my1EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                2, 1, 1);
            my2EllArray = createObjectArray(arraySize, @ellipsoid, ... 
                diag([1 + MAX_TOL, 1 + MAX_TOL]) , 1, 1);
            ansLogicalArray = true(arraySize);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = ansLogicalArray;
        case 15
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySize = [1, 1, 2, 1, 1, 1, 2, 1, 1];
            my1EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                5, 1, 1);
            my2EllArray = createObjectArray(arraySize, @ellipsoid, ... 
                diag(repmat(1 + 100 * MAX_TOL, 1, 5)), 1, 1);
            ansLogicalArray = false(arraySize);
            reportStr = sprintf('(1).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)\n(2).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)\n(3).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)\n(4).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)');
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = ansLogicalArray;
            varargout{4} = reportStr;            
        case 16
            arraySize = [1, 1, 3, 1, 1, 1, 2, 1, 1];
            my1EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                5, 1, 1);
            my2EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            ansLogicalArray = false(arraySize);
            report1Str = sprintf('(1).Q-->Different sizes (left: [5 5], right: [4 4])\n(1).q-->Different sizes (left: [1 5], right: [1 4])\n(2).Q-->Different sizes (left: [5 5], right: [4 4])\n(2).q-->Different sizes (left: [1 5], right: [1 4])\n(3).Q-->Different sizes (left: [5 5], right: [4 4])\n(3).q-->Different sizes (left: [1 5], right: [1 4])\n(4).Q-->Different sizes (left: [5 5], right: [4 4])\n(4).q-->Different sizes (left: [1 5], right: [1 4])\n(5).Q-->Different sizes (left: [5 5], right: [4 4])\n(5).q-->Different sizes (left: [1 5], right: [1 4])\n(6).Q-->Different sizes (left: [5 5], right: [4 4])\n(6).q-->Different sizes (left: [1 5], right: [1 4])');
            report2Str = 'wrongInput';
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = ansLogicalArray;
            varargout{4} = report1Str;
            varargout{5} = report2Str;
        case 17
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySize = [1, 1, 2, 1, 1, 1, 1, 1, 2];
            my1EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                10, 1, 1);
            my2EllArray = createObjectArray(arraySize, @ellipsoid, ... 
                (2 * MAX_TOL) * ones(10, 1), eye(10), 2);
            ansLogicalArray = false(arraySize);
            reportStr = sprintf('(1).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)\n(2).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)\n(3).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)\n(4).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)');
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = ansLogicalArray;
            varargout{4} = reportStr;          
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
function checkEllEqual(testEll1Vec, testEll2Vec, isEqual, ansStr)
    [isEqArray, reportStr] = eq(testEll1Vec, testEll2Vec);
    mlunit.assert_equals(isEqArray, isEqual);
    mlunit.assert_equals(reportStr, ansStr);
end