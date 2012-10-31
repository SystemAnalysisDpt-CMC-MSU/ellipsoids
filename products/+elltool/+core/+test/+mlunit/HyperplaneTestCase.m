classdef HyperplaneTestCase < mlunitext.test_case
    % $Author: <Zakharov Eugene>  <justenterrr@gmail.com> $    $Date: <31 october> $
    % $Copyright: Moscow State University,
    %            Faculty of Computational Mathematics and Computer Science,
    %            System Analysis Department <2012> $
    %
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
            %
            SInpData =  self.auxReadFile(self);
            testNormalVec = SInpData.testNormalVec;
            testConstant = SInpData.testConstant;
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
            testNormalsMat = SInpData.testNormalsMat;
            testConstantVec = SInpData.testConstants;
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
            SInpData =  self.auxReadFile(self);
            %
            testHyperplanesVec = SInpData.testHyperplanesVec;
            testVectorsMat = SInpData.testVectorsMat;
            isContainedVec = SInpData.isContainedVec;
            isContainedTestedVec = contains(testHyperplanesVec,testVectorsMat);
            isOk = all(isContainedVec == isContainedTestedVec);
            %
            mlunit.assert(isOk);
        end
        %
        function self = testDimensions(self)
            SInpData =  self.auxReadFile(self);
            testHyperplanesVec = SInpData.testHyperplanesVec;
            dimensionsVec = SInpData.dimensionsVec;
            dimensionsTestedVec = dimension(testHyperplanesVec);
            isOk = all(dimensionsVec == dimensionsTestedVec);
            mlunit.assert(isOk);
        end
        %
        %
        function self = testEqAndNe(self)
            SInpData =  self.auxReadFile(self);
            testHyperplanesVec = SInpData.testHyperplanesVec;
            compareHyperplanesVec = SInpData.compareHyperplanesVec;
            isEqVec = SInpData.isEqVec;
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
            SInpData =  self.auxReadFile(self);;
            testHyperplanesVec = SInpData.testHyperplanesVec;
            isEmptyVec = SInpData.isEmptyVec;
            isEmptyTestedVec = isempty(testHyperplanesVec);
            isOk = all(isEmptyVec == isEmptyTestedVec);
            mlunit.assert(isOk);
        end
        %
        function self = testIsParallel(self)
            SInpData =  self.auxReadFile(self);
            testHyperplanesVec = SInpData.testHyperplanesVec;
            isParallelVec = SInpData.isParallelVec;
            compareHyperplanesVec  = SInpData.compareHyperplanesVec;
            %
            testedIsParallel = isparallel(testHyperplanesVec,compareHyperplanesVec);
            isOk = all(testedIsParallel == isParallelVec);
            %
            mlunit.assert(isOk);
        end
        %
        function self = testUminus(self)
            SInpData =  self.auxReadFile(self);
            testNormalVec = SInpData.testNormalVec;
            testConstant = SInpData.testConstant;
            testHyraplane = hyperplane(testNormalVec, testConstant);
            minusTestHyraplane = uminus(testHyraplane);
            res = self.isNormalAndConstantRight(-testNormalVec, -testConstant,minusTestHyraplane);
            mlunit.assert_equals(1, res);
        end
        %
        function self = testDisplay(self)
            SInpData =  self.auxReadFile(self);
            testHyperplane = SInpData.testHyperplane;
            display(testHyperplane);
            testHyperplaneVec = SInpData.testHyperplaneVec;
            display(testHyperplaneVec);
        end
        %
        function self = testPlot(self)
            SInpData =  self.auxReadFile(self);
            testHyperplane3D1Vec = SInpData.testHyperplaneVec3D1;
            testHyperplane3D2Vec = SInpData.testHyperplaneVec3D2;
            testHyperplane2DVec = SInpData.testHyperplaneVec2D;
            STestOptions = SInpData.testOptions;
            %
            plot(testHyperplane3D1Vec);
            plot(testHyperplane2DVec);
            plot(testHyperplane3D1Vec,STestOptions);
            plot(testHyperplane3D1Vec,'g',testHyperplane3D2Vec,'r');            
        end
        %    
        function self = testWrongInput(self)
            SInpData =  self.auxReadFile(self);
            testConstant = SInpData.testConstant;
            testHyperplane = SInpData.testHyperplane;
            nanVec = SInpData.nanVector;
            infVec = SInpData.infVector;
            %
            self.runAndCheckError('contains(testHyperplane,nanVec)','wrongInput',...
                'X is expected');
            self.runAndCheckError('hyperplane(infVec,testConstant)','wrongInput',...
                'v,c is');
            self.runAndCheckError('hyperplane(nanVec,testConstant)','wrongInput',...
                'v,c is');
        end
    end
    %
    methods(Static)
         function res = isNormalAndConstantRight(testNormal, testConstant, testingHyraplane)
            [resultNormal, resultConstant] = double(testingHyraplane);
            %
            testNormSizeVec = size(testNormal);
            resNormSizeVec = size(resultNormal);
            %
            isSizesMatch = (testNormSizeVec(1) == resNormSizeVec(1)) &&...
                (testNormSizeVec(2) == resNormSizeVec(2));
            %
            if(isSizesMatch)
                res = all(testNormal == resultNormal) && (testConstant == ...
                    resultConstant);
            else
                res = false;
            end
         end
         
         function SInpData = auxReadFile(self)
            methodName=modgen.common.getcallernameext(2);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            SInpData = load(inpFileName);
         end

    end
end