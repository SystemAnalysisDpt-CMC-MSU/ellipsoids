classdef HyperplaneTestCase < mlunitext.test_case
    methods
        function self = HyperplaneTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
        end
        
        function self = testIsRightConstructed(self)
            %simple construction test
            testNormal = [1; 0; 3];
            testConstant = 1;
            testingHyraplane = hyperplane(testNormal, testConstant);
            res = isNormalAndConstantRight(testNormal, testConstant,testingHyraplane);
            mlunit.assert_equals(1, res);
            
            
            %omitting constant test
            testNormal = [1; 0; 3];
            testConstant = 0;
            testingHyraplane = hyperplane(testNormal);
            res = isNormalAndConstantRight(testNormal, testConstant,testingHyraplane);
            mlunit.assert_equals(1, res);
            
            %mutliple Hyperplane test
            testNormals = [[3; 4; 43; 1], [1; 0; 3; 3], [5; 2; 2; 12]];
            testConstants = [1 2 3];
            testingHyraplanes = hyperplane(testNormals, testConstants);
            
            nHypeplanes = size(testNormals,2);
            res = 0;
            for iHyperplanes = 1:nHypeplanes
                res = res + isNormalAndConstantRight(testNormal(iHyperplanes),...
                    testConstants(iHyperplanes), testingHyraplanes(iHyperplanes));
            end
            mlunit.assert_equals(nHypeplanes, res);
            
            %mutliple Hyperplane one constant test
            testNormals = [[3; 4; 43; 1], [1; 0; 3; 3], [5; 2; 2; 12]];
            testConstant = 2;
            testingHyraplanes = hyperplane(testNormals, testConstant);
            
            nHypeplanes = size(testNormals,2);
            res = 0;
            for iHyperplanes = 1:nHypeplanes
                res = res + isNormalAndConstantRight(testNormal(iHyperplanes),...
                    testConstant, testingHyraplanes(iHyperplanes));
            end
            mlunit.assert_equals(nHypeplanes, res);
        end
        
        function self = testUminus(self)
            testNormal = [1; 0; 3];
            testConstant = 1;
            testHyraplane = hyperplane(testNormal, testConstant);
            minusTestHyraplane = uminus(testHyraplane);
            res = isNormalAndConstantRight(-testNormal, -testConstant,minusTestHyraplane);
            mlunit.assert_equals(1, res);
        end
        
        function self = testEq(self)
            testNormal = [1; 0; 3];
            testConstant = 1;
            nEqualNormal1 = [2; 4; 3];
            nEqualNormal2 = [1; 0; 3; 1];
            nEqualConstant = 2;
            
            etalonHyraplane = hyperplane(testNormal, testConstant);
            equalHyperaplane1 = hyperplane(testNormal, testConstant);
            equalHyperaplane2 = hyperplane(testNormal*2, testConstant*2);
            equalHyperaplane3 = hyperplane(-testNormal, -testConstant);
            nEqualHyperplane1 = hyperplane(nEqualNormal1, nEqualConstant);
            nEqualHyperplane2 = hyperplane(nEqualNormal2, testConstant);
            
            
            res1 = eq(etalonHyraplane,equalHyperaplane1);
            mlunit.assert_equals(1, res1);
            res2 = eq(etalonHyraplane,equalHyperaplane2);
            mlunit.assert_equals(1, res2);
            res3 = eq(etalonHyraplane,equalHyperaplane3);
            mlunit.assert_equals(1, res3);
            res4 = eq(etalonHyraplane,nEqualHyperplane1);
            mlunit.assert_equals(0, res4);
            res5 = eq(etalonHyraplane,nEqualHyperplane2);
            mlunit.assert_equals(1, res5);
        end
            
        function res = isNormalAndConstantRight(testNormal, testConstant, testingHyraplane)
            [resultNormal, resultConstant] = double(testingHyraplane);
            
            testNormalSize = size(testNormal);
            resultNormalSize = size(resultNormal);
            
            isSizesMatch = (testNormalSize(1) == resultNormalSize(1)) &&...
                (testNormalSize(2) == resultNormalSize(2));
            
            if(isSizesMatch)
                res = sum(testNormal == resultNormal) && (testConstant == ...
                    resultConstant);
            else
                res = false;
            end
        end
    end
end