classdef EllSecTCMultiDim < mlunitext.test_case
    
% $Author: Igor Samokhin, Lomonosov Moscow State University,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 02-November-2012, <igorian.vmk@gmail.com>$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

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
    function self = testIsInside(self)
%             my1EllArray(2) = ellipsoid;
%             my1EllArray(:) = ellipsoid([5; 5; 5; 5], ...
%                 [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
%             my2EllArray(2) = ellipsoid;
%             my2EllArray(1) = ell_unitball(4);
%             testRes = isinside(my2EllArray, my1EllArray, 'i');
%             mlunit.assert_equals(testRes, 0);
            [test1EllArray, test2EllArray] = createTypicalEll(1);
            compareForIsInside(test1EllArray, test1EllArray, 'i', 1);
            compareForIsInside(test1EllArray, test2EllArray, [], 0);
            [test1EllArray, test2EllArray] = createTypicalEll(2);
            compareForIsInside(test1EllArray, test2EllArray, 'i', 1);
            compareForIsInside(test1EllArray, test2EllArray, 'u', 0);
            [test1EllArray, test2EllArray] = createTypicalEll(3);
            compareForIsInside(test1EllArray, test2EllArray, 'i', -1);
            compareForIsInside(test1EllArray, test2EllArray, 'u', 0);
            [test1EllArray, test2EllArray] = createTypicalEll(4);
%             compareForIsInside(test2EllArray, test1EllArray, 'i', 0);
            compareForIsInside(test2EllArray, test2EllArray, [], 0);
            [test1EllArray, test2EllArray] = createTypicalHighDimEll(1);
            compareForIsInside(test2EllArray, test1EllArray, 'i', 1);
            compareForIsInside(test2EllArray, test2EllArray, [], 0);
            compareForIsInside(test2EllArray, test2EllArray, 'u', 0);
        end
        function self = testMinkmp_ea(self)
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(5);
            compareForMinkFunc(@minkmp_ea, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec, ~] = ...
                createTypicalEll(6);
            compareForMinkFunc(@minkmp_ea, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(7);
            compareForMinkFunc(@minkmp_ea, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimEll(2);
            compareForMinkFunc(@minkmp_ea, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
        end
        function self = testMinkmp_ia(self)
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(5);
            compareForMinkFunc(@minkmp_ia, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
            
            [my1Ell, my2Ell, myEllArray, myMat, ~, ansEllVec] = ...
                createTypicalEll(6);
            compareForMinkFunc(@minkmp_ia, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(7);
            compareForMinkFunc(@minkmp_ia, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimEll(2);
            compareForMinkFunc(@minkmp_ia, 4, ansEllVec, my1Ell, my2Ell, ...
                myEllArray, myMat)
        end
        function self = testMinksum_ea(self)
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(8);
            compareForMinkFunc(@minksum_ea, 2, ansEllVec, myEllArray, myMat)
            
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(9);
            compareForMinkFunc(@minksum_ea, 2, ansEllVec, myEllArray, myMat)
            
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(10);
            compareForMinkFunc(@minksum_ea, 2, ansEllVec, myEllArray, myMat)
            
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimEll(3);
            compareForMinkFunc(@minksum_ea, 2, ansEllVec, myEllArray, myMat)
        end
        function self = testMinksum_ia(self)
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(8);
            compareForMinkFunc(@minksum_ia, 2, ansEllVec, myEllArray, myMat)
            
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(9);
            compareForMinkFunc(@minksum_ia, 2, ansEllVec, myEllArray, myMat)
            
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(10);
            compareForMinkFunc(@minksum_ia, 2, ansEllVec, myEllArray, myMat)
            
            [myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimEll(3);
            compareForMinkFunc(@minksum_ia, 2, ansEllVec, myEllArray, myMat)
        end
        function self = testMinkpm_ea(self)
            [myEllArray, myEll, myMat, ansEllVec] = ...
                createTypicalEll(11);
            compareForMinkFunc(@minkpm_ea, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
            
            [myEllArray, myEll, myMat, ansEllVec, ~] = ...
                createTypicalEll(12);
            compareForMinkFunc(@minkpm_ea, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
            
            [myEllArray, myEll, myMat, ansEllVec] = ...
                createTypicalEll(13);
            compareForMinkFunc(@minkpm_ea, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
            
            [myEllArray, myEll, myMat, ansEllVec] = ...
                createTypicalHighDimEll(4);
            compareForMinkFunc(@minkpm_ea, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
        end
        function self = testMinkpm_ia(self)
            [myEllArray, myEll, myMat, ansEllVec] = ...
                createTypicalEll(11);
            compareForMinkFunc(@minkpm_ia, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
            
            [myEllArray, myEll, myMat, ~, ansEllVec] = ...
                createTypicalEll(12);
            compareForMinkFunc(@minkpm_ia, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
            
            [myEllArray, myEll, myMat, ansEllVec] = ...
                createTypicalEll(13);
            compareForMinkFunc(@minkpm_ia, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
            
            [myEllArray, myEll, myMat, ansEllVec] = ...
                createTypicalHighDimEll(4);
            compareForMinkFunc(@minkpm_ia, 3, ansEllVec, myEllArray, myEll, ...
                myMat)
        end
     end
end
function [varargout] = createTypicalEll(flag)
    switch flag
        case 1
            array1Size = [1, 2, 1, 1, 2, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [2; 1], [4, 1; 1, 1], 2);
            array2Size = [1, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                2, 1, 1);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 2
            array1Size = [1, 1, 1, 1, 1, 3, 1, 1, 2];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [2; 1; 0], [4, 1, 1; 1, 2, 1; 1, 1, 5], 2);
            array2Size = [1, 2, 1, 1, 1, 3, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                3, 1, 1);
            my2EllArray(1, 2, 1, 1, 1, 3, 1) = ellipsoid([2; 1; 0], ...
                [4, 1, 1; 1, 2, 1; 1, 1, 5]);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 3
            array1Size = [1, 1, 1, 1, 1, 3, 1, 1, 3, 1, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [5; 5; 5], [4, 1, 1; 1, 2, 1; 1, 1, 5], 2);
            array2Size = [1, 2, 1, 1, 1, 1, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                3, 1, 1);
            my2EllArray(1, 2, 1, 1, 1, 1, 1) = ellipsoid([5; 5; 5], ...
                [4, 1, 1; 1, 2, 1; 1, 1, 5], 2);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 4
            array1Size = [1, 1, 1, 1, 1, 2, 1, 1, 2, 1, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
            array2Size = [2, 2, 1, 1, 1, 1, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                4, 1, 1);
            my2EllArray(1, 2, 1, 1, 1, 1, 1) = ellipsoid([5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;  
        case 5
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
        case 6
            arraySize = [1, 2, 1, 3, 2, 1];
            my1Ell = ellipsoid(10 * ones(7, 1), diag(9 * ones(1, 7)));
            my2Ell = ellipsoid(-3 * ones(7, 1), diag([4, ones(1, 6)]));
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                7, 1, 1);
            myMat = [eye(7), -eye(7)];
            ansEaEllMat = diag([13 ^ 2, 13 * 16 * ones(1, 6)]);
            ansEaEllVec = createObjectArray([1, 2], @ellipsoid, ... 
                13 * ones(7, 1), ansEaEllMat, 2);
            ansIaEllMat = diag([13 ^ 2, (sqrt(2.5) + 12) ^ 2 * ones(1, 6)]);
            ansIaEllVec = createObjectArray([1, 2], @ellipsoid, ... 
                13 * ones(7, 1), ansIaEllMat, 2);
            varargout{1} = my1Ell;
            varargout{2} = my2Ell;
            varargout{3} = myEllArray;          
            varargout{4} = myMat;          
            varargout{5} = ansEaEllVec;   
            varargout{6} = ansIaEllVec;   
        case 7
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
        case 8
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
        case 9
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
        case 10
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
        case 11
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
        case 12
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
        case 13
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
        otherwise
    end
end
function [varargout] = createTypicalHighDimEll(flag)
    switch flag
        case 1
            array1Size = [1, 2, 1, 1, 2, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                zeros(100, 1), diag([5 * ones(1, 50), 2 * ones(1, 50)]), 2);
            array2Size = [1, 2, 1, 1, 1, 2, 1];
            my2EllArray = createObjectArray(array2Size, @ellipsoid, ... 
                ones(100, 1), diag([0.2 * ones(1, 50), ...
                0.5 * ones(1, 50)]), 2);
            my2EllArray(1, 2, 1, 1, 1, 2, 1) = ellipsoid(zeros(100, 1), ...
                diag([5 * ones(1, 50), 2 * ones(1, 50)]));
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 2
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
        case 3
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
        case 4
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
function compareForIsInside(test1EllArray, test2EllArray, myString, myResult)
    if isempty(myString)
        testRes = isinside(test1EllArray, test2EllArray);
    else
        testRes = isinside(test1EllArray, test2EllArray, myString);
    end
    mlunit.assert_equals(myResult, testRes);
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
    [isEqual, reportStr] = eq(resEllVec, ansEllVec);
    mlunit.assert_equals(true, all(isEqual), reportStr);
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