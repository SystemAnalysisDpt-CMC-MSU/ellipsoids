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
            [testEllArray, resultEll] = createTypicalArray(1);
            resEllVec = ellunion_ea(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllArray, resultEll] = createTypicalArray(2);
            resEllVec = ellunion_ea(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllArray, resultEll] = createTypicalArray(3);
            resEllVec = ellunion_ea(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            testMat = diag(ones(1, 4));
            arraySizeVec = [2, 1, 1, 2, 3, 3];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                4, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', testMat);
            resultEll = ellipsoid([0; 0; 0; 0], diag(4 * ones(1, 4)));
            resEllVec = ellunion_ea(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllArray, ~, errorStr] = createTypicalArray(4);
            self.runAndCheckError...
               ('ellunion_ea(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(5);
            self.runAndCheckError...
               ('ellunion_ea(testEllArray)', errorStr);
            [testEllArray, ~, errorStr] = createTypicalArray(6);
            self.runAndCheckError...
               ('ellunion_ea(testEllArray)', errorStr);
           [testEllArray, ~, errorStr] = createTypicalArray(7);
            self.runAndCheckError...
               ('ellunion_ea(testEllArray)', errorStr);
        end
        function self = testEllintersectionIa(self)
            [testEllArray, resultEll] = createTypicalArray(1);
            resEllVec = ellintersection_ia(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllArray, resultEll] = createTypicalArray(2);
            resEllVec = ellintersection_ia(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            [testEllArray, resultEll] = createTypicalArray(3);
            resEllVec = ellintersection_ia(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            testMat = diag(ones(1, 4));
            arraySizeVec = [2, 1, 1, 2, 3, 3];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', testMat);
            resultEll = ellipsoid([0; 0; 0; 0], diag(zeros(1, 4)));
            resEllVec = ellintersection_ia(testEllArray);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
                testMat = diag(ones(1, 4));
            arraySizeVec = [1, 2, 1, 3, 1, 3];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                4, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 10].', testMat);
            testEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -10].', testMat);
            errorStr = 'cvxError';
            self.runAndCheckError...
               ('ellintersection_ia(testEllArray)', errorStr);
        end
        function self = testContains(self)    
            arraySizeVec = [2, 1, 1, 1, 3, 1, 1];
            testEll1Array = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            testEll2Array = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            testResVec = contains(testEll1Array, testEll2Array);
            mlunit.assert_equals(1, all(testResVec(:)));
            arraySizeVec = [1, 2, 3, 1, 2, 1];
            testEll1Array = createObjectArray(arraySizeVec, @ell_unitball, ... 
                2, 1, 1);
            testEll2Array = createObjectArray(arraySizeVec, @ellipsoid, ...
                zeros(2, 1), diag( 1.1 * ones(1, 2)), 2);
            testResVec = contains(testEll1Array, testEll2Array);
            mlunit.assert_equals(0, any(testResVec(:)));
            testResVec = contains(testEll2Array, testEll1Array);
            mlunit.assert_equals(1, all(testResVec(:)));
            arraySizeVec = [1, 2, 3, 1, 2, 1];
            testEll1Array = createObjectArray(arraySizeVec, @ell_unitball, ... 
                2, 1, 1);
            testEll2Array = createObjectArray(arraySizeVec, @ellipsoid, ...
                zeros(2, 1), diag( 1.1 * ones(1, 2)), 2);
            testResVec = contains(testEll1Array, testEll2Array);
            mlunit.assert_equals(0, any(testResVec(:)));
            testResVec = contains(testEll2Array, testEll1Array);
            mlunit.assert_equals(1, all(testResVec(:)));
            arraySizeVec = [2, 1, 1, 1, 1, 3, 1];
            testEll1Array = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            testEll2Array = createObjectArray(arraySizeVec, @ellipsoid, ...
                5 * ones(4, 1), diag( 2 * ones(1, 4)), 2);
            testResVec = contains(testEll1Array, testEll2Array);
            mlunit.assert_equals(0, any(testResVec(:)));
            testResVec = contains(testEll2Array, testEll1Array);
            mlunit.assert_equals(0, any(testResVec(:)));
        end        
        function self = testIsInternal(self)
            arraySizeVec = [2, 3, 2, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                3, 1, 1);
            testPointVec = 0.9 * eye(3);
            testResVec = isinternal(testEllArray, testPointVec, 'i');
            self.flexAssert([1, 1, 1], testResVec);
            testResVec = isinternal(testEllArray, testPointVec, 'u');
            self.flexAssert([1, 1, 1], testResVec);
            arraySizeVec = [1, 2, 2, 3, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                2, 1, 1);
            testPointVec = 1.1 * eye(2);
            testResVec = isinternal(testEllArray, testPointVec, 'i');
            self.flexAssert([0, 0], testResVec);
            testResVec = isinternal(testEllArray, testPointVec, 'u');
            self.flexAssert([0, 0], testResVec);
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                5, 1, 1);
            testPointVec = 0.9 * eye(5);
            testResVec = isinternal(testEllArray, testPointVec, 'i');
            self.flexAssert([1, 1, 1, 1, 1], testResVec);
            testResVec = isinternal(testEllArray, testPointVec, 'u');
            self.flexAssert([1, 1, 1, 1, 1], testResVec);
            arraySizeVec = [2, 1, 2, 1, 3, 3];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            testMat = 0.9 * eye(4);
            testMat = [testMat, 1.1 * eye(4)];
            testPointVec = testMat;
            testResVec = isinternal(testEllArray, testPointVec, 'i');
            self.flexAssert([1, 1, 1, 1, 0, 0, 0, 0], testResVec);
            testMat = eye(4);
            arraySizeVec = [2, 1, 2, 1, 3, 3];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', testMat);
            testMat = [0.9 * eye(4), 1.9 * eye(4), zeros(4, 1)];
            testPointVec = testMat;
            testResVec = isinternal(testEllArray, testPointVec, 'i');
            self.flexAssert([0, 0, 0, 0, 0, 0, 0, 0, 1], testResVec);
            testResVec = isinternal(testEllArray, testPointVec, 'u');
            self.flexAssert([1, 1, 1, 1, 1, 1, 1, 1, 1], testResVec);            
        end  
        function self = testHpIntersection(self)
            arraySizeVec = [2, 2, 3, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                3, 1, 1);
            testHpArray = createObjectArray(arraySizeVec, @hyperplane, ... 
                [0, 0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                [1, 0, 0; 0, 1, 0; 0, 0, 0], 1, 1);
            resEllArray = hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            arraySizeVec = [1, 2, 2, 3, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                2, 1, 1);
            testHpArray = createObjectArray(arraySizeVec, @hyperplane, ... 
                [0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                [1, 0; 0, 0], 1, 1);
            resEllArray = hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            testHpArray = createObjectArray(arraySizeVec, @hyperplane, ... 
                [0, 0, 0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 0], 1, 1);
            isnAnsIntersectedArray = false(1, 1, 1, 1, 1, 7, 1, 1, 7);
            [resEllArray, isnIntersectedArray] = ...
                hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            testResArray = eq(isnIntersectedArray, isnAnsIntersectedArray);
            self.flexAssert(true, all(testResArray(:)));
            testMat = diag(ones(1, 4));
            arraySizeVec = [2, 1, 1, 3, 3, 3];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 -1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', testMat);
            testHpArray = createObjectArray(arraySizeVec, @hyperplane, ... 
                [0, 0, 1, 0].', 0, 2);
            testMat = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 0, 0; 0, 0, 0, 1];
            ansEllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                testMat, 1, 1);
            ansEllArray(1, 1, 1, 1, 1, 1) = ellipsoid([0 0 0 1].', testMat);
            ansEllArray(1, 1, 1, 1, 1, 2) = ellipsoid([0 0 0 -1].', testMat);
            ansEllArray(1, 1, 1, 1, 1, 3) = ellipsoid([0 0 0 0].', ...
                diag( zeros(1, 4)));
            ansEllArray(1, 1, 1, 1, 2, 1) = ellipsoid([0 0 0 0].', zeros(4));
            ansEllArray(1, 1, 1, 1, 2, 2) = ellipsoid([0 1 0 0].', testMat);
            ansEllArray(1, 1, 1, 1, 2, 3) = ellipsoid([0 -1 0 0].', testMat);
            ansEllArray(1, 1, 1, 1, 3, 1) = ellipsoid([1 0 0 0].', testMat);
            ansEllArray(1, 1, 1, 1, 3, 2) = ellipsoid([-1 0 0 0].', testMat);
            resEllArray = hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            arraySizeVec = [2, 2, 3, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                3, 1, 1);
            testHpArray = createObjectArray(arraySizeVec, @hyperplane, ... 
                [0, 0, 1].', -2, 2);   
            errorStr = 'degenerateEllipsoid';
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
            arraySizeVec = [2, 1, 3, 2, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ell_unitball(3);
        case 2
            arraySizeVec = [1, 2, 4, 3, 2];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                2, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ell_unitball(2);
        case 3
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                4, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ell_unitball(4);
        case 4
            testEllArray = ellipsoid.empty(1, 0, 0, 1, 5);
            arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyArray';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 5
            arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            testEllArray(2, 1, 1, 2, 1, 3, 1) = ellipsoid;
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyElement';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 6
            arraySizeVec = [2, 1, 1, 2, 1, 1, 1];
            testEllArray(arraySizeVec) = ellipsoid;
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyElement';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 7
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

        case 8
            testHpArray = hyperplane.empty(1, 0, 0, 2, 5);
            arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
            test2HpArray = createObjectArray(arraySizeVec, @hyperplane, ... 
                [0, 0, 1].', -2, 2);   
            errorStr = 'wrongInput:emptyArray';
            varargout{1} = testHpArray;
            varargout{2} = test2HpArray;
            varargout{3} = errorStr;
        otherwise
    end
end
function objectArray = createObjectArray(arraySizeVec, func, firstArg, ...
    secondArg, nArg)
    nElems = prod(arraySizeVec, 2);
    firstArgCArray = repmat({firstArg}, 1, nElems);
    if (nArg == 1)
        objectCArray = cellfun(func, firstArgCArray, ...
            'UniformOutput', false);
    else
        secondArgCArray = repmat({secondArg}, 1, nElems);
        objectCArray = cellfun(func, firstArgCArray, secondArgCArray, ...
            'UniformOutput', false);
    end
    objectArray = reshape([objectCArray{:}], arraySizeVec);
end