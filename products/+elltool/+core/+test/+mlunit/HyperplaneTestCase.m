classdef HyperplaneTestCase < mlunitext.test_case
    properties (Access=private)
        testDataRootDir
    end
    methods
        function self = HyperplaneTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];     
        end
        
        function self = testIsRightConstructedAndDouble(self)  
            %method double is implicitly tested in every comparison between
            %hyperplanes contents and normals and constants, from which it 
            %was constructed(in function isNormalAndConstantRight)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            testDataStructure = load(inpFileName);
            testNormalVec = testDataStructure.testNormalVec;
            testConstant = testDataStructure.testConstant;
            
            %simple construction test
            testingHyraplane = hyperplane(testNormalVec, testConstant);
            res = self.isNormalAndConstantRight(testNormalVec, testConstant,testingHyraplane);
            mlunit.assert_equals(1, res);
            
            
            %omitting constant test
            testConstant = 0;
            testingHyraplane = hyperplane(testNormalVec);
            res = self.isNormalAndConstantRight(testNormalVec, testConstant,testingHyraplane);
            mlunit.assert_equals(1, res);
            
            
            testNormalsMat = testDataStructure.testNormalsMat;
            testConstants = testDataStructure.testConstants;
            %mutliple Hyperplane test
            testingHyraplaneVec = hyperplane(testNormalsMat, testConstants);
            
            nHypeplanes = size(testNormalsMat,2);
            res = 0;
            for iHyperplanes = 1:nHypeplanes
                res = res + self.isNormalAndConstantRight(testNormalsMat(:,iHyperplanes),...
                    testConstants(iHyperplanes), testingHyraplaneVec(iHyperplanes));
            end
            mlunit.assert_equals(nHypeplanes, res);
            
            %mutliple Hyperplane one constant test
            testNormalsMat = [[3; 4; 43; 1], [1; 0; 3; 3], [5; 2; 2; 12]];
            testConstant = 2;
            testingHyraplaneVec = hyperplane(testNormalsMat, testConstant);
            
            nHypeplanes = size(testNormalsMat,2);
            res = 0;
            for iHyperplanes = 1:nHypeplanes
                res = res + self.isNormalAndConstantRight(testNormalsMat(:,iHyperplanes),...
                    testConstant, testingHyraplaneVec(iHyperplanes));
            end
            mlunit.assert_equals(nHypeplanes, res);
        end
        
        function self = testContains(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            testDataStructure = load(inpFileName);
            
            containedVec = testDataStructure.containedVec;
            notContainedVec = testDataStructure.notContainedVec;
            
            testHyperplane = testDataStructure.testHyperplane;
            res = contains(testHyperplane,containedVec);
            mlunit.assert_equals(1, res);
            
            res = contains(testHyperplane,notContainedVec);
            mlunit.assert_equals(0, res);
            
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            testVectorsMat = testDataStructure.testVectorsMat;
            isContainedVec = testDataStructure.isContainedVec;
            isContainedVecTested = contains(testHyperplanesVec,testVectorsMat);
            res = sum(isContainedVec == isContainedVecTested) == size(isContainedVec,2);
            
            mlunit.assert_equals(1, res);
        end
        
        function self = testDimensions(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            testDataStructure = load(inpFileName);
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            dimensionsVec = testDataStructure.dimensionsVec;
            dimensionsVecTested = dimension(testHyperplanesVec);
            res = sum(dimensionsVec == dimensionsVecTested) == size(dimensionsVec,2);
            mlunit.assert_equals(1, res);
        end
        
        function self = testIsEmpty(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            testDataStructure = load(inpFileName);
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            isEmptyVec = testDataStructure.isEmptyVec;
            isEmptyVecTested = isempty(testHyperplanesVec);
            res = sum(isEmptyVec == isEmptyVecTested) == size(isEmptyVec,2);
            mlunit.assert_equals(1, res);
        end
        
        function self = testUminus(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            testDataStructure = load(inpFileName);
            testNormal = testDataStructure.testNormal;
            testConstant = testDataStructure.testConstant;
            testHyraplane = hyperplane(testNormal, testConstant);
            minusTestHyraplane = uminus(testHyraplane);
            res = self.isNormalAndConstantRight(-testNormal, -testConstant,minusTestHyraplane);
            mlunit.assert_equals(1, res);
        end
        
        function self = testEq(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            testDataStructure = load(inpFileName);
            testNormal = testDataStructure.testNormal;
            testConstant = testDataStructure.testConstant;
            nEqualNormal1 = testDataStructure.nEqualNormal1;
            nEqualNormal2 =  testDataStructure.nEqualNormal2;
            nEqualConstant = testDataStructure.nEqualConstant;
            
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
            mlunit.assert_equals(0, res5);
        end
            
    end
    
    methods(Static)
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