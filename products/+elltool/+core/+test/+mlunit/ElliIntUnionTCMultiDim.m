classdef ElliIntUnionTCMultiDim < mlunitext.test_case
%$Author: Igor Samokhin <igorian.vmk@gmail.com> $
%$Date: 2013-01-31 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $

    properties (Access=private)
        testDataRootDir
        ellFactoryObj
    end
    %
    methods
        function set_up_param(self)
            self.ellFactoryObj = elltool.core.test.mlunit.TEllipsoidFactory();
        end
    end
    methods
        function ellObj = ellipsoid(self, varargin)
            ellObj = self.ellFactoryObj.createInstance('ellipsoid', ...
                varargin{:});            
        end
        function ellObj = ell_unitball(self, varargin)
            ellObj = elltool.core.test.mlunit.tell_unitball(...
                self.ellFactoryObj, varargin{:});
        end
        function hpObj = hyperplane(self, varargin)
            hpObj = self.ellFactoryObj.createInstance('hyperplane', ...
                varargin{:});            
        end
    end
    %
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
            checkEllunionEaAndEllintersectionIa(self, true);
        end
        function self = testEllintersectionIa(self)
            checkEllunionEaAndEllintersectionIa(self, false);
        end
        function checkEllunionEaAndEllintersectionIa(self, isEllunionEa)
            testCorrect(1);
            testCorrect(2);
            testCorrect(3);
            [testEllArray, ~] = self.createTypicalArray(8);
            if isEllunionEa
                resultEll = self.ellipsoid([0; 0; 0; 0], diag(4 * ones(1, 4)));
            else
                resultEll = self.ellipsoid([0; 0; 0; 0], diag(zeros(1, 4)));
            end
            testCorrect(0);
            if ~isEllunionEa
                testMat = eye(4);
                arraySizeVec = [1, 2, 1, 3, 1, 3];
                testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ...
                    4, 1, 1);
                testEllArray(1, 1, 1, 1, 1, 1) = self.ellipsoid([0 0 0 10].', testMat);
                testEllArray(1, 1, 1, 1, 1, 2) = self.ellipsoid([0 0 0 -10].', testMat);
                errorStr = 'cvxError';
                testError(0);
            end
            testError(4);
            testError(5);
            testError(6);
            testError(7);
            function testCorrect(flag)
                if (flag > 0)
                    [testEllArray, resultEll] = self.createTypicalArray(flag);
                end
                if isEllunionEa
                    resEllVec = ellunion_ea(testEllArray);
                else
                    resEllVec = ellintersection_ia(testEllArray);
                end
                [isEq, reportStr] = isEqual(resEllVec, resultEll);
                mlunitext.assert_equals(true, isEq, reportStr);
            end
            function testError(flag)
                if (flag > 0)
                    [testEllArray, ~, errorStr] = self.createTypicalArray(flag);
                end
                if isEllunionEa
                    self.runAndCheckError...
                        ('testEllArray.ellunion_ea()', errorStr);
                else
                    self.runAndCheckError...
                        ('testEllArray.ellintersection_ia()', errorStr);
                end 
            end
        end
        function self = testDoesContain(self)    
            arraySizeVec = [2, 1, 1, 1, 3, 1, 1];
            test1EllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ...
                3, 1, 1);
            test2EllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ...
                3, 1, 1);
            testResVec = doesContain(test1EllArray, test2EllArray);
                mlunitext.assert_equals(true, all(testResVec(:)));
            arraySizeVec = [1, 2, 3, 1, 2, 1];
            test1EllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                2, 1, 1);
            test2EllArray = createObjectArray(arraySizeVec, @self.ellipsoid, ...
                zeros(2, 1), diag( 1.1 * ones(1, 2)), 2);
            testCorrect(false);
            testCorrect(true);
            arraySizeVec = [1, 2, 3, 1, 2, 1];
            test1EllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                2, 1, 1);
            test2EllArray = createObjectArray(arraySizeVec, @self.ellipsoid, ...
                zeros(2, 1), diag( 1.1 * ones(1, 2)), 2);
            testCorrect(false);
            testCorrect(true);
            arraySizeVec = [2, 1, 1, 1, 1, 3, 1];
            test1EllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                4, 1, 1);
            test2EllArray = createObjectArray(arraySizeVec, @self.ellipsoid, ...
                5 * ones(4, 1), diag( 2 * ones(1, 4)), 2);
            testCorrect(false);
            testResVec = doesContain(test2EllArray, test1EllArray);
                mlunitext.assert_equals(false, any(testResVec(:)));
            testError(4);
            testError(5);
            testError(6);
            testError(7);
            function testCorrect(isAllCheck)
                if (isAllCheck)
                    testResVec = doesContain(test2EllArray, test1EllArray);
                    mlunitext.assert_equals(true, all(testResVec(:)));
                else
                    testResVec = doesContain(test1EllArray, test2EllArray);
                    mlunitext.assert_equals(false, any(testResVec(:)));
                end
            end
            function testError(flag)
                [test1EllArray, test2EllArray, errorStr] = ...
                    self.createTypicalArray(flag);
                self.runAndCheckError...
                   ('test1EllArray.doesContain(test2EllArray)', errorStr);
                self.runAndCheckError...
                   ('test2EllArray.doesContain(test1EllArray)', errorStr);
                self.runAndCheckError...
                   ('test1EllArray.doesContain(test1EllArray)', errorStr);
            end
        end

        function self = testIsInternal(self)
            arraySizeVec = [2, 3, 2, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                3, 1, 1);
            testPointVec = 0.9 * eye(3);
            testCorrect(true, [1, 1, 1]);
            arraySizeVec = [1, 2, 2, 3, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                2, 1, 1);
            testPointVec = 1.1 * eye(2);
            testCorrect(true, [0, 0]);
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                5, 1, 1);
            testPointVec = 0.9 * eye(5);
            testCorrect(true, [1, 1, 1, 1, 1]);
            arraySizeVec = [2, 1, 2, 1, 3, 3];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                4, 1, 1);
            testMat = 0.9 * eye(4);
            testMat = [testMat, 1.1 * eye(4)];
            testPointVec = testMat;
            testCorrect(false, [1, 1, 1, 1, 0, 0, 0, 0]);
            [testEllArray, ~] = self.createTypicalArray(8);
            testMat = [0.9 * eye(4), 1.9 * eye(4), zeros(4, 1)];
            testPointVec = testMat;
            testCorrect(false, [0, 0, 0, 0, 0, 0, 0, 0, 1]);
            testResVec = isinternal(testEllArray, testPointVec, 'u');
            self.flexAssert([1, 1, 1, 1, 1, 1, 1, 1, 1], testResVec);   
            testError(4);
            testError(5);
            testError(6);
            testError(7);
            function testCorrect(isTwoCheck, AnsVec)
                testResVec = isinternal(testEllArray, testPointVec, 'i');
                self.flexAssert(AnsVec, testResVec);
                if (isTwoCheck)
                    testResVec = isinternal(testEllArray, testPointVec, 'u');
                    self.flexAssert(AnsVec, testResVec);
                end
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = self.createTypicalArray(flag);
                self.runAndCheckError...
                   ('testEllArray.isinternal(testPointVec)', errorStr);
            end
        end  
        function self = testHpIntersection(self)
            arraySizeVec = [2, 2, 3, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                3, 1, 1);
            testHpArray = createObjectArray(arraySizeVec, ...
                @(varargin)self.hyperplane(varargin{:}), [0, 0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySizeVec, @self.ellipsoid, ... 
                [1, 0, 0; 0, 1, 0; 0, 0, 0], 1, 1);
            testCorrect();
            arraySizeVec = [1, 2, 2, 3, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                2, 1, 1);
            testHpArray = createObjectArray(arraySizeVec, ...
                @(varargin)self.hyperplane(varargin{:}), [0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySizeVec, @self.ellipsoid, ... 
                [1, 0; 0, 0], 1, 1);
            testCorrect();
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                4, 1, 1);
            testHpArray = createObjectArray(arraySizeVec, ...
                @(varargin)self.hyperplane(varargin{:}), [0, 0, 0, 1].', 0, 2);
            ansEllArray = createObjectArray(arraySizeVec, @self.ellipsoid, ... 
                [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 0], 1, 1);
            isnAnsIntersectedArray = false(1, 1, 1, 1, 1, 7, 1, 1, 7);
            [resEllArray, isnIntersectedArray] = ...
                hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
            
            testResArray = eq(isnIntersectedArray, isnAnsIntersectedArray);
            self.flexAssert(true, all(testResArray(:)));
            
            [testEllArray, arraySizeVec] = self.createTypicalArray(8);
            testHpArray = createObjectArray(arraySizeVec,  ...
                @(varargin)self.hyperplane(varargin{:}), [0, 0, 1, 0].', 0, 2);
            testMat = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 0, 0; 0, 0, 0, 1];
            ansEllArray = createObjectArray(arraySizeVec, @self.ellipsoid, ... 
                testMat, 1, 1);
            ansEllArray(1, 1, 1, 1, 1, 1) = self.ellipsoid([0 0 0 1].', testMat);
            ansEllArray(1, 1, 1, 1, 1, 2) = self.ellipsoid([0 0 0 -1].', testMat);
            ansEllArray(1, 1, 1, 1, 1, 3) = self.ellipsoid([0 0 0 0].', ...
                diag( zeros(1, 4)));
            ansEllArray(1, 1, 1, 1, 2, 1) = self.ellipsoid([0 0 0 0].', zeros(4));
            ansEllArray(1, 1, 1, 1, 2, 2) = self.ellipsoid([0 1 0 0].', testMat);
            ansEllArray(1, 1, 1, 1, 2, 3) = self.ellipsoid([0 -1 0 0].', testMat);
            ansEllArray(1, 1, 1, 1, 3, 1) = self.ellipsoid([1 0 0 0].', testMat);
            ansEllArray(1, 1, 1, 1, 3, 2) = self.ellipsoid([-1 0 0 0].', testMat);
            testCorrect()
            arraySizeVec = [2, 2, 3, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @self.ell_unitball, ... 
                 3, 1, 1);
            testHpArray = createObjectArray(arraySizeVec,  ...
                @(varargin)self.hyperplane(varargin{:}), [0, 0, 1].', -2, 2);   
            ansEllArray = self.ellipsoid();
            testCorrect();
            testHpArray = self.hyperplane.empty(1, 0, 0, 2, 5);
            [~, testEllArray, errorStr, arraySizeVec] = ...
                self.createTypicalArray( 4);
            testError(0);
            testHpArray = createObjectArray(arraySizeVec, ...
                @(varargin)self.hyperplane(varargin{:}),  [0, 0, 1].', -2, 2);
            testHpArray(1, 1, 1, 2, 1, 1, 1) = self.hyperplane();
            errorStr = 'wrongInput:emptyHyperplane';
            testError(0);
          	testHpArray = createObjectArray(arraySizeVec, @(x)self.hyperplane(), ...
                3, 1, 1); 
            testError(0);
            testHpArray = createObjectArray(arraySizeVec, ...
                @(varargin)self.hyperplane(varargin{:}), [0, 0, 1].', 1, 2);
            testHpArray(1, 1, 1, 2, 1, 1, 1) = self.hyperplane([0, 1].', 1);
            [~, ~, errorStr] = self.createTypicalArray(7);
           testError(0);
             testHpArray(1, 1, 1, 2, 1, 1, 1) = self.hyperplane([0, 0, 1].', 1);
             testError(4);
             testError(5);
             testError(6);
             testError(7);       
             function testCorrect()
                resEllArray = hpintersection(testEllArray, testHpArray);
                testResArray = eq(resEllArray, ansEllArray);
                self.flexAssert(true, all(testResArray(:)));
            end
            function testError(flag)
                if (flag > 0)
                    [testEllArray, ~, errorStr] = ...
                        self.createTypicalArray(flag);
                end
                self.runAndCheckError...
                    ('testEllArray.hpintersection(testHpArray)', errorStr);
            end

        end
        function flexAssert(varargin)
            IS_ASSERTION_ON = true;
            if (IS_ASSERTION_ON)
                mlunitext.assert_equals(varargin{2:end});
            end;
        end
    end
    %
    methods (Access = private)
        function varargout = createTypicalArray(self, varargin)
            varargout = cell(1, nargout);
            if nargout > 0
                [varargout{:}] = createTypicalArray(self.ellFactoryObj,...
                    varargin{:});
            else
                createTypicalArray(self.ellFactoryObj, varargin{:});
            end
        end
    end
end
function [varargout] = createTypicalArray(ellFactoryObj, flag)
    import elltool.core.test.mlunit.*;
    arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
    switch flag
        case 1
            arraySizeVec = [2, 1, 3, 2, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 3, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = tell_unitball(ellFactoryObj, 3);
        case 2
            arraySizeVec = [1, 2, 4, 3, 2];
            testEllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 2, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = tell_unitball(ellFactoryObj, 2);
        case 3
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 4, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = tell_unitball(ellFactoryObj, 4);
        case 4
            ellObj = ellFactoryObj.createInstance('ellipsoid');
            testEllArray = ellObj.empty(1, 0, 0, 1, 5);
            test2EllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 3, 1, 1);
            errorStr = 'wrongInput:emptyArray';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
            varargout{4} = arraySizeVec;
        case 5
            testEllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 3, 1, 1);
            testEllArray(2, 1, 1, 2, 1, 3, 1) = ...
                ellFactoryObj.createInstance('ellipsoid');
            test2EllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 3, 1, 1);
            errorStr = 'wrongInput:emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 6
            testEllArray = createObjectArray(arraySizeVec, @(x) ...
                ellFactoryObj.createInstance('ellipsoid'), ...
                3, 1, 1);
            test2EllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 3, 1, 1);
            errorStr = 'wrongInput:emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 7
            testEllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, varargin{:}), 3, 1, 1);
            testEllArray(2, 1, 1, 1, 1, 1, 1) = ...
                tell_unitball(ellFactoryObj, 7);
            test2EllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, ...
                varargin{:}), 3, 1, 1);
            errorStr = 'wrongSizes';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 8
            testMat = eye(4);
            arraySizeVec = [2, 1, 1, 2, 3, 3];
            testEllArray = createObjectArray(arraySizeVec, @(varargin) ...
                tell_unitball(ellFactoryObj, ...
                varargin{:}), 4, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 1) = ellFactoryObj.createInstance(...
                'ellipsoid', [0 0 0 1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 2) = ellFactoryObj.createInstance(...
                'ellipsoid', [0 0 0 -1].', testMat);
            testEllArray(1, 1, 1, 1, 1, 3) = ellFactoryObj.createInstance(...
                'ellipsoid', [0 0 1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 1) = ellFactoryObj.createInstance(...
                'ellipsoid', [0 0 -1 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 2) = ellFactoryObj.createInstance(...
                'ellipsoid', [0 1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 2, 3) = ellFactoryObj.createInstance(...
                'ellipsoid', [0 -1 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 1) = ellFactoryObj.createInstance(...
                'ellipsoid', [1 0 0 0].', testMat);
            testEllArray(1, 1, 1, 1, 3, 2) = ellFactoryObj.createInstance(...
                'ellipsoid', [-1 0 0 0].', testMat);
            varargout{1} = testEllArray;
            varargout{2} = arraySizeVec;
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