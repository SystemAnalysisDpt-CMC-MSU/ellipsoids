classdef ElliIntUnionTCMultiDim < mlunitext.test_case

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
        function self = ElliIntUnionTCMultiDim(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,...
                'TestData',...
                filesep,shortClassName];
        end
        function self = testEllunionEa(self)
            [testEllVec, resultEll] = createTypicalArray(1);
            resEllVec = ellunion_ea(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllVec, resultEll] = createTypicalArray(2);
            resEllVec = ellunion_ea(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllVec, resultEll] = createTypicalArray(3);
            resEllVec = ellunion_ea(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllVec, resultEll] = createTypicalArray(4);
            resEllVec = ellunion_ea(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
        end
        function self = testEllintersectionIa(self)
            [testEllVec, resultEll] = createTypicalArray(1);
            resEllVec = ellintersection_ia(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllVec, resultEll] = createTypicalArray(2);
            resEllVec = ellintersection_ia(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllVec, resultEll] = createTypicalArray(3);
            resEllVec = ellintersection_ia(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllVec, resultEll] = createTypicalArray(5);
            resEllVec = ellintersection_ia(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllVec, errorStr] = createTypicalArray(6);
            self.runAndCheckError...
               ('ellintersection_ia(testEllVec)', errorStr);
        end
        function self = testContains(self)            
            [testEll1Vec, testEll2Vec] = createTypicalArray(7);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(1, all(testResVec(:)));
            [testEll1Vec, testEll2Vec] = createTypicalArray(8);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(0, any(testResVec(:)));
            testResVec = contains(testEll2Vec, testEll1Vec);
            mlunit.assert_equals(1, all(testResVec(:)));
            [testEll1Vec, testEll2Vec] = createTypicalArray(9);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(0, any(testResVec(:)));
            testResVec = contains(testEll2Vec, testEll1Vec);
            mlunit.assert_equals(1, all(testResVec(:)));
            [testEll1Vec, testEll2Vec] = createTypicalArray(10);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(0, any(testResVec(:)));
            testResVec = contains(testEll2Vec, testEll1Vec);
            mlunit.assert_equals(0, any(testResVec(:)));
        end        
        function self = testIsInternal(self)
            [testEllVec, testPointVec] = createTypicalArray(11);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([1, 1, 1], testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert([1, 1, 1], testResVec);
            [testEllVec, testPointVec] = createTypicalArray(12);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([0, 0], testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert([0, 0], testResVec);
            [testEllVec, testPointVec] = createTypicalArray(13);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([1, 1, 1, 1, 1], testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert([1, 1, 1, 1, 1], testResVec);
            [testEllVec, testPointVec] = createTypicalArray(14);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([1, 1, 1, 1, 0, 0, 0, 0], testResVec);
            [testEllVec, testPointVec] = createTypicalArray(15);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([0, 0, 0, 0, 0, 0, 0, 0, 1], testResVec);
            testResVec = isinternal(testEllVec, testPointVec, 'u');
            self.flexAssert([1, 1, 1, 1, 1, 1, 1, 1, 1], testResVec);            
        end  
        function self = testHpIntersection(self)
            [testEllArray, testHpArray, ansEllArray] = ...
                createTypicalArray(16);
            resEllArray = hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            [testEllArray, testHpArray, ansEllArray] = ...
                createTypicalArray(17);
            resEllArray = hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            [testEllArray, testHpArray, ansEllArray, ...
                isnAnsIntersectedArray] = createTypicalArray(18);
            [resEllArray, isnIntersectedArray] = ...
                hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            testResArray = eq(isnIntersectedArray, isnAnsIntersectedArray);
            self.flexAssert(true, all(testResArray(:)));
            [testEllArray, testHpArray, ansEllArray] = ...
                createTypicalArray(19);
            resEllArray = hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            [testEllArray, testHpArray, errorStr] = ...
                createTypicalArray(20);
            self.runAndCheckError ...
                ('resEllVec = hpintersection(testEllArray, testHpArray)',...
                errorStr);
        end
        function flexAssert(varargin)
            IS_ASSERTION_ON = true;
            if (IS_ASSERTION_ON)
                mlunit.assert_equals(varargin{2:end});
            end;
        end
    end    
end
function [varargout] = createTypicalArray(flag)
    switch flag
        case 1
            arraySize = [2, 1, 3, 2, 1, 1, 4];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                3, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ell_unitball(3);
        case 2
            arraySize = [1, 2, 4, 3, 2];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                2, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ell_unitball(2);
        case 3
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                4, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = ell_unitball(4);
        case 4
            myMat = diag(ones(1, 4));
            arraySize = [2, 1, 1, 2, 3, 3];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                4, 1, 1);
            myEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
            varargout{1} = myEllArray;
            varargout{2} = ellipsoid([0; 0; 0; 0], diag(4 * ones(1, 4)));
        case 5
            myMat = diag(ones(1, 4));
            arraySize = [2, 1, 1, 2, 3, 3];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            myEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
            varargout{1} = myEllArray;
            varargout{2} = ellipsoid([0; 0; 0; 0], diag(zeros(1, 4)));
        case 6
            myMat = diag(ones(1, 4));
            arraySize = [1, 2, 1, 3, 1, 3];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                4, 1, 1);
            myEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 10].', myMat);
            myEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -10].', myMat);
            varargout{1} = myEllArray;
            varargout{2} = 'cvxError';
        case 7
            arraySize = [2, 1, 1, 1, 3, 1, 1];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ...
                3, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = myEllArray;
        case 8
            arraySize = [1, 2, 3, 1, 2, 1];
            my1EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                2, 1, 1);
            my2EllArray = createObjectArray(arraySize, @ellipsoid, ...
                zeros(2, 1), diag( 1.1 * ones(1, 2)), 2);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 9
            arraySize = [1, 1, 1, 1, 1, 4, 1, 1, 3];
            my1EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            my2EllArray = createObjectArray(arraySize, @ellipsoid, ...
                3 * ones(4, 1), diag( 64 * ones(1, 4)), 2);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 10
            arraySize = [2, 1, 1, 1, 1, 3, 1];
            my1EllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            my2EllArray = createObjectArray(arraySize, @ellipsoid, ...
                5 * ones(4, 1), diag( 2 * ones(1, 4)), 2);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 11
            arraySize = [2, 3, 2, 1, 1, 1, 4];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                3, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = 0.9 * eye(3);
        case 12
            arraySize = [1, 2, 2, 3, 1, 4];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                2, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = 1.1 * eye(2);
        case 13
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                5, 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = 0.9 * eye(5);
        case 14
            arraySize = [2, 1, 2, 1, 3, 3];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            myMat = 0.9 * eye(4);
            myMat = [myMat, 1.1 * eye(4)];
            varargout{1} = myEllArray;
            varargout{2} = myMat;
        case 15
            myMat = eye(4);
            arraySize = [2, 1, 2, 1, 3, 3];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            myEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
            myMat = [0.9 * eye(4), 1.9 * eye(4), zeros(4, 1)];
            varargout{1} = myEllArray;
            varargout{2} = myMat;
        case 16
            arraySize = [2, 2, 3, 1, 1, 1, 4];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                3, 1, 1);
            myHpArray = createObjectArray(arraySize, @hyperplane, ... 
                [0, 0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
                [1, 0, 0; 0, 1, 0; 0, 0, 0], 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = myHpArray;    
            varargout{3} = ansEllArray;
        case 17
            arraySize = [1, 2, 2, 3, 1, 4];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                2, 1, 1);
            myHpArray = createObjectArray(arraySize, @hyperplane, ... 
                [0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
                [1, 0; 0, 0], 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = myHpArray;    
            varargout{3} = ansEllArray;
        case 18
            arraySize = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            myHpArray = createObjectArray(arraySize, @hyperplane, ... 
                [0, 0, 0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
                [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 0], 1, 1);
            varargout{1} = myEllArray;
            varargout{2} = myHpArray;    
            varargout{3} = ansEllArray;
            varargout{4} = false(1, 1, 1, 1, 1, 7, 1, 1, 7);
        case 19
            myMat = diag(ones(1, 4));
            arraySize = [2, 1, 1, 3, 3, 3];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                4, 1, 1);
            myEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
            myEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
            myEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
            myHpArray = createObjectArray(arraySize, @hyperplane, ... 
                [0, 0, 1, 0].', 0, 2);
            myMat = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 0, 0; 0, 0, 0, 1];
            ansEllArray = createObjectArray(arraySize, @ellipsoid, ... 
                myMat, 1, 1);
            ansEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', myMat);
            ansEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', myMat);
            ansEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 0 0].', ...
                diag( zeros(1, 4)));
            ansEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 0 0].', zeros(4));
            ansEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', myMat);
            ansEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', myMat);
            ansEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', myMat);
            ansEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', myMat);
            varargout{1} = myEllArray;
            varargout{2} = myHpArray;    
            varargout{3} = ansEllArray;
        case 20
            arraySize = [2, 2, 3, 1, 1, 1, 4];
            myEllArray = createObjectArray(arraySize, @ell_unitball, ... 
                3, 1, 1);
            myHpArray = createObjectArray(arraySize, @hyperplane, ... 
                [0, 0, 1].', -2, 2);
            varargout{1} = myEllArray;
            varargout{2} = myHpArray;    
            varargout{3} = 'degenerateEllipsoid';
        otherwise
    end
end
function objectArray = createObjectArray(arraySize, func, firstArg, ...
    secondArg, nArg)
    nElems = prod(arraySize, 2);
    firstArgCArray = repmat({firstArg}, 1, nElems);
    if (nArg == 1)
        objectCArray = cellfun(func, firstArgCArray, ...
            'UniformOutput', false);
    else
        secondArgCArray = repmat({secondArg}, 1, nElems);
        objectCArray = cellfun(func, firstArgCArray, secondArgCArray, ...
            'UniformOutput', false);
    end
    objectArray = reshape([objectCArray{:}], arraySize);
end