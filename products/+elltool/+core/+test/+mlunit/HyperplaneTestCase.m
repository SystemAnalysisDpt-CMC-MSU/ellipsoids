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
        
        function self = testHyperplaneAndDouble(self)  
            %method double is implicitly tested in every comparison between
            %hyperplanes contents and normals and constants, from which it 
            %was constructed(in function isNormalAndConstantRight)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testNormalVec = testDataStructure.testNormalVec;
            testConstant = testDataStructure.testConstant;
            %
            %simple construction test
            testingHyraplane = hyperplane(testNormalVec, testConstant);
            res = self.isNormalAndConstantRight(testNormalVec, testConstant,testingHyraplane);
            mlunit.assert_equals(1, res);
            %
            %omitting constant test
            testConstant = 0;
            testingHyraplane = hyperplane(testNormalVec);
            res = self.isNormalAndConstantRight(testNormalVec, testConstant,testingHyraplane);
            mlunit.assert_equals(1, res);
            %
            %
            testNormalsMat = testDataStructure.testNormalsMat;
            testConstantVec = testDataStructure.testConstants;
            %
            %mutliple Hyperplane test
            testingHyraplaneVec = hyperplane(testNormalsMat, testConstantVec);
            %
            nHypeplanes = size(testNormalsMat,2);
            nRes = 0;
            for iHyperplane = 1:nHypeplanes
                nRes = nRes + self.isNormalAndConstantRight(testNormalsMat(:,iHyperplane),...
                    testConstantVec(iHyperplane), testingHyraplaneVec(iHyperplane));
            end
            mlunit.assert_equals(nHypeplanes, nRes);
            %
            %mutliple Hyperplane one constant test
            testNormalsMat = [[3; 4; 43; 1], [1; 0; 3; 3], [5; 2; 2; 12]];
            testConstant = 2;
            testingHyraplaneVec = hyperplane(testNormalsMat, testConstant);
            %
            nHypeplanes = size(testNormalsMat,2);
            nRes = 0;
            for iHyperplane = 1:nHypeplanes
                nRes = nRes + self.isNormalAndConstantRight(testNormalsMat(:,iHyperplane),...
                    testConstant, testingHyraplaneVec(iHyperplane));
            end
            mlunit.assert_equals(nHypeplanes, nRes);
        end
        %
        function self = testContains(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            %
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            testVectorsMat = testDataStructure.testVectorsMat;
            isContainedVec = testDataStructure.isContainedVec;
            isContainedTestedVec = contains(testHyperplanesVec,testVectorsMat);
            isOk = all(isContainedVec == isContainedTestedVec);
            %
            mlunit.assert(isOk);
        end
        %
        function self = testDimensions(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            dimensionsVec = testDataStructure.dimensionsVec;
            dimensionsTestedVec = dimension(testHyperplanesVec);
            isOk = all(dimensionsVec == dimensionsTestedVec);
            mlunit.assert(isOk);
        end
        %
        %
        function self = testEqAndNe(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            compareHyperplanesVec = testDataStructure.compareHyperplanesVec;
            isEqVec = testDataStructure.isEqVec;
            %
            testedIsEqVec = eq(testHyperplanesVec,compareHyperplanesVec);
            testedNeVec = ne(testHyperplanesVec,compareHyperplanesVec);
            %
            isOk = all(isEqVec == testedIsEqVec);
            mlunit.assert(isOk);
            %
            isOk =  all(isEqVec ~= testedNeVec);
            mlunit.assert(isOk);
        end
        %
        function self = testIsEmpty(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            isEmptyVec = testDataStructure.isEmptyVec;
            isEmptyTestedVec = isempty(testHyperplanesVec);
            isOk = all(isEmptyVec == isEmptyTestedVec);
            mlunit.assert(isOk);
        end
        %
        function self = testIsParallel(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testHyperplanesVec = testDataStructure.testHyperplanesVec;
            isParallelVec = testDataStructure.isParallelVec;
            compareHyperplanesVec  = testDataStructure.compareHyperplanesVec;
            %
            testedIsParallel = isparallel(testHyperplanesVec,compareHyperplanesVec);
            isOk = all(testedIsParallel == isParallelVec);
            %
            mlunit.assert(isOk);
        end
        %
        function self = testUminus(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testNormalVec = testDataStructure.testNormalVec;
            testConstant = testDataStructure.testConstant;
            testHyraplane = hyperplane(testNormalVec, testConstant);
            minusTestHyraplane = uminus(testHyraplane);
            res = self.isNormalAndConstantRight(-testNormalVec, -testConstant,minusTestHyraplane);
            mlunit.assert_equals(1, res);
        end
        %
        function self = testDisplay(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testHyperplane = testDataStructure.testHyperplane;
            display(testHyperplane);
            testHyperplaneVec = testDataStructure.testHyperplaneVec;
            display(testHyperplaneVec);
        end
        %
        function self = testPlot(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testHyperplane3DVec1 = testDataStructure.testHyperplaneVec3D1;
            testHyperplane3DVec2 = testDataStructure.testHyperplaneVec3D2;
            testHyperplane2DVec = testDataStructure.testHyperplaneVec2D;
            testOptions = testDataStructure.testOptions;
            %
            plot(testHyperplane3DVec1);
            plot(testHyperplane2DVec);
            plot(testHyperplane3DVec1,testOptions);
            plot(testHyperplane3DVec1,'g',testHyperplane3DVec2,'r');            
        end
        %    
        function self = testWrongInput(self)
            methodName=modgen.common.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            testDataStructure = load(inpFileName);
            testConstant = testDataStructure.testConstant;
            testHyperplane = testDataStructure.testHyperplane;
            nanVector = testDataStructure.nanVector;
            infVector = testDataStructure.infVector;
            %
            self.runAndCheckError('contains(testHyperplane,nanVector)',...
                'wrongInput',['X is expected to comply with all ',...
                'of the following conditions: ~any(isnan(x1(:)))']);
            self.runAndCheckError('hyperplane(infVector,testConstant)',...
                'wrongInput',...
                ['v,c is expected to comply with all of the following ',...
                'conditions: ~(any( isnan(x1(:)) ) || any(isinf(x1(:))) ',...
                '|| any(isnan(x2(:))) || any(isinf(x2(:))))']);
            self.runAndCheckError('hyperplane(nanVector,testConstant)',...
                'wrongInput',...
                ['v,c is expected to comply with all of the ',...
                'following conditions: ~(any( isnan(x1(:)) ) || ',...
                'any(isinf(x1(:))) || any(isnan(x2(:))) || any(isinf(x2(:))))']);
        end
    end
    %
    methods(Static)
         function res = isNormalAndConstantRight(testNormal, testConstant, testingHyraplane)
            [resultNormal, resultConstant] = double(testingHyraplane);
            %
            testNormalSize = size(testNormal);
            resultNormalSize = size(resultNormal);
            %
            isSizesMatch = (testNormalSize(1) == resultNormalSize(1)) &&...
                (testNormalSize(2) == resultNormalSize(2));
            %
            if(isSizesMatch)
                res = all(testNormal == resultNormal) && (testConstant == ...
                    resultConstant);
            else
                res = false;
            end
         end             
    end
end