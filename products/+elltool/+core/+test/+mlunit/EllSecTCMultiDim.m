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
%     function self = testIsInside(self)
%             [test1Ell, test2Ell] = createTypicalEll(1);
%             compareForIsInside(test1Ell, test1Ell, 'i', 1);
%             compareForIsInside(test1Ell, test2Ell, [], 0);
%             [test1Ell, test2Ell] = createTypicalEll(2);
%             compareForIsInside(test1Ell, [test1Ell test2Ell], 'i', 1);
%             compareForIsInside(test1Ell, [test1Ell test2Ell], 'u', 0);
%             [test1Ell, test2Ell] = createTypicalEll(3);
%             compareForIsInside(test1Ell, [test1Ell test2Ell], 'i', -1);
%             compareForIsInside(test1Ell, [test1Ell test2Ell], 'u', 0);
%             [test1Ell, test2Ell] = createTypicalEll(4);
%             compareForIsInside([test1Ell test2Ell], test1Ell, 'i', 0);
%             compareForIsInside([test1Ell test2Ell], [test1Ell test2Ell],...
%                 [], 0);
%             [test1Ell, test2Ell] = createTypicalHighDimEll(1);
%             compareForIsInside([test1Ell test2Ell], test1Ell, 'i', 0);
%             compareForIsInside([test1Ell test2Ell], [test1Ell test2Ell],...
%                 [], 0);
%             compareForIsInside([test1Ell test2Ell], [test1Ell test2Ell],...
%                 'u', 0);
%         end
        function self = testMinkmp_ea(self)
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(5);
            resEllVec = minkmp_ea(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec, ~] = ...
                createTypicalEll(6);
            resEllVec = minkmp_ea(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(7);
            resEllVec = minkmp_ea(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimEll(2);
            resEllVec = minkmp_ea(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
        end
        function self = testMinkmp_ia(self)
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(5);
            resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
            
            [my1Ell, my2Ell, myEllArray, myMat, ~, ansEllVec] = ...
                createTypicalEll(6);
            resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalEll(7);
            resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
            
            [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
                createTypicalHighDimEll(2);
            resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
            [isEqual, reportStr] = eq(resEllVec, ansEllVec);
            mlunit.assert_equals(true, all(isEqual), reportStr);
        end
%         function self = testMinksum_ea(self)
%             [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
%                 createTypicalEll(5);
%             resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
%             [isEqual, reportStr] = eq(resEllVec, ansEllVec);
%             mlunit.assert_equals(true, all(isEqual), reportStr);
%             
%             [my1Ell, my2Ell, myEllArray, myMat, ~, ansEllVec] = ...
%                 createTypicalEll(6);
%             resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
%             [isEqual, reportStr] = eq(resEllVec, ansEllVec);
%             mlunit.assert_equals(true, all(isEqual), reportStr);
%             
%             [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
%                 createTypicalEll(7);
%             resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
%             [isEqual, reportStr] = eq(resEllVec, ansEllVec);
%             mlunit.assert_equals(true, all(isEqual), reportStr);
%             
%             [my1Ell, my2Ell, myEllArray, myMat, ansEllVec] = ...
%                 createTypicalHighDimEll(2);
%             resEllVec = minkmp_ia(my1Ell, my2Ell, myEllArray, myMat);
%             [isEqual, reportStr] = eq(resEllVec, ansEllVec);
%             mlunit.assert_equals(true, all(isEqual), reportStr);
%         end
%         function self = testMinksum_ia(self)
%             compareAnalyticForMinkSum(false, false, 11, 5, 5, true)
%             compareAnalyticForMinkSum(false, false, 12, 5, 5, true)
%             compareAnalyticForMinkSum(false, false, 13, 5, 5, true)
%             compareAnalyticForMinkSum(false, true, 10, 100, 100, true)
%         end
%         function self = testMinkpm_ea(self)
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(15);
%             resEll = minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
%             ansEll = ellipsoid(4, 1);
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
%             resEll = minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
%             ansEll = ellipsoid([3; 1], [2 0; 0 2]);
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(17);
%             resEll = minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
%             ansEll = ellipsoid([3; 1; 0], [2 0 0; 0 2 0; 0 0 2]);
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(18);
%             %'MINKPM_EA: first and second arguments must be ellipsoids.'
%             self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(19);
%             %'MINKPM_EA: first and second arguments must be ellipsoids.'
%             self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
%             %'MINKPM_EA: second argument must be single ellipsoid.'
%             self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], [testEllipsoid3 testEllipsoid3], testLVec)', 'wrongInput');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(20);
%             %'MINKPM_EA: all ellipsoids must be of the same dimension.'
%             self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(21);
%             %'MINKPM_EA: all ellipsoids must be of the same dimension.'
%             self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
%              
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(22);
%             %'MINKPM_EA: dimension of the direction vectors must be the same as dimension of ellipsoids.'
%             self.runAndCheckError('minkpm_ea([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
%             
%             [testEllHighDim1 testLVec] = createTypicalHighDimEll(4);
%             resEll = minkpm_ea([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
%             ansEll = ellipsoid(zeros(12, 1), eye(12));
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllHighDim1 testLVec] = createTypicalHighDimEll(5);
%             resEll = minkpm_ea([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
%             ansEll = ellipsoid(zeros(20, 1), eye(20));
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllHighDim1 testLVec] = createTypicalHighDimEll(6);
%             resEll = minkpm_ea([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
%             ansEll = ellipsoid(zeros(100, 1), eye(100));
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%         end
%         
%         function self = testMinkpm_ia(self)            
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(15);
%             resEll = minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
%             ansEll = ellipsoid(4, 1);
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
%             resEll = minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
%             ansEll = ellipsoid([3; 1], [2 0; 0 2]);
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(17);
%             resEll = minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec);
%             ansEll = ellipsoid([3; 1; 0], [2 0 0; 0 2 0; 0 0 2]);
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(18);
%             %'MINKPM_IA: first and second arguments must be ellipsoids.'
%             self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(19);
%             %'MINKPM_IA: first and second arguments must be ellipsoids.'
%             self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongInput');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(16);
%             %'MINKPM_IA: second argument must be single ellipsoid.'
%             self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], [testEllipsoid3 testEllipsoid3], testLVec)', 'wrongInput');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(20);
%             %'MINKPM_IA: all ellipsoids must be of the same dimension.'
%             self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
%             
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(21);
%             %'MINKPM_IA: all ellipsoids must be of the same dimension.'
%             self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
%              
%             [testEllipsoid1 testEllipsoid2 testEllipsoid3 testLVec] = createTypicalEll(22);
%             %'MINKPM_IA: dimension of the direction vectors must be the same as dimension of ellipsoids.'
%             self.runAndCheckError('minkpm_ia([testEllipsoid1 testEllipsoid2], testEllipsoid3, testLVec)', 'wrongSizes');
%             
%             [testEllHighDim1 testLVec] = createTypicalHighDimEll(4);
%             resEll = minkpm_ia([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
%             ansEll = ellipsoid(zeros(12, 1), eye(12));
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllHighDim1 testLVec] = createTypicalHighDimEll(5);
%             resEll = minkpm_ia([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
%             ansEll = ellipsoid(zeros(20, 1), eye(20));
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%             
%             [testEllHighDim1 testLVec] = createTypicalHighDimEll(6);
%             resEll = minkpm_ia([testEllHighDim1 testEllHighDim1], testEllHighDim1, testLVec);
%             ansEll = ellipsoid(zeros(100, 1), eye(100));
%             [isEq, reportStr] = eq(resEll, ansEll);
%             mlunit.assert_equals(true, isEq, reportStr);
%         end    
     end
end
function [varargout] = createTypicalEll(flag)
    switch flag
        case 1
            array1Size = [1, 2, 1, 3, 2, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [2; 1], [4, 1; 1, 1], 2);
            array2Size = [1, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                2, 1, 1);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 2
            array1Size = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [2; 1; 0], [4, 1, 1; 1, 2, 1; 1, 1, 5], 2);
            array2Size = [1, 3, 1, 1, 1, 5, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                3, 1, 1);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 3
            array1Size = [1, 1, 1, 1, 1, 7, 1, 1, 7, 1, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [5; 5; 5], [4, 1, 1; 1, 2, 1; 1, 1, 5], 2);
            array2Size = [1, 2, 1, 1, 1, 1, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                3, 1, 1);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 4
            array1Size = [1, 1, 1, 1, 1, 7, 1, 1, 7, 1, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                [5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6], 2);
            array2Size = [2, 2, 1, 1, 1, 1, 1];
            my2EllArray = createObjectArray(array2Size, @ell_unitball, ... 
                4, 1, 1);
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
        otherwise
    end
end
function [varargout] = createTypicalHighDimEll(flag)
    switch flag
        case 1
            array1Size = [1, 2, 1, 3, 2, 1];
            my1EllArray = createObjectArray(array1Size, @ellipsoid, ... 
                zeros(100, 1), diag([5 * ones(1, 50), 2 * ones(1, 50)]), 2);
            array2Size = [1, 3, 1, 1, 1, 5, 1];
            my2EllArray = createObjectArray(array2Size, @ellipsoid, ... 
                ones(100, 1), diag([0.2 * ones(1, 50), ...
                0.5 * ones(1, 50)]), 1);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 2
            arraySize = [1, 1, 1, 1, 1, 3, 1, 1, 3, 1];
            my1Ell = ell_unitball(100);
            my2Ell = ellipsoid(ones(100, 1), diag( 0.25 * ones(1, 100)));
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                100, 1, 1);
            myMat = eye(100);
            ansEllMat = diag(9.5 ^ 2 * ones(1, 100));
            ansEllVec = createObjectArray([1, 100], @ellipsoid, ... 
                -ones(100, 1), ansEllMat, 2);
            varargout{1} = my1Ell;
            varargout{2} = my2Ell;
            varargout{3} = myEllArray;          
            varargout{4} = myMat;          
            varargout{5} = ansEllVec;  
        otherwise
    end
end
function compareForIsInside(test1EllVec, test2EllVec, myString, myResult)
    if isempty(myString)
        testRes = isinside(test1EllVec, test2EllVec);
    else
        testRes = isinside(test1EllVec, test2EllVec, myString);
    end
    mlunit.assert_equals(myResult, testRes);
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