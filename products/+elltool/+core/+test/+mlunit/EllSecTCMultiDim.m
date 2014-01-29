classdef EllSecTCMultiDim < mlunitext.test_case
%$Author: Igor Samokhin <igorian.vmk@gmail.com> $
%$Date: 2013-01-31 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self=EllSecTCMultiDim(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,...
                'TestData', filesep,shortClassName];
        end
        function self = testIsContainedInIntersection (self)
            array1Size = [1, 2, 1, 1, 2, 1];
            myMat = [4, 1, 1; 1, 2, 1; 1, 1, 5];
            test1EllArray = createObjectArray(array1Size, @ellipsoid, ...
                [2; 1], [4, 1; 1, 1], 2);
            array2Size = [1, 1];
            test2EllArray = createObjectArray(array2Size, @ell_unitball, ...
                2, 1, 1);
            testCorrect(0, 'i', 1);
            testCorrect(1, 'i', 0);
            testCorrect(1, [], 0);
            array1Size = [1, 1, 1, 1, 1, 3, 1, 1, 2];
            test1EllArray = createObjectArray(array1Size, @ellipsoid, ...
                [2; 1; 0], myMat, 2);
            array2Size = [1, 2, 1, 1, 1, 3, 1];
            test2EllArray = createObjectArray(array2Size, @ell_unitball, ...
                3, 1, 1);
            test2EllArray(1, 2, 1, 1, 1, 3, 1) = ellipsoid([2; 1; 0], ...
                myMat);
            testCorrect(1, 'i', 1);
            testCorrect(1, 'u', 0);
            array1Size = [1, 1, 1, 1, 1, 3, 1, 1, 3, 1, 1];
            test1EllArray = createObjectArray(array1Size, @ellipsoid, ...
                [5; 5; 5], myMat, 2);
            array2Size = [1, 2, 1, 1, 1, 1, 1];
            test2EllArray = createObjectArray(array2Size, @ell_unitball, ...
                3, 1, 1);
            test2EllArray(1, 2, 1, 1, 1, 1, 1) = ellipsoid([5; 5; 5], ...
                myMat, 2);
            testCorrect(1, 'i', -1);
            testCorrect(1, 'u', 0);
            array1Size = [1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1];
            test1EllArray = createObjectArray(array1Size, @ellipsoid, ...
                [5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
            array2Size = [2, 2, 1, 1, 1, 1, 1];
            test2EllArray = createObjectArray(array2Size, @ell_unitball, ...
                4, 1, 1);
            test2EllArray(1, 2, 1, 1, 1, 1, 1) = ellipsoid([5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
            testCorrect(2, 'i', 0);
            testCorrect(3, [], 0);
            array1Size = [1, 2, 1, 1, 2, 1];
            test1EllArray = createObjectArray(array1Size, @ellipsoid, ...
                zeros(100, 1), diag([5 * ones(1, 50), 2 * ones(1, 50)]), 2);
            array2Size = [1, 2, 1, 1, 1, 2, 1];
            test2EllArray = createObjectArray(array2Size, @ellipsoid, ...
                ones(100, 1), diag([0.2 * ones(1, 50), ...
                0.5 * ones(1, 50)]), 2);
            test2EllArray(1, 2, 1, 1, 1, 2, 1) = ellipsoid(-ones(100, 1), ...
                diag([5 * ones(1, 50), 2 * ones(1, 50)]));
            testCorrect(1, 'i', -1);
            testCorrect(3, [], 0);
            testCorrect(3, 'u', 0);
            testError(10);
            testError(11);
            testError(12);
            testError(13);
            function testCorrect(flag, myString, myResult)
                if isempty(myString)
                    switch flag
                        case 0
                            testRes = doesIntersectionContain(test1EllArray, test1EllArray);
                        case 1
                            testRes = doesIntersectionContain(test1EllArray, test2EllArray);
                        case 2
                            testRes = doesIntersectionContain(test2EllArray, test1EllArray);
                        case 3
                            testRes = doesIntersectionContain(test2EllArray, test2EllArray);
                        otherwise
                    end
                else
                    switch flag
                        case 0
                            testRes = doesIntersectionContain(test1EllArray, ...
                                test1EllArray, 'mode', myString);
                        case 1
                            testRes = doesIntersectionContain(test1EllArray, ...
                                test2EllArray, 'mode', myString);
                        case 2
                            testRes = doesIntersectionContain(test2EllArray, ...
                                test1EllArray, 'mode', myString);
                        case 3
                            testRes = doesIntersectionContain(test2EllArray, ...
                                test2EllArray, 'mode', myString);
                        otherwise
                    end
                end
                mlunitext.assert_equals(myResult, testRes);
            end
            function testError(flag)
                [test1EllArray, test2EllArray, errorStr] = ...
                    createTypicalArray(flag);
                self.runAndCheckError...
                    ('test1EllArray.doesIntersectionContain(test2EllArray)', ...
                    errorStr);
                if (flag == 10) || (flag == 13)
                    self.runAndCheckError...
                        ('test2EllArray.doesIntersectionContain(test1EllArray)', ...
                        errorStr);
                else
                    self.runAndCheckError...
                        ('test2EllArray.doesIntersectionContain(test1EllArray)', ...
                        'wrongInput:emptyEllipsoid');
                end
            end
        end
        function self = testMinksum_ea(self)
            checkMinksumEaAndMinksumIa(self, true);
        end
        function self = testMinksum_ia(self)
            checkMinksumEaAndMinksumIa(self, false);
        end
        function self = testMinkmp_ea(self)
            checkMinkmpEaAndMinkmpIa(self, true);
        end
        function self = testMinkmp_ia(self)
            checkMinkmpEaAndMinkmpIa(self, false);
        end
        function self = testMinkpm_ea(self)
            checkMinkpmEaAndMinkpmIa(self, true);
        end
        function self = testMinkpm_ia(self)
            checkMinkpmEaAndMinkpmIa(self, false);
        end
    end
end
function [varargout] = createTypicalArray(flag)
switch flag
    case 1
        arraySize = [2, 1, 3, 1, 1, 1, 2];
        my1Ell = ellipsoid(diag( 4 * ones(1, 10)));
        my2Ell = ell_unitball(10);
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            10, 1, 1);
        myMat = eye(10);
        ansEllMat = diag(13 ^ 2 * ones(1, 10));
        ansEllVec = createObjectArray([1, 10], @ellipsoid, ...
            ansEllMat, 1, 1);
        varargout{1} = my1Ell;
        varargout{2} = my2Ell;
        varargout{3} = myEllArray;
        varargout{4} = myMat;
        varargout{5} = ansEllVec;
    case 2
        arraySize = [1, 2, 1, 3, 2, 1];
        my1Ell = ellipsoid(10 * ones(7, 1), diag(9 * ones(1, 7)));
        my2Ell = ellipsoid(-3 * ones(7, 1), diag([4, ones(1, 6)]));
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            7, 1, 1);
        myMat = [eye(7), -eye(7)];
        ansEaEllMat = diag([13 ^ 2, 13 * 16 * ones(1, 6)]);
        ansEaEllVec = createObjectArray([1, 2], @ellipsoid, ...
            13 * ones(7, 1), ansEaEllMat, 2);
        ansIaEllMat = diag([13 ^ 2, (realsqrt(2.5) + 12) ^ 2 * ones(1, 6)]);
        ansIaEllVec = createObjectArray([1, 2], @ellipsoid, ...
            13 * ones(7, 1), ansIaEllMat, 2);
        varargout{1} = my1Ell;
        varargout{2} = my2Ell;
        varargout{3} = myEllArray;
        varargout{4} = myMat;
        varargout{5} = ansEaEllVec;
        varargout{6} = ansIaEllVec;
    case 3
        arraySize = [1, 1, 1, 1, 1, 3, 1, 1, 2];
        my1Ell = ell_unitball(1);
        my2Ell = ellipsoid(1, 0.25);
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            1, 1, 1);
        myMat = [1, -1];
        ansEllMat = diag(6.5 ^ 2);
        ansEllVec = createObjectArray([1, 2], @ellipsoid, ...
            -1, ansEllMat, 2);
        varargout{1} = my1Ell;
        varargout{2} = my2Ell;
        varargout{3} = myEllArray;
        varargout{4} = myMat;
        varargout{5} = ansEllVec;
    case 4
        arraySize = [2, 1, 3, 1, 1, 1, 2];
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            10, 1, 1);
        myMat = eye(10);
        ansEllMat = diag(12 ^ 2 * ones(1, 10));
        ansEllVec = createObjectArray([1, 10], @ellipsoid, ...
            ansEllMat, 1, 1);
        varargout{1} = myEllArray;
        varargout{2} = myMat;
        varargout{3} = ansEllVec;
    case 5
        arraySize = [1, 2, 1, 3, 2, 1];
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            7, 1, 1);
        myEllArray(1, 2, 1, 3, 2, 1) = ellipsoid(5 * ones(7, 1), ...
            diag(9 * ones(1, 7)));
        myMat = [eye(7), -eye(7)];
        ansEllMat = diag(14 ^ 2 * ones(1, 7));
        ansEllVec = createObjectArray([1, 14], @ellipsoid, ...
            5 * ones(7, 1), ansEllMat, 2);
        varargout{1} = myEllArray;
        varargout{2} = myMat;
        varargout{3} = ansEllVec;
    case 6
        arraySize = [1, 1, 1, 1, 1, 3, 1, 1, 2];
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            1, 1, 1);
        myEllArray(1, 1, 1, 1, 1, 2, 1, 1, 1) = ellipsoid(-1, 0.25);
        myMat = [1, -1];
        ansEllMat = diag(5.5 ^ 2);
        ansEllVec = createObjectArray([1, 2], @ellipsoid, ...
            -1, ansEllMat, 2);
        varargout{1} = myEllArray;
        varargout{2} = myMat;
        varargout{3} = ansEllVec;
    case 7
        arraySize = [2, 1, 3, 1, 1, 1, 2];
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            10, 1, 1);
        myEll = ellipsoid(diag( 4 * ones(1, 10)));
        myMat = eye(10);
        ansEllMat = diag(10 ^ 2 * ones(1, 10));
        ansEllVec = createObjectArray([1, 10], @ellipsoid, ...
            ansEllMat, 1, 1);
        varargout{1} = myEllArray;
        varargout{2} = myEll;
        varargout{3} = myMat;
        varargout{4} = ansEllVec;
    case 8
        arraySize = [1, 2, 1, 3, 2, 1];
        myEllArray = createObjectArray(arraySize, @ellipsoid, ...
            -3 * ones(7, 1), diag([4, ones(1, 6)]), 2);
        myEll = ellipsoid(10 * ones(7, 1), diag(9 * ones(1, 7)));
        myMat = [eye(7), -eye(7)];
        ansEaEllMat = diag([21 ^ 2, 9 ^ 2 ...
            * ones(1, 6)]);
        ansEaEllVec = createObjectArray([1, 14], @ellipsoid, ...
            -46 * ones(7, 1), ansEaEllMat, 2);
        ans1IaEllMat = diag( 0.875 * 12 ^ 2 * [ 4, ones(1, 6)] - 63);
        ans2IaEllMat = diag( 0.75 * 12 ^ 2 * [ 4, ones(1, 6)] - 27);
        ansIaEllVec = createObjectArray([1, 14], @ellipsoid, ...
            -46 * ones(7, 1), ans2IaEllMat, 2);
        ansIaEllVec(1) = ellipsoid(-46 * ones(7, 1), ans1IaEllMat);
        ansIaEllVec(8) = ellipsoid(-46 * ones(7, 1), ans1IaEllMat);
        varargout{1} = myEllArray;
        varargout{2} = myEll;
        varargout{3} = myMat;
        varargout{4} = ansEaEllVec;
        varargout{5} = ansIaEllVec;
    case 9
        arraySize = [1, 1, 1, 1, 1, 2, 1, 1, 2];
        myEll = ellipsoid(1, 0.25);
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            1, 1, 1);
        myMat = [1, -1];
        ansEllMat = diag(12.25);
        ansEllVec = createObjectArray([1, 2], @ellipsoid, ...
            -1, ansEllMat, 2);
        varargout{1} = myEllArray;
        varargout{2} = myEll;
        varargout{3} = myMat;
        varargout{4} = ansEllVec;
    case 10
        arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
        testEllArray = ellipsoid.empty(1, 0, 0, 1, 5);
        test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
            3, 1, 1);
        errorStr = 'wrongInput:emptyArray';
        varargout{1} = testEllArray;
        varargout{2} = test2EllArray;
        varargout{3} = errorStr;
    case 11
        arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
        testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
            3, 1, 1);
        testEllArray(2, 1, 1, 2, 1, 3, 1) = ellipsoid;
        test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
            3, 1, 1);
        errorStr = 'wrongInput:emptyEllipsoid';
        varargout{1} = testEllArray;
        varargout{2} = test2EllArray;
        varargout{3} = errorStr;
    case 12
        arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
        testEllArray = createObjectArray(arraySizeVec, @(x)ellipsoid(), ...
            3, 1, 1);
        test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
            3, 1, 1);
        errorStr = 'wrongInput:emptyEllipsoid';
        varargout{1} = testEllArray;
        varargout{2} = test2EllArray;
        varargout{3} = errorStr;
    case 13
        arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
        testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
            3, 1, 1);
        testEllArray(2, 1, 1, 1, 1, 1, 1) = ell_unitball(7);
        test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
            3, 1, 1);
        errorStr = 'wrongSizes';
        varargout{1} = testEllArray;
        varargout{2} = test2EllArray;
        varargout{3} = errorStr;
    otherwise
end
end
function [varargout] = createTypicalHighDimArray(flag)
switch flag
    case 1
        arraySize = [1, 1, 1, 1, 1, 3, 1, 1, 3, 1];
        my1Ell = ell_unitball(100);
        my2Ell = ellipsoid(ones(100, 1), diag( 0.25 * ones(1, 100)));
        myEllArray = createObjectArray(arraySize, @ell_unitball, ...
            100, 1, 1);
        myMat = [eye(5); zeros(95, 5)];
        ansEllMat = diag(9.5 ^ 2 * ones(1, 100));
        ansEllVec = createObjectArray([1, 5], @ellipsoid, ...
            -ones(100, 1), ansEllMat, 2);
        varargout{1} = my1Ell;
        varargout{2} = my2Ell;
        varargout{3} = myEllArray;
        varargout{4} = myMat;
        varargout{5} = ansEllVec;
    case 2
        arraySize = [1, 1, 1, 1, 1, 3, 1, 1, 3, 1];
        myEllArray = createObjectArray(arraySize, @ellipsoid, ...
            ones(100, 1), diag( 0.25 * ones(1, 100)), 2);
        myMat = [eye(5); zeros(95, 5)];
        ansEllMat = diag(4.5 ^ 2 * ones(1, 100));
        ansEllVec = createObjectArray([1, 5], @ellipsoid, ...
            9 * ones(100, 1), ansEllMat, 2);
        varargout{1} = myEllArray;
        varargout{2} = myMat;
        varargout{3} = ansEllVec;
    case 3
        arraySize = [1, 1, 1, 2, 1, 3, 1, 1, 3, 1];
        myEllArray = createObjectArray(arraySize, @ellipsoid, ...
            ones(100, 1), diag( 0.25 * ones(1, 100)), 2);
        myEll = ell_unitball(100);
        myMat = [eye(5); zeros(95, 5)];
        ansEllMat = diag(64 * ones(1, 100));
        ansEllVec = createObjectArray([1, 5], @ellipsoid, ...
            18 * ones(100, 1), ansEllMat, 2);
        varargout{1} = myEllArray;
        varargout{2} = myEll;
        varargout{3} = myMat;
        varargout{4} = ansEllVec;
    otherwise
end
end
function compareForMinkFunc(func, nArg, ansEllVec, firstArg, secondArg, thirdArg, ...
    fourthArg)
switch nArg
    case 2
        resEllVec = func(firstArg, secondArg);
    case 3
        resEllVec = func(firstArg, secondArg, thirdArg);
    case 4
        resEllVec = func(firstArg, secondArg, thirdArg, fourthArg);
    otherwise
end
[isEq, reportStr] = isEqual(resEllVec, ansEllVec);
mlunitext.assert_equals(true, all(isEq), reportStr);
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
function checkMinksumEaAndMinksumIa(self, isMinksumEa)
testCorrect(true, 4);
testCorrect(true, 5);
testCorrect(true, 6);
testCorrect(false, 2);
testError(10);
testError(11);
testError(12);
testError(13);
    function testCorrect(isnHighDim, flag)
        if (isnHighDim)
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalArray(flag);
        else
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimArray(flag);
        end
        if isMinksumEa
            compareForMinkFunc(@minksum_ea, 2, ansEllVec, ...
                myEllArray, myMat);
        else
            compareForMinkFunc(@minksum_ia, 2, ansEllVec, ...
                myEllArray, myMat)
        end
    end
    function testError(flag)
        [test1EllArray, ~, errorStr] = createTypicalArray(flag);
        if isMinksumEa
            self.runAndCheckError...
                ('test1EllArray.minksum_ea(eye(3))', errorStr);
        else
            self.runAndCheckError...
                ('test1EllArray.minksum_ia(eye(3))', errorStr);
        end
    end
end
function checkMinkmpEaAndMinkmpIa(self, isMinkmpEa)
testCorrect(true, 1);
testCorrect(true, 2);
testCorrect(true, 3);
testCorrect(false, 1);
testError(10);
testError(11);
testError(12);
testError(13);
    function testCorrect(isnHighDim, flag)
        if (isnHighDim)
            if (flag == 2) && (~isMinkmpEa)
                [my1Ell, my2Ell, myEllArray, myMat, ~, ansEllVec] = ...
                    createTypicalArray(flag);
            else
                [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                    createTypicalArray(flag);
            end
        else
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimArray(flag);
        end
        if isMinkmpEa
            compareForMinkFunc(@minkmp_ea, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat);
        else
            compareForMinkFunc(@minkmp_ia, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat);
        end
    end
    function testError(flag)
        [test1EllArray, test2EllArray, errorStr] = ...
            createTypicalArray(flag);
        if isMinkmpEa
            self.runAndCheckError...
                ('test1EllArray.minkmp_ea(ell_unitball(3), test2EllArray, eye(3))', ...
                'wrongInput');
            self.runAndCheckError...
                ('ell_unitball(3).minkmp_ea(test1EllArray, test2EllArray, eye(3))', ...
                'wrongInput');
            if (flag ~= 10)
                self.runAndCheckError...
                    ('ell_unitball(3).minkmp_ea(ell_unitball(3), test1EllArray, eye(3))', ...
                    errorStr);
            end
        else
            self.runAndCheckError...
                ('test1EllArray.minkmp_ia(ell_unitball(3), test2EllArray, eye(3))', ...
                'wrongInput');
            self.runAndCheckError...
                ('ell_unitball(3).minkmp_ia(test1EllArray, test2EllArray, eye(3))', ...
                'wrongInput');
            if (flag ~= 10)
                self.runAndCheckError...
                    ('ell_unitball(3).minkmp_ia(ell_unitball(3), test1EllArray, eye(3))', ...
                    errorStr);
            end
        end
    end
end
function checkMinkpmEaAndMinkpmIa(self, isMinkpmEa)
testCorrect(true, 7);
testCorrect(true, 8);
testCorrect(true, 9);
testCorrect(false, 3);
testError(10);
testError(11);
testError(12);
testError(13);
    function testCorrect(isnHighDim, flag)
        if (isnHighDim)
            if (flag == 8) && (~isMinkpmEa)
                [myEllArray, myEll, myMat, ~, ansEllVec] = ...
                    createTypicalArray(flag);
            else
                [myEllArray, myEll, myMat, ansEllVec] = ...
                    createTypicalArray(flag);
            end
        else
            [myEllArray, myEll, myMat, ansEllVec] = ...
                createTypicalHighDimArray(flag);
        end
        if isMinkpmEa
            compareForMinkFunc(@minkpm_ea, 3, ansEllVec, myEllArray, ...
                myEll, myMat);
        else
            compareForMinkFunc(@minkpm_ia, 3, ansEllVec, myEllArray, ...
                myEll, myMat);
        end
    end
    function testError(flag)
        [test1EllArray, test2EllArray, errorStr] = ...
            createTypicalArray(flag);
        if isMinkpmEa
            self.runAndCheckError...
                ('test2EllArray.minkpm_ea(test1EllArray, eye(3))', ...
                'wrongInput');
            self.runAndCheckError...
                ('test1EllArray.minkpm_ea(test2EllArray, eye(3))', ...
                'wrongInput');
        else
            self.runAndCheckError...
                ('test2EllArray.minkpm_ia(test1EllArray, eye(3))', ...
                'wrongInput');
            self.runAndCheckError...
                ('test1EllArray.minkpm_ia(test2EllArray, eye(3))', ...
                'wrongInput');
        end
        if (flag == 10) || (flag == 13)
            if isMinkpmEa
                self.runAndCheckError...
                    ('test1EllArray.minkpm_ea(ell_unitball(3), eye(3))', ...
                    errorStr);
            else
                self.runAndCheckError...
                    ('test1EllArray.minkpm_ia(ell_unitball(3), eye(3))', ...
                    errorStr);
            end
        else
            if isMinkpmEa
                self.runAndCheckError...
                    ('test1EllArray.minkpm_ea(ell_unitball(3), eye(3))', ...
                    'wrongSizes');
            else
                self.runAndCheckError...
                    ('test1EllArray.minkpm_ia(ell_unitball(3), eye(3))', ...
                    'wrongSizes');
            end
        end
    end
end