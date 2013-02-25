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
            
            arraySize = [2, 1, 1, 2, 3, 3, 1, 1];
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            ansDimNumArray = createObjectArray(arraySize, @diag, ...
                100, 1, 1);
            ansRankNumArray = createObjectArray(arraySize, @diag, ...
                50, 1, 1);
            [testDim, testRank] = dimension(testEllArray);
            mlunit.assert_equals(ansDimNumArray, testDim);
            mlunit.assert_equals(ansRankNumArray, testRank);
        end
        function self = testIsDegenerate(self)
            %Empty ellipsoid
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('isdegenerate(testEllArray)', ...
                'wrongInput:emptyEllipsoid');
            
            %Not degerate ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(5);
            isTestRes = isdegenerate(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            %Degenerate ellipsoids
            arraySize = [2, 1, 1, 1, 3, 1, 1];
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            isAnsArray = createObjectArray(arraySize, @true, ...
                1, 1, 1);
            isTestRes = isdegenerate(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            arraySize = [1, 1, 2, 3, 1, 2, 1];
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySize, @true, ...
                1, 1, 1);
            isTestRes = isdegenerate(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            [testEllArray, ~, errorStr] = createTypicalArray(13);
            self.runAndCheckError('isdegenerate(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(14);
            self.runAndCheckError('isdegenerate(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(15);
            self.runAndCheckError('isdegenerate(testEllArray)', errorStr);
        end
        function self = testIsEmpty(self)
            %Chek realy empty ellipsoid
            
            arraySize = [2, 1, 1, 1, 1, 3, 1, 1];
            testEllArray(2, 1, 1, 1, 1, 3, 1, 1) = ellipsoid;
            isAnsArray = createObjectArray(arraySize, @true, ...
                1, 1, 1);
            isTestRes = isempty(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            %Chek not empty ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(5);
            isTestRes = isempty(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
            
            arraySize = [1, 1, 1, 1, 1, 4, 1, 1, 3];
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySize, @false, ...
                1, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = ellipsoid;
            isAnsArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = true;
            isTestRes = isempty(testEllArray);
            mlunit.assert_equals(isAnsArray, isTestRes);
        end
        function self = testMaxEig(self)
            %Check empty ellipsoid
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('maxeig(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(6);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ansNumArray, ~, ~] = createTypicalArray(7);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on not diaganal matrix
            [testEllArray, ansNumArray, ~, ~] = createTypicalArray(8);
            [testNumArray] = maxeig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
%             [testEllArray, ~, errorStr] = createTypicalArray(13);
%             a = maxeig(testEllArray);
            [testEllArray, ~, errorStr] = createTypicalArray(14);
            self.runAndCheckError('maxeig(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(15);
            self.runAndCheckError('maxeig(testEllArray)', errorStr);
        end
        function self = testMinEig(self)
            %Check empty ellipsoid
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('mineig(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(6);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ~, ansNumArray, ~] = createTypicalArray(7);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on not diaganal matrix
            [testEllArray, ~, ansNumArray, ~] = createTypicalArray(8);
            [testNumArray] = mineig(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ~, errorStr] = createTypicalArray(14);
            self.runAndCheckError('mineig(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(15);
            self.runAndCheckError('mineig(testEllArray)', errorStr);
        end
        function self = testTrace(self)
            %Empty ellipsoid
            [testEllArray, ~, ~, ~] = createTypicalArray(1);
            self.runAndCheckError('trace(testEllArray)','wrongInput:emptyEllipsoid');
            
            %Check degenerate matrix
            [testEllArray ansNumArray] = createTypicalArray(6);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on diaganal matrix
            [testEllArray ansNumArray, ~, ~] = createTypicalArray(2);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ~, ~, ansNumArray] = createTypicalArray(7);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            %Check on not diaganal matrix
            [testEllArray, ~, ~, ansNumArray] = createTypicalArray(8);
            [testNumArray] = trace(testEllArray);
            mlunit.assert_equals(ansNumArray, testNumArray);
            
            [testEllArray, ~, errorStr] = createTypicalArray(14);
            self.runAndCheckError('trace(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(15);
            self.runAndCheckError('trace(testEllArray)', errorStr);
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
            
            [testEllArray, ~, errorStr] = createTypicalArray(14);
            self.runAndCheckError('volume(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(15);
            self.runAndCheckError('volume(testEllArray)', errorStr);
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
                createTypicalArray(9);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, '');
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.eq(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.eq(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, reportStr] = ...
                createTypicalArray(10);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, reportStr);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.eq(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.eq(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, reportStr, ~] = ...
                createTypicalArray(11);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, reportStr);

            [test1EllArray, test2EllArray, ansLogicalArray, reportStr] = ...
                createTypicalArray(12);
            checkEllEqual(test1EllArray, test2EllArray, ...
                ansLogicalArray, reportStr);
            
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('eq(test1EllArray, test2EllArray)', ...
                errorStr);
            self.runAndCheckError('eq(test2EllArray, test1EllArray)', ... 
                errorStr);
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
                createTypicalArray(9);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.ne(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.ne(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(10);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.ne(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.ne(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~, ~] = ...
                createTypicalArray(11);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(12);
            testResArray = ne(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('eq(test1EllArray, test2EllArray)', ...
                errorStr);
            self.runAndCheckError('eq(test2EllArray, test1EllArray)', ... 
                errorStr);
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
                createTypicalArray(9);
            testResArray = ge(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.ge(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.ge(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(10);
            testResArray = ge(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.ge(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.ge(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(11);
            self.runAndCheckError('ge(test1EllArray, test2EllArray)', ...
                errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(12);
            testResArray = ge(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('ge(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(14);
            self.runAndCheckError('ge(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(15);
            self.runAndCheckError('ge(test1EllArray, test2EllArray)', ...
                errorStr);
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
                createTypicalArray(9);
            testResArray = gt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.gt(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.gt(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(10);
            testResArray = gt(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.gt(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.gt(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(11);
            self.runAndCheckError('gt(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(12);
            testResArray = gt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('gt(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(14);
            self.runAndCheckError('gt(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(15);
            self.runAndCheckError('gt(test1EllArray, test2EllArray)', ...
                errorStr);
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
                createTypicalArray(9);
            testResArray = lt(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.lt(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.lt(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(10);
            testResArray = lt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.lt(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.lt(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(11);
            self.runAndCheckError('lt(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(12);
            testResArray = lt(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('lt(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(14);
            self.runAndCheckError('lt(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(15);
            self.runAndCheckError('lt(test1EllArray, test2EllArray)', ...
                errorStr);
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
                createTypicalArray(9);
            testResArray = le(test1EllArray, test2EllArray);
            mlunit.assert_equals(ansLogicalArray, testResArray);
            mlunit.assert_equals(ansLogicalArray, ...
                test1EllArray.le(test2EllArray));
            mlunit.assert_equals(~ansLogicalArray, ...
                test2EllArray.le(test1EllArray));
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~] = ...
                createTypicalArray(10);
            testResArray = le(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            mlunit.assert_equals(~ansLogicalArray, ...
                test1EllArray.le(test2EllArray));
            mlunit.assert_equals(ansLogicalArray, ...
                test2EllArray.le(test1EllArray));
            
            [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                createTypicalArray(11);
            self.runAndCheckError('le(test1EllArray, test2EllArray)', errorStr);
            
            [test1EllArray, test2EllArray, ansLogicalArray, ~]= ...
                createTypicalArray(12);
            testResArray = le(test1EllArray, test2EllArray);
            mlunit.assert_equals(~ansLogicalArray, testResArray);
            
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('le(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(14);
            self.runAndCheckError('le(test1EllArray, test2EllArray)', ...
                errorStr);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(15);
            self.runAndCheckError('le(test1EllArray, test2EllArray)', ...
                errorStr);
        end
        function self = testPropertyGetters(self)
            arraySize = [1, 1, 2, 1, 1, 1, 1, 1, 2, 1];
            ellCenter = ones(10, 1);
            ellMat = rand(10);
            ellMat = ellMat * ellMat.';
            testAbsTol = 3;
            testRelTol = 0.4;
            testNPlot2dPoints = 40;
            testNPlot3dPoints = 100;
            args = {ellCenter, ellMat, 'absTol', testAbsTol, 'relTol', ...
                testRelTol, 'nPlot2dPoints', testNPlot2dPoints,...
                'nPlot3dPoints', testNPlot3dPoints};
            testEllArray(1, 1, 1, 1, 1, 1, 1, 1, 1, 1) = ellipsoid(args{:});
            testEllArray(1, 1, 1, 1, 1, 1, 1, 1, 2, 1) = ellipsoid(args{:});
            testEllArray(1, 1, 2, 1, 1, 1, 1, 1, 1, 1) = ellipsoid(args{:});
            testEllArray(1, 1, 2, 1, 1, 1, 1, 1, 2, 1) = ellipsoid(args{:});
            testAbsTolArray = createObjectArray(arraySize, @repmat, ... 
                testAbsTol, 1, 2);
            testRelTolArray = createObjectArray(arraySize, @repmat, ... 
                testRelTol, 1, 2);
            testNPlot2dPointsArray = createObjectArray(arraySize, @repmat, ... 
                testNPlot2dPoints, 1, 2);
            testNPlot3dPointsArray = createObjectArray(arraySize, @repmat, ... 
                testNPlot3dPoints, 1, 2);
            mlunit.assert_equals(testAbsTolArray, testEllArray.getAbsTol());
            mlunit.assert_equals(testRelTolArray, testEllArray.getRelTol());
            mlunit.assert_equals(testNPlot2dPointsArray, ...
                testEllArray.getNPlot2dPoints());
            mlunit.assert_equals(testNPlot3dPointsArray, ...
                testEllArray.getNPlot3dPoints());
        end
    end
end
function [varargout] = createTypicalArray(flag)
    arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
    switch flag
        case 1
            arraySize = [2, 1, 3, 2, 1, 1, 4];
            testEllArray(2, 1, 3, 2, 1, 1, 4) = ellipsoid;
            ansNumArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            ansLogicalArray = true(arraySize);
            errorStr = 'emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansLogicalArray;
            varargout{4} = errorStr;
        case 2
            arraySize = [1, 2, 4, 3, 2, 1];
            testEllArray = createObjectArray(arraySize, @ell_unitball, ...
                1, 1, 1);
            ansNumArray = createObjectArray(arraySize, @diag, ...
                1, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySize, @diag, ...
                2, 1, 1);
            ansLogicalArray = true(arraySize);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
            varargout{4} = ansLogicalArray;
        case 3
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                eye(5), 1, 1);
            ansNumArray = createObjectArray(arraySize, @diag, ...
                5, 1, 1);
            volumeDouble = 8 * (pi ^ 2) / 15;
            ansVolumeDoubleArray = createObjectArray(arraySize, @diag, ...
                volumeDouble, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
        case 4
            arraySize = [2, 1, 3, 2, 1, 1, 4, 1, 1];
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            ansDimNumArray = createObjectArray(arraySize, @diag, ...
                5, 1, 1);
            ansRankNumArray = createObjectArray(arraySize, @diag, ...
                4, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansDimNumArray;
            varargout{3} = ansRankNumArray;
            varargout{4} = ansVolumeDoubleArray;
        case 5
            arraySize = [1, 2, 4, 3, 2];
            testEllArray = createObjectArray(arraySize, @ell_unitball, ...
                1, 1, 1);
            isAnsArray = createObjectArray(arraySize, @false, ...
                1, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = isAnsArray;
        case 6
            arraySize = [1, 1, 2, 3, 2, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                diag(zeros(1, 100)), 1, 1);
            ansNumArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
        case 7
            arraySize = [2, 3, 2, 1, 1, 1, 4, 1, 1];
            myMat = diag(0 : 1 : 100);
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySize, @diag, ...
                100, 1, 1);
            ansMinNumArray = createObjectArray(arraySize, @diag, ...
                0, 1, 1);
            ansTraceNumArray = createObjectArray(arraySize, @diag, ...
                sum(0 : 1 : 100), 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        case 8
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myMat = rand(10);
            myMat = myMat * myMat.';
            testEllArray = createObjectArray(arraySize, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySize, @diag, ...
                max(eig(myMat)), 1, 1);
            ansMinNumArray = createObjectArray(arraySize, @diag, ...
                min(eig(myMat)), 1, 1);
            ansTraceNumArray = createObjectArray(arraySize, @diag, ...
                trace(myMat), 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        case 9
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
        case 10
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
        case 11
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
        case 12
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
        case 13
            testEllArray = ellipsoid.empty(1, 0, 0, 1, 5);
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyArray';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 14
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            testEllArray(2, 1, 1, 2, 1, 3, 1) = ellipsoid;
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 15
            testEllArray = createObjectArray(arraySizeVec, @(x)ellipsoid(), ...
                3, 1, 1);
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
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
function checkEllEqual(test1EllArray, test2EllArray, isEqual, ansStr)
    [isEqArray, reportStr] = eq(test1EllArray, test2EllArray);
    mlunit.assert_equals(isEqArray, isEqual);
    mlunit.assert_equals(reportStr, ansStr);
end