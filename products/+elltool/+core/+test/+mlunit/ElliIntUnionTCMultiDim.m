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
        function flexAssert(varargin)
            IS_ASSERTION_ON = true;
            if (IS_ASSERTION_ON)
                mlunit.assert_equals(varargin{2:end});
            end;
        end;
        function self = testEllUnionEaSensitivity(self)
            [testEllVec, resultEll] = createTypicalArray(1);
            resEllVec = ellunion_ea(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
        end
        function self = testEllIntersectionIaSensitivity(self)
            [testEllVec, resultEll] = createTypicalArray(1);
            resEllVec = ellintersection_ia(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
        end
        function self = testContains(self)            
            [testEll1Vec, testEll2Vec] = createTypicalArray(2);
            testResVec = contains(testEll1Vec, testEll2Vec);
            mlunit.assert_equals(0, any(testResVec(:)));
            testResVec = contains(testEll2Vec, testEll1Vec);
            mlunit.assert_equals(1, all(testResVec(:)));         
        end        
        function self = testIsInternal(self)
            [testEllVec, testPointVec] = createTypicalArray(3);
            testResVec = isinternal(testEllVec, testPointVec, 'i');
            self.flexAssert([1, 1, 1, 1, 0, 0, 0, 0], testResVec);
        end
        function self = testEllintersectionIa(self)
            [testEllVec, resultEll] = createTypicalArray(1);
            resEllVec = ellintersection_ia(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
            
        end
        function self = testEllunionEa(self)
            [testEllVec, resultEll] = createTypicalArray(1);
            resEllVec = ellunion_ea(testEllVec);
            [isEqual, reportStr] = eq(resEllVec, resultEll);
            mlunit.assert_equals(true, isEqual, reportStr);
        end
        function self = testHpIntersection(self)
            [testEllArray, testHpArray, ansEllArray] = ...
                createTypicalArray(4);
            resEllArray = hpintersection(testEllArray, testHpArray);
            testResArray = eq(resEllArray, ansEllArray);
            self.flexAssert(true, all(testResArray(:)));
        end
    end
        
end
function [varargout] = createTypicalArray(flag)
    switch flag
        case 1
            myInt = 3;
            myEllArray(myInt, myInt, myInt, myInt, myInt, myInt, myInt) ...
                = ellipsoid;
            myEllArray(:, :, :, :, :, :, :) = ell_unitball(4);
            varargout{1} = myEllArray;
            varargout{2} = ell_unitball(4);
        case 2
            myInt = 3;
            my1EllArray(myInt, myInt, myInt, myInt, myInt, myInt, myInt) ...
                = ellipsoid;
            my1EllArray(:, :, :, :, :, :, :) = ell_unitball(4);
            my2EllArray(myInt, myInt, myInt, myInt, myInt, myInt, myInt) ...
                = ellipsoid;
            my2EllArray(:, :, :, :, :, :, :) = ellipsoid(zeros(4, 1), ...
                diag( 2 * ones(1, 4)));
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
        case 3
            myInt = 3;
            myEllArray(myInt, myInt, myInt, myInt, myInt, myInt) = ...
                ellipsoid;
            myEllArray( :, :, :, :, :, :) = ell_unitball(4);
            myMat = 0.8 * eye(4);
            myMat = [myMat, 1.2 * eye(4)];
            varargout{1} = myEllArray;
            varargout{2} = myMat;    
        case 4
            myInt = 3;
            myEllArray(myInt, myInt, myInt, myInt, myInt, myInt, myInt) ...
                = ellipsoid;
            myEllArray(:, :, :, :, :, :, :) = ellipsoid(eye(3));
            myHpArray(myInt, myInt, myInt, myInt, myInt, myInt, myInt) ...
                = hyperplane;
            myHpArray(:, :, :, :, :, :, :) = hyperplane([0, 0, 1].', 0);
            ansEllArray(myInt, myInt, myInt, myInt, myInt, myInt, ...
                myInt) = ellipsoid;
            ansEllArray(:, :, :, :, :, :, :) = ...
                ellipsoid([1, 0, 0; 0, 1, 0; 0, 0, 0]);
            varargout{1} = myEllArray;
            varargout{2} = myHpArray;    
            varargout{3} = ansEllArray;
        otherwise
    end
end