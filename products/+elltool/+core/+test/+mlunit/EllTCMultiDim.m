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
            testCorrect(true, true, 1);
            %2: Not empty ellipsoid
            testCorrect(true, true, 2);
            testCorrect(true, true, 3);
            %Chek for two output arguments
            %1: Empty ellipsoid
            testCorrect(true, false, 1);
            %2: Not empty ellipsoid
            testCorrect(true, false, 2);
            testCorrect(true, false, 3);
            testCorrect(false, false, 4);
            arraySizeVec = [2, 1, 1, 2, 3, 3, 1, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            ansDimNumArray = createObjectArray(arraySizeVec, @diag, ...
                100, 1, 1);
            ansRankNumArray = createObjectArray(arraySizeVec, @diag, ...
                50, 1, 1);
            test2Correct();
            testCorrect(true, true, 16);
            testCorrect(true, false, 16);
            function testCorrect(isTwoArg, isnRankParam, flag)
                if isTwoArg
                    [testEllArray ansNumArray, ~] = createTypicalArray(flag);
                    if isnRankParam
                        testRes = dimension(testEllArray);
                        mlunit.assert_equals(ansNumArray, testRes);
                        if (flag == 16)
                           mlunit.assert_equals(class(ansNumArray), ...
                               class(testRes)); 
                        end
                    else
                        [testDim, testRank] = dimension(testEllArray);
                        mlunit.assert_equals(ansNumArray, testDim);
                        mlunit.assert_equals(ansNumArray, testRank);
                        if (flag == 16)
                           mlunit.assert_equals(class(ansNumArray), ...
                               class(testDim)); 
                           mlunit.assert_equals(class(ansNumArray), ...
                               class(testRank)); 
                        end
                    end
                else
                    [testEllArray ansDimNumArray ansRankNumArray, ~] = ...
                        createTypicalArray(flag);
                    test2Correct();
                end
            end
            function test2Correct()
                [testDim, testRank] = dimension(testEllArray);
                mlunit.assert_equals(ansDimNumArray, testDim);
                mlunit.assert_equals(ansRankNumArray, testRank);
            end
            
        end
        function self = testIsDegenerate(self)
            %Not degerate ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(5);
            testCorrect()
            %Degenerate ellipsoids
            arraySizeVec = [2, 1, 1, 1, 3, 1, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @true, ...
                1, 1, 1);
            testCorrect()
            arraySizeVec = [1, 1, 2, 3, 1, 2, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @true, ...
                1, 1, 1);
            testCorrect()
            mlunit.assert_equals(class(isAnsArray), class(isTestRes)); 
            [testEllArray, ~, isAnsArray] = createTypicalArray(16);
            testCorrect()
            mlunit.assert_equals(class(isAnsArray), class(isTestRes)); 
            %Empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect()
                isTestRes = isdegenerate(testEllArray);
                mlunit.assert_equals(isAnsArray, isTestRes);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.isdegenerate()', ...
                        'wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.isdegenerate()',...
                        errorStr);
                end
           end
        end
        function self = testIsEmpty(self)
            %Chek realy empty ellipsoid            
            arraySizeVec = [2, 1, 1, 1, 1, 3, 1, 1];
            testEllArray(2, 1, 1, 1, 1, 3, 1, 1) = ellipsoid;
            isAnsArray = createObjectArray(arraySizeVec, @true, ...
                1, 1, 1);
            testCorrect()
            %Chek not empty ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(5);
            testCorrect()
            arraySizeVec = [1, 1, 1, 1, 1, 4, 1, 1, 3];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @false, ...
                1, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = ellipsoid;
            isAnsArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = true;
            testCorrect()
            [testEllArray, ~, isAnsArray] = createTypicalArray(16);
            testCorrect()
            mlunit.assert_equals(class(isAnsArray), class(isTestRes)); 
            function testCorrect()
                isTestRes = isempty(testEllArray);
                mlunit.assert_equals(isAnsArray, isTestRes);
            end
        end
        function self = testMaxEig(self)
            %Check degenerate matrix
            testCorrect(6);
            testCorrect(2);
            testCorrect(7);
            testCorrect(8);
            testCorrect(16);
            mlunit.assert_equals(class(ansNumArray), class(testNumArray)); 
            %Check empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect(flag)
                [testEllArray ansNumArray] = createTypicalArray(flag);
                [testNumArray] = maxeig(testEllArray);
                mlunit.assert_equals(ansNumArray, testNumArray);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.maxeig()','wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.maxeig()', errorStr);
                end
            end
            
        end
        function self = testMinEig(self)
            %Check degenerate matrix
            testCorrect(6);
            testCorrect(2);
            testCorrect(7);
            testCorrect(8);
            testCorrect(16);
            mlunit.assert_equals(class(ansNumArray), class(testNumArray)); 
            %Check empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect(flag)
                if (flag == 2) || (flag == 6) || (flag == 16)
                    [testEllArray ansNumArray] = createTypicalArray(flag);
                else
                    [testEllArray, ~, ansNumArray] = createTypicalArray(flag);
                end
                [testNumArray] = mineig(testEllArray);
                mlunit.assert_equals(ansNumArray, testNumArray);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.mineig()','wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.mineig()', errorStr);
                end
            end
        end
        function self = testTrace(self)
            %Check degenerate matrix
            testCorrect(6);
            testCorrect(2);
            testCorrect(7);
            testCorrect(8);
            testCorrect(16);
            mlunit.assert_equals(class(ansNumArray), class(testNumArray)); 
            %Empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect(flag)
                if (flag == 2) || (flag == 6) || (flag == 16)
                    [testEllArray ansNumArray] = createTypicalArray(flag);
                else
                    [testEllArray, ~, ~, ansNumArray] = createTypicalArray(flag);
                end
                [testNumArray] = trace(testEllArray);
                mlunit.assert_equals(ansNumArray, testNumArray);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.trace()','wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.trace()', errorStr);
                end
            end
        end
        function self = testVolume(self)
            %Check degenerate ellipsoid
            testCorrect(4);
            %Check dim=1 with two different centers
            testCorrect(2);
            testCorrect(3);
            testCorrect(16);
            mlunit.assert_equals(class(ansDoubleArray), ...
                class(testDoubleArray)); 
            %Empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect(flag)
                if  (flag == 16)
                    [testEllArray, ansDoubleArray, ~] = createTypicalArray(flag);
                elseif (flag == 2) || (flag == 3)
                    [testEllArray, ~, ansDoubleArray] = createTypicalArray(flag);
                else
                    [testEllArray, ~, ~, ansDoubleArray] = createTypicalArray(flag);
                end
                [testDoubleArray] = volume(testEllArray);
                mlunit.assert_equals(ansDoubleArray, testDoubleArray);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.volume()','wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.volume()', errorStr);
                end
            end
        end
        function self = testEq(self)
            isAnsArray = [];
            testCorrect(1);
            testCorrect(2);
            testCorrect(9);
            testCheckCorrect()
            testCorrect(10);
            testCheckCorrect()
            testCorrect(11);
            testCorrect(12);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('eq(test1EllArray, test2EllArray)', ...
                errorStr);
            self.runAndCheckError('eq(test2EllArray, test1EllArray)', ... 
                errorStr);
            function testCheckCorrect()
                mlunit.assert_equals(isAnsArray, ...
                    test1EllArray.eq(test2EllArray));
                mlunit.assert_equals(isAnsArray, ...
                    test2EllArray.eq(test1EllArray));
            end
            function testCorrect(flag)
                reportStr = '';
                if (flag == 1)
                    [test1EllArray, ~, isAnsArray, ~] = ...
                        createTypicalArray(flag);
                    [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
                elseif (flag == 2)
                    [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
                    [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
                elseif (flag == 9)
                    [test1EllArray, test2EllArray, isAnsArray] = ...
                        createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, isAnsArray, ...
                        reportStr] = createTypicalArray(flag);
                end
                [isEqArray, reportStr] = eq(test1EllArray, test2EllArray);
                mlunit.assert_equals(isEqArray, isAnsArray);
                mlunit.assert_equals(reportStr, reportStr);
            end
        end
        function self = testNe(self)
            isAnsArray = [];
            testCorrect(1);
            testCorrect(2);
            testCorrect(9);
            testCorrect(10);
            testCorrect(11);
            testCorrect(12);
            [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
            self.runAndCheckError('test1EllArray.ne(test2EllArray)', ...
                errorStr);
            self.runAndCheckError('test2EllArray.ne(test1EllArray)', ... 
                errorStr);
            function testCheckCorrect()
                mlunit.assert_equals(isAnsArray, ...
                    test1EllArray.ne(test2EllArray));
                mlunit.assert_equals(isAnsArray, ...
                    test2EllArray.ne(test1EllArray));
            end
            function testCorrect(flag)
                if (flag == 1)
                    [test1EllArray, ~, isAnsArray, ~] = ...
                        createTypicalArray(flag);
                    [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
                elseif (flag == 2)
                    [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
                    [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
                elseif (flag == 9)
                    [test1EllArray, test2EllArray, isAnsArray] = ...
                        createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, isAnsArray, ~] ...
                        = createTypicalArray(flag);
                end
                isAnsArray = ~isAnsArray;
                if (flag == 9) || (flag == 10)
                    testCheckCorrect();
                end
                testResArray = ne(test1EllArray, test2EllArray);
                mlunit.assert_equals(isAnsArray, testResArray);
            end
        end
        function self = testGe(self)
            isAnsArray = [];
            test1EllArray = [];
            test2EllArray = [];
            testCorrect(2);
            testCorrect(9);
            testCorrect(10);
            testCorrect(12);
            testError(1);
            testError(11);
            testError(13);
            testError(14);
            testError(15);
            function testCheckCorrect()
                mlunit.assert_equals(isAnsArray, ...
                    test1EllArray.ge(test2EllArray));
                mlunit.assert_equals(~isAnsArray, ...
                    test2EllArray.ge(test1EllArray));
            end
            function testCorrect(flag)
                if (flag == 2)
                    [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
                    [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, isAnsArray] = ...
                        createTypicalArray(flag);
                end
                if (flag == 9) || (flag == 12)
                    isAnsArray = ~isAnsArray;
                end
                if (flag == 9) || (flag == 10)
                    testCheckCorrect();
                end
                testResArray = ge(test1EllArray, test2EllArray);
                mlunit.assert_equals(isAnsArray, testResArray);
            end
            function testError(flag)
                if (flag == 1)
                    [test1EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                    [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
                elseif (flag == 11)
                    [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, errorStr] = ...
                        createTypicalArray(flag);
                end
                self.runAndCheckError('test1EllArray.ge(test2EllArray)',...
                    errorStr);
            end
        end 
        function self = testGt(self)
            isAnsArray = [];
            test1EllArray = [];
            test2EllArray = [];
            testCorrect(2);
            testCorrect(9);
            testCorrect(10);
            testCorrect(12);
            testError(1);
            testError(11);
            testError(13);
            testError(14);
            testError(15);
            function testCheckCorrect()
                mlunit.assert_equals(isAnsArray, ...
                    test1EllArray.gt(test2EllArray));
                mlunit.assert_equals(~isAnsArray, ...
                    test2EllArray.gt(test1EllArray));
            end
            function testCorrect(flag)
                if (flag == 2)
                    [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
                    [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, isAnsArray] = ...
                        createTypicalArray(flag);
                end
                if (flag == 9) || (flag == 12)
                    isAnsArray = ~isAnsArray;
                end
                if (flag == 9) || (flag == 10)
                    testCheckCorrect();
                end
                testResArray = gt(test1EllArray, test2EllArray);
                mlunit.assert_equals(isAnsArray, testResArray);
            end
            function testError(flag)
                if (flag == 1)
                    [test1EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                    [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
                elseif (flag == 11)
                    [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, errorStr] = ...
                        createTypicalArray(flag);
                end
                self.runAndCheckError('test1EllArray.gt(test2EllArray)',...
                    errorStr);
            end
        end
        function self = testLt(self)
            isAnsArray = [];
            test1EllArray = [];
            test2EllArray = [];
            testCorrect(2);
            testCorrect(9);
            testCorrect(10);
            testCorrect(12);
            testError(1);
            testError(11);
            testError(13);
            testError(14);
            testError(15);
            function testCheckCorrect()
                mlunit.assert_equals(isAnsArray, ...
                    test1EllArray.lt(test2EllArray));
                mlunit.assert_equals(~isAnsArray, ...
                    test2EllArray.lt(test1EllArray));
            end
            function testCorrect(flag)
                if (flag == 2)
                    [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
                    [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, isAnsArray] = ...
                        createTypicalArray(flag);
                end
                if (flag == 10) || (flag == 12)
                    isAnsArray = ~isAnsArray;
                end
                if (flag == 9) || (flag == 10)
                    testCheckCorrect();
                end
                testResArray = lt(test1EllArray, test2EllArray);
                mlunit.assert_equals(isAnsArray, testResArray);
            end
            function testError(flag)
                if (flag == 1)
                    [test1EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                    [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
                elseif (flag == 11)
                    [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, errorStr] = ...
                        createTypicalArray(flag);
                end
                self.runAndCheckError('test1EllArray.lt(test2EllArray)',...
                    errorStr);
            end
        end
        function self = testLe(self)
            isAnsArray = [];
            test1EllArray = [];
            test2EllArray = [];
            testCorrect(2);
            testCorrect(9);
            testCorrect(10);
            testCorrect(12);
            testError(1);
            testError(11);
            testError(13);
            testError(14);
            testError(15);
            function testCheckCorrect()
                mlunit.assert_equals(isAnsArray, ...
                    test1EllArray.le(test2EllArray));
                mlunit.assert_equals(~isAnsArray, ...
                    test2EllArray.le(test1EllArray));
            end
            function testCorrect(flag)
                if (flag == 2)
                    [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
                    [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, isAnsArray] = ...
                        createTypicalArray(flag);
                end
                if (flag == 10) || (flag == 12)
                    isAnsArray = ~isAnsArray;
                end
                if (flag == 9) || (flag == 10)
                    testCheckCorrect();
                end
                testResArray = le(test1EllArray, test2EllArray);
                mlunit.assert_equals(isAnsArray, testResArray);
            end
            function testError(flag)
                if (flag == 1)
                    [test1EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                    [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
                elseif (flag == 11)
                    [test1EllArray, test2EllArray, ~, ~, errorStr] = ...
                        createTypicalArray(flag);
                else
                    [test1EllArray, test2EllArray, errorStr] = ...
                        createTypicalArray(flag);
                end
                self.runAndCheckError('test1EllArray.le(test2EllArray)',...
                    errorStr);
            end
        end
        function self = testPropertyGetters(self)
            arraySizeVec = [1, 1, 2, 1, 1, 1, 1, 1, 2, 1];
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
            testAbsTolArray = createObjectArray(arraySizeVec, @repmat, ... 
                testAbsTol, 1, 2);
            testRelTolArray = createObjectArray(arraySizeVec, @repmat, ... 
                testRelTol, 1, 2);
            testNPlot2dPointsArray = createObjectArray(arraySizeVec, @repmat, ... 
                testNPlot2dPoints, 1, 2);
            testNPlot3dPointsArray = createObjectArray(arraySizeVec, @repmat, ... 
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
            arraySizeVec = [2, 1, 3, 2, 1, 1, 4];
            testEllArray(2, 1, 3, 2, 1, 1, 4) = ellipsoid;
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            isAnsArray = true(arraySizeVec);
            errorStr = 'emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = isAnsArray;
            varargout{4} = errorStr;
        case 2
            arraySizeVec = [1, 2, 4, 3, 2, 1];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                1, 1, 1);
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                1, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySizeVec, @diag, ...
                2, 1, 1);
            isAnsArray = true(arraySizeVec);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
            varargout{4} = isAnsArray;
        case 3
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                eye(5), 1, 1);
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                5, 1, 1);
            volumeDouble = 8 * (pi ^ 2) / 15;
            ansVolumeDoubleArray = createObjectArray(arraySizeVec, @diag, ...
                volumeDouble, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
        case 4
            arraySizeVec = [2, 1, 3, 2, 1, 1, 4, 1, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            ansDimNumArray = createObjectArray(arraySizeVec, @diag, ...
                5, 1, 1);
            ansRankNumArray = createObjectArray(arraySizeVec, @diag, ...
                4, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansDimNumArray;
            varargout{3} = ansRankNumArray;
            varargout{4} = ansVolumeDoubleArray;
        case 5
            arraySizeVec = [1, 2, 4, 3, 2];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                1, 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @false, ...
                1, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = isAnsArray;
        case 6
            arraySizeVec = [1, 1, 2, 3, 2, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag(zeros(1, 100)), 1, 1);
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
        case 7
            arraySizeVec = [2, 3, 2, 1, 1, 1, 4, 1, 1];
            myMat = diag(0 : 1 : 100);
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySizeVec, @diag, ...
                100, 1, 1);
            ansMinNumArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            ansTraceNumArray = createObjectArray(arraySizeVec, @diag, ...
                sum(0 : 1 : 100), 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        case 8
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myMat = rand(10);
            myMat = myMat * myMat.';
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySizeVec, @diag, ...
                max(eig(myMat)), 1, 1);
            ansMinNumArray = createObjectArray(arraySizeVec, @diag, ...
                min(eig(myMat)), 1, 1);
            ansTraceNumArray = createObjectArray(arraySizeVec, @diag, ...
                trace(myMat), 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        case 9
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                2, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                diag([1 + MAX_TOL, 1 + MAX_TOL]) , 1, 1);
            isAnsArray = true(arraySizeVec);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
        case 10
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySizeVec = [1, 1, 2, 1, 1, 1, 2, 1, 1];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                5, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                diag(repmat(1 + 100 * MAX_TOL, 1, 5)), 1, 1);
            isAnsArray = false(arraySizeVec);
            reportStr = sprintf('(1).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)\n(2).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)\n(3).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)\n(4).Q-->Max. difference (4.998751e-04) is greater than the specified tolerance(1.000000e-05)');
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
            varargout{4} = reportStr;            
        case 11
            arraySizeVec = [1, 1, 3, 1, 1, 1, 2, 1, 1];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                5, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            isAnsArray = false(arraySizeVec);
            report1Str = sprintf('(1).Q-->Different sizes (left: [5 5], right: [4 4])\n(1).q-->Different sizes (left: [1 5], right: [1 4])\n(2).Q-->Different sizes (left: [5 5], right: [4 4])\n(2).q-->Different sizes (left: [1 5], right: [1 4])\n(3).Q-->Different sizes (left: [5 5], right: [4 4])\n(3).q-->Different sizes (left: [1 5], right: [1 4])\n(4).Q-->Different sizes (left: [5 5], right: [4 4])\n(4).q-->Different sizes (left: [1 5], right: [1 4])\n(5).Q-->Different sizes (left: [5 5], right: [4 4])\n(5).q-->Different sizes (left: [1 5], right: [1 4])\n(6).Q-->Different sizes (left: [5 5], right: [4 4])\n(6).q-->Different sizes (left: [1 5], right: [1 4])');
            report2Str = 'wrongInput';
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
            varargout{4} = report1Str;
            varargout{5} = report2Str;
        case 12
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySizeVec = [1, 1, 2, 1, 1, 1, 1, 1, 2];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                10, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                (2 * MAX_TOL) * ones(10, 1), eye(10), 2);
            isAnsArray = false(arraySizeVec);
            reportStr = sprintf('(1).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)\n(2).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)\n(3).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)\n(4).q-->Max. difference (2.000000e-05) is greater than the specified tolerance(1.000000e-05)');
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
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
        case 16
            arraySizeVec = [1, 0, 0, 1, 5];
            testEllArray = ellipsoid.empty(arraySizeVec);
            ansDoubleArray = zeros(arraySizeVec);
            isAnsArray = true(arraySizeVec);
            varargout{1} = testEllArray;
            varargout{2} = ansDoubleArray;
            varargout{3} = isAnsArray;
        otherwise
    end
end
function objectArray = createObjectArray(arraySizeVec, func, firstArg, ...
    secondArg, nArg)
    nElems = prod(arraySizeVec, 2);
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
    objectArray = reshape([objectCArray{:}], arraySizeVec);
end