classdef HyperplaneTestCase < mlunitext.test_case
    %$Author: <Zakharov Eugene>  <justenterrr@gmail.com> $
    %$Date: 2012-10-31 $
    %$Copyright: Moscow State University,
    %            Faculty of Computational Mathematics
    %            and Computer Science,
    %            System Analysis Department <2012> $
    %
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
        function hpObj = hyperplane(self, varargin)
            hpObj = self.ellFactoryObj.createInstance('hyperplane', ...
                varargin{:});
        end
    end
    %
    methods
        function self = HyperplaneTestCase(varargin)
            self = self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        function tear_down(~)
            close all;
        end
        function self = testHyperplaneAndDouble(self)
            %method double is implicitly tested in every comparison between
            %hyperplanes contents and normals and constants, from which it
            %was constructed(in function isNormalAndConstantRight)
            %
            SInpData = self.auxReadFile(self);
            testNormalVec = SInpData.testNormalVec;
            testConst = SInpData.testConstant;
            %
            %simple construction test
            testingHyperplane = self.hyperplane(testNormalVec, testConst);
            res = self.isNormalAndConstantRight(testNormalVec, testConst,testingHyperplane);
            mlunitext.assert_equals(true, res);
            %
            %omitting constant test
            testConst = 0;
            testingHyperplane = self.hyperplane(testNormalVec);
            res = self.isNormalAndConstantRight(testNormalVec, testConst,testingHyperplane);
            mlunitext.assert_equals(true, res);
            %
            %
            testNormalsMat = SInpData.testNormalsMat;
            testConstantVec = SInpData.testConstants;
            %
            %mutliple Hyperplane test
            testingHyraplaneVec = self.hyperplane(testNormalsMat, testConstantVec);
            %
            nHypeplanes = size(testNormalsMat,2);
            nRes = 0;
            for iHyperplane = 1:nHypeplanes
                nRes = nRes + self.isNormalAndConstantRight(testNormalsMat(:,iHyperplane),...
                    testConstantVec(iHyperplane), testingHyraplaneVec(iHyperplane));
            end
            mlunitext.assert_equals(nHypeplanes, nRes);
            %
            %mutliple Hyperplane one constant test
            testNormalsMat = [[3; 4; 43; 1], [1; 0; 3; 3], [5; 2; 2; 12]];
            testConst = 2;
            testingHyraplaneVec = self.hyperplane(testNormalsMat, testConst);
            %
            nHypeplanes = size(testNormalsMat,2);
            nRes = 0;
            for iHyperplane = 1:nHypeplanes
                nRes = nRes + self.isNormalAndConstantRight(testNormalsMat(:,iHyperplane),...
                    testConst, testingHyraplaneVec(iHyperplane));
            end
            mlunitext.assert_equals(nHypeplanes, nRes);

            testNormArr = ones(10, 2, 2);
            testConstArr = 2*ones(2, 2);
            testHypArr = self.hyperplane(testNormArr, testConstArr);
            isPos = all(size(testHypArr) == [2, 2]);
            isPos = (isPos && ...
                (self.isNormalAndConstantRight(testNormArr(:, 1, 1), ...
                testConstArr(1, 1), testHypArr(1))));
            isPos = (isPos && ...
                (self.isNormalAndConstantRight(testNormArr(:, 1, 2), ...
                testConstArr(1, 2), testHypArr(3))));
            mlunitext.assert(isPos);
            %
            %mutliple constantants and single vector
            testNormalVec = [3; 4; 43; 1];
            testConst = [2,3,4,5,6,7];
            nConst=length(testConst);
            testingHyraplaneVec = self.hyperplane(testNormalVec, testConst);
            mlunitext.assert_equals(nConst,size(testingHyraplaneVec,2))
            mlunitext.assert_equals(1,size(testingHyraplaneVec,1))
            mlunitext.assert_equals(2,ndims(testingHyraplaneVec))
            %
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
            mlunitext.assert(isOk);

            testHyp = self.hyperplane([1; 0; 0], 1);
            testVectorsMat = [1 0 0 2; 0 1 0 0; 0 0 1 0];
            isContainedVec = contains(testHyp, testVectorsMat);
            isContainedTestedVec = [true; 0; 0; 0];
            isOk = all(isContainedVec == isContainedTestedVec);
            mlunitext.assert(isOk);

            testFstHyp = self.hyperplane([1; 0], 1);
            testSecHyp = self.hyperplane([1; 1], 1);
            testThrHyp = self.hyperplane([0; 1], 1);
            testHypMat = [testFstHyp testSecHyp; testFstHyp testThrHyp];
            testVectors = [1; 0];
            isContainedMat = contains(testHypMat, testVectors);
            isContainedTestedMat = [true false; true false];
            isOk = all(isContainedMat == isContainedTestedMat);
            mlunitext.assert(isOk);

            nElems = 24;
            testHypArr(nElems) = self.hyperplane();
            testHypArr(:) = self.hyperplane([1; 1], 1);
            testHypArr = reshape(testHypArr, [2 3 4]);
            testVectorsArr = zeros(2, 2, 3, 4);
            testVectorsArr(:, 2, 3 ,4) = [1; 1];
            isContainedArr = contains(testHypArr, testVectorsArr);
            isContainedTestedArr = false(2, 3, 4);
            isContainedTestedArr(end) = true;
            isOk = all(isContainedArr == isContainedTestedArr);
            mlunitext.assert(isOk);
        end
        %
        function self = testFromRepMat (self)
            sizeArr = [2, 3, 3, 5];
            hypArr = self.hyperplane.fromRepMat(sizeArr);
            isOkArr = hypArr.isEmpty();
            mlunitext.assert(all(isOkArr(:)));
            %
            sizeArr = [2, 3, 3 + 1i * eps / 10, 5];
            hypArr = self.hyperplane.fromRepMat(sizeArr);
            isOkArr = hypArr.isEmpty();
            mlunitext.assert(all(isOkArr(:)));
            %
            sizeArr = [1 3+1i*eps/2 5];
            hypConst = 3;
            hypNormVec = [2; 3];
            absTol = 1e-10;
            hyp = self.hyperplane(hypNormVec, hypConst, ...
                'absTol', absTol);
            hypArr = self.hyperplane.fromRepMat(hypNormVec,hypConst,sizeArr, ...
                'absTol',absTol);
            isOkArr = eq(hyp,hypArr);
            mlunitext.assert(all(isOkArr(:)));
            isOkArr = hypArr.getAbsTol() == absTol;
            mlunitext.assert(all(isOkArr));
            %
            sizeArr = [2 3+1i*eps*2 3 5]; %#ok<NASGU>
            eyeMat = eye(5); %#ok<NASGU>
            self.runAndCheckError('self.ellipsoid.fromRepMat(sizeArr)', ...
                'wrongInput');
            self.runAndCheckError('self.ellipsoid.fromRepMat(eyeMat)', ...
                'wrongInput');
        end
        %
        function self = testDimensions(self)
            SInpData =  self.auxReadFile(self);
            testHyperplanesVec = SInpData.testHyperplanesVec;
            dimensionsVec = SInpData.dimensionsVec;
            dimensionsTestedVec = dimension(testHyperplanesVec);
            isOk = all(dimensionsVec == dimensionsTestedVec);
            mlunitext.assert(isOk);
        end
        %
        function self = testEqAndNe(self)
            SInpData =  self.auxReadFile(self);
            testHyperplanesVec = SInpData.testHyperplanesVec;
            compareHyperplanesVec = SInpData.compareHyperplanesVec;
            addRelTol = @(S)self.hyperplane(S.normal, S.shift);
            testHyperplanesCVec=cell(size(testHyperplanesVec));
            for iHp = 1 : numel(testHyperplanesVec)
                testHyperplanesCVec{iHp} = ...
                    addRelTol(testHyperplanesVec(iHp).toStruct(true));
            end
            testHyperplanesVec=horzcat(testHyperplanesCVec{:});
            compareHyperplanesCVec=cell(size(compareHyperplanesVec));
            for iHp = 1 : numel(compareHyperplanesVec)
                compareHyperplanesCVec{iHp} = ...
                    addRelTol(compareHyperplanesVec(iHp).toStruct());
            end
            compareHyperplanesVec=horzcat(compareHyperplanesCVec{:});
            isEqVec = SInpData.isEqVec;
            %
            testedIsEqVec = eq(testHyperplanesVec,compareHyperplanesVec);
            testedNeVec = ne(testHyperplanesVec,compareHyperplanesVec);
            %
            isOk = all(isEqVec == testedIsEqVec);
            mlunitext.assert(isOk);
            %
            isOk =  all(isEqVec ~= testedNeVec);
            mlunitext.assert(isOk);
            %
            testHypHighDimFst = self.hyperplane([1:1:75]', 1); %#ok<NBRAK>
            testHypHighDimSec = self.hyperplane([1:1:75]', 2); %#ok<NBRAK>
            checkHypEqual(testHypHighDimFst, testHypHighDimSec, false, ...
                '\(1).shift-->.*\(6.666666.*e\-01).*tolerance.\(1.00000.*e\-05)',...
                '\(1).shift-->.*\(0.6666666.*).*tolerance.\(1.00000.*e\-05)');
            %
            testFstHyp = self.hyperplane([1; 0], 0);
            testSecHyp = self.hyperplane([1; 0], 0);
            testThrHyp = self.hyperplane([2; 1], 0);
            str = '\(1).shift-->.*\(6.66666.*e\-01).*tolerance.\(1.00000.*e\-05).*\n\(3).normal-->.*\(4.47213.*e\-01).*tolerance.\(1.00000.*e\-05).*';
            altStr = '\(1).shift-->.*\(0.66666666.*).*tolerance.\(1.00000.*e\-05).*\n\(3).normal-->.*\(2).*tolerance.\(1.00000.*e\-05).*';
            checkHypEqual([testHypHighDimFst testFstHyp testFstHyp], ...
                [testHypHighDimSec testSecHyp testThrHyp], ...
                [false true false], str,altStr);
        end
        %
        function self = testIsEmpty(self)
            SInpData =  self.auxReadFile(self);
            testHyperplanesVec = SInpData.testHyperplanesVec;
            isEmptyVec = SInpData.isEmptyVec;
            isEmptyTestedVec = isEmpty(testHyperplanesVec);
            isOk = all(isEmptyVec == isEmptyTestedVec);
            mlunitext.assert(isOk);

            nFstDim = 10;
            nSecDim = 20;
            nThrDim = 30;
            testHypArr(nFstDim, nSecDim, nThrDim) = self.hyperplane();
            isEmptyArr = isEmpty(testHypArr);
            isOk = all(isEmptyArr);
            mlunitext.assert(isOk);
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
            mlunitext.assert(isOk);
        end
        %
        function self = testUminus(self)
            SInpData =  self.auxReadFile(self);
            testNormalVec = SInpData.testNormalVec;
            testConstant = SInpData.testConstant;
            testHyraplane = self.hyperplane(testNormalVec, testConstant);
            minusTestHyraplane = uminus(testHyraplane);
            res = self.isNormalAndConstantRight(-testNormalVec, -testConstant,minusTestHyraplane);
            mlunitext.assert_equals(true, res);
        end
        %
        function self = testDisplay(self)
            SInpData =  self.auxReadFile(self);
            testHyperplane = SInpData.testHyperplane; %#ok<NASGU>
            evalc('display(testHyperplane);');
            testHyperplaneVec = SInpData.testHyperplaneVec; %#ok<NASGU>
            evalc('display(testHyperplaneVec);');
        end
        %
        %         function self = testPlot(self)
        %             SInpData =  self.auxReadFile(self);
        %             testHplane3D1Vec = SInpData.testHplane3D1Vec;
        %             testHplane3D2Vec = SInpData.testHplane3D2Vec;
        %             testHplane2DVec = SInpData.testHplane2DVec;
        %             STestOptions = SInpData.STestOptions;
        %             %
        %             pHandle = plot(testHplane3D1Vec);
        %             close(pHandle);
        %             pHandle = plot(testHplane2DVec);
        %             close(pHandle);
        %             pHandle = plot(testHplane3D1Vec,STestOptions);
        %             close(pHandle);
        %             pHandle = plot(testHplane3D1Vec,'g',testHplane3D2Vec,'r');
        %             close(pHandle);
        %         end
        %         function testPlotSimple(~)
        %             HA = self.hyperplane([1 0; 1 -2]'', [4 -2]);
        %             o.width = 2; o.size = [3 6.6]; o.center = [0 -2; 0 0];
        %             hFig=figure();
        %             h=plot(HA, 'r', o); hold off;
        %             close(hFig);
        %         end
        %
        function self = testWrongInput(self)
            SInpData =  self.auxReadFile(self);
            testConstant = SInpData.testConstant; %#ok<NASGU>
            testHyperplane = SInpData.testHyperplane; %#ok<NASGU>
            nanVec = SInpData.nanVector; %#ok<NASGU>
            infVec = SInpData.infVector; %#ok<NASGU>
            %
            self.runAndCheckError('contains(testHyperplane,nanVec)',...
                'wrongInput');
            self.runAndCheckError('self.hyperplane(infVec,testConstant)',...
                'wrongInput');
            self.runAndCheckError('self.hyperplane(nanVec,testConstant)',...
                'wrongInput');
        end
        %
        function self = testGetAbsTol(self)
            normVec = ones(3,1);
            const = 0;
            testAbsTol = 1;
            args = {normVec,const, 'absTol',testAbsTol};
            %
            hplaneArr = [self.hyperplane(args{:}),self.hyperplane(args{:});...
                self.hyperplane(args{:}),self.hyperplane(args{:})];
            hplaneArr(:,:,2) = [self.hyperplane(args{:}),self.hyperplane(args{:});...
                self.hyperplane(args{:}),self.hyperplane(args{:})];
            sizeArr = size(hplaneArr);
            testAbsTolArr = repmat(testAbsTol,sizeArr);
            %
            isOkArr = (testAbsTolArr == hplaneArr.getAbsTol());
            %
            isOk = all(isOkArr(:));
            mlunitext.assert(isOk);
        end
        %
        function self = testToStruct(self)
            normalCVec{1} = [1 2 3]';
            shiftCVec{1} = 3;
            normalCVec{2} = [2 3 4]';
            shiftCVec{2} = -2;
            normalCVec{3} = [1 0]';
            shiftCVec{3} = 1;
            normalCVec{4} = [1 0 0 0]';
            shiftCVec{4} = 5;
            for iElem = 1 : 4
                hpVec(iElem) = self.hyperplane(normalCVec{iElem}, shiftCVec{iElem}); %#ok<AGROW>
            end
            SHpVec = cellfun(@auxToStruct, normalCVec, shiftCVec);
            ObtainedHpStruct = hpVec(1).toStruct();
            isOk = isEqual(ObtainedHpStruct, SHpVec(1));
            ObtainedHpStructVec = hpVec.toStruct();
            isOk = isOk && all(arrayfun(@isEqual, ObtainedHpStructVec, SHpVec));

            mlunitext.assert_equals(true, isOk);

            function isEq = isEqual(SHp1, SHp2)
                isEq = abs(SHp1.shift - SHp2.shift) < 1e-6;
                isEq = isEq && all(abs(SHp1.normal - SHp2.normal) < 1e-6);
            end

            function struct = auxToStruct(normal, shift)
                multiplier = 1/norm(normal);
                if (shift < 0)
                    multiplier = -multiplier;
                end
                struct.shift = shift * multiplier;
                struct.normal = normal * multiplier;
            end
        end

        function self = testRelTol(self)
            hp = self.hyperplane();
            auxTestRelTol(hp, 1e-5);

            hp = self.hyperplane(1, 1, 'relTol', 1e-3);
            auxTestRelTol(hp, 1e-3);

            function auxTestRelTol(hp, relTol)
                isOk = hp.toStruct(true).relTol == relTol;
                mlunitext.assert_equals(true, isOk)
            end
        end
     end
%     %
    methods(Static, Access = private)
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
%
        function SInpData = auxReadFile(self)
            methodName=modgen.common.getcallernameext(2);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            %
            SInpData = load(inpFileName);
        end

    end
end

function checkHypEqual(testFstHypArr, testSecHypArr, isEqualArr, ansStr,...
    ansAltStr)
if nargin<5
    ansAltStr=ansStr;
end
[isEqArr, reportStr] = isEqual(testFstHypArr, testSecHypArr);
mlunitext.assert_equals(isEqArr, isEqualArr);
isRepEq = isequal(reportStr, ansStr);
if ~isRepEq
    isRepEq = ~isempty(regexp(reportStr, ansStr, 'once'))||...
        ~isempty(regexp(reportStr, ansAltStr, 'once'));
end
mlunitext.assert_equals(isRepEq, true);
end
