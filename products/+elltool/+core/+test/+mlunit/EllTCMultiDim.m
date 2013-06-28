classdef EllTCMultiDim < mlunitext.test_case
%$Author: Igor Samokhin <igorian.vmk@gmail.com> $
%$Date: 2013-01-31 $
%$Copyright: Moscow State University,
%            Faculty of Computational Mathematics
%            and Computer Science,
%            System Analysis Department 2013 $
    
    properties (Access=private)
        testDataRootDir
     end
     methods
        function self=EllTCMultiDim(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,'TestData',...
                filesep,shortClassName];
        end
        %
        function self = testDistance(self)
            absTol = elltool.conf.Properties.getAbsTol();
            %
            % Test input of distance().
            arrSizeVec=[1, 2, 3];
            testFirstArr=ones(arrSizeVec);
            testSecArr=ellipsoid(1);
            self.runAndCheckError(...
                'distance(ones([1, 2, 3]),ellipsoid(1))',...
                'wrongInput');
            %
            % Create Data for tests
            arrSizeVec=[2, 3, 2, 2];
            testEllArray=createObjectArray(arrSizeVec,@ell_unitball,2,1,1);
            nEll=numel(testEllArray);
            %vecMat=repmat([2;0],1,nEll);
            vecArrSizeVec=[2, arrSizeVec];
            vecArray=zeros(vecArrSizeVec);
            vecArray(1,:)=2;
            ansArray=ones(arrSizeVec);
            testEll3Array=testEllArray(:,:,:,1);
            testEll2Array=testEllArray;
            testEll2Array(1)=ell_unitball(3);
            %
            % Test ellipsoid-vector distance
            checkCommonErrors('vecArray');
            checkMultyInput(testEllArray,vecArray,true);
            % Wrong dimension of vectors
            %vecArrSizeVec=[3, arrSizeVec];
            vec3Array=zeros([3,arrSizeVec]);%repmat([1;0;0],1,nEll);
            self.runAndCheckError('distance(testEllArray,vec3Array)',...
                'wrongInput');           
            %
            % Test ellipsoid-ellipsoids distance 
            testEll4Array=createObjectArray(arrSizeVec,@ellipsoid,[3;0],...
                diag([1,1]),2);
            %
            checkMultyInput(testEllArray,testEll4Array,false);
            checkCommonErrors('testEllArray');
            % wrong number of one of dims
            testEll4Array=createObjectArray(arrSizeVec(end:-1:1),...
                @ell_unitball,2,1,1);
            self.runAndCheckError('distance(testEllArray,testEll4Array)',...
                'wrongInput');
            %
            % Test ellipsoid-hiperplane distance 
            % Create data.
            arrSize2Vec=[2 arrSizeVec];
            testNormArray=zeros(arrSize2Vec);
            testNormArray(1,:)=1;
            testNormArray(2,:)=0;
            testHpArray=hyperplane(testNormArray,2);
            %
            checkMultyInput(testEllArray,testHpArray,false);
            checkCommonErrors('testHpArray');
            %
            % Test ellipsoid-polytope distance 
            % Create data.
            hMat=-eye(2);
            kVec=[-2 1]';
            qStruct=struct('H',hMat,'K',kVec);
            testPolObj=polytope(qStruct);
            %
            checkMultyInput(testEllArray,testPolObj,false);
            %
            function checkDist(obj1Array, obj2Array)
                resArray=distance(obj1Array, obj2Array);
                difVec=abs(resArray(:)-ansArray(:))<absTol;
                mlunitext.assert(all(difVec));
            end
            function checkMultyInput(obj1Array, obj2Array, isVecDist)
                checkDist(obj1Array,obj2Array);
                checkDist(obj1Array(1),obj2Array);
                if isVecDist
                    checkDist(obj1Array,obj2Array(:,1));
                else
                    checkDist(obj1Array,obj2Array(1));
                end
            end
            function checkCommonErrors(arrayStr)
              self.runAndCheckError(strcat('distance(testEll3Array,',...
                  arrayStr,')'),'wrongInput');
             self.runAndCheckError(strcat('distance(testEll2Array,',...
                  arrayStr,')'),'wrongInput');
            end
        end
        function self = testDimension(self)
            %Chek for one output argument
            %1: Empty ellipsoid
            testCorrect(true, true, 1);
            %2: Not empty ellipsoid
            testCorrect(true, true, 2);
            testCorrect(true, true, 3);
            %Chek for two output arguments
            %1: Empty ellipsoid
            testCorrect(true, false, 1);
            %2: Not empty ellipsoid
            testCorrect(true, false, 2);
            testCorrect(true, false, 3);
            testCorrect(false, false, 4);
            arraySizeVec = [2, 1, 1, 2, 3, 3, 1, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            ansDimNumArray = createObjectArray(arraySizeVec, @diag, ...
                100, 1, 1);
            ansRankNumArray = createObjectArray(arraySizeVec, @diag, ...
                50, 1, 1);
            test2Correct();
            testCorrect(true, true, 16);
            testCorrect(true, false, 16);
            function testCorrect(isTwoArg, isnRankParam, flag)
                if isTwoArg
                    [testEllArray ansNumArray, ~] = createTypicalArray(flag);
                    if isnRankParam
                        testRes = dimension(testEllArray);
                        mlunitext.assert_equals(ansNumArray, testRes);
                        if (flag == 16)
                           mlunitext.assert_equals(class(ansNumArray), ...
                               class(testRes)); 
                        end
                    else
                        [testDim, testRank] = dimension(testEllArray);
                        mlunitext.assert_equals(ansNumArray, testDim);
                        mlunitext.assert_equals(ansNumArray, testRank);
                        if (flag == 16)
                           mlunitext.assert_equals(class(ansNumArray), ...
                               class(testDim)); 
                           mlunitext.assert_equals(class(ansNumArray), ...
                               class(testRank)); 
                        end
                    end
                else
                    [testEllArray ansDimNumArray ansRankNumArray, ~] = ...
                        createTypicalArray(flag);
                    test2Correct();
                end
            end
            function test2Correct()
                [testDim, testRank] = dimension(testEllArray);
                mlunitext.assert_equals(ansDimNumArray, testDim);
                mlunitext.assert_equals(ansRankNumArray, testRank);
            end
            
        end
        function self = testIsDegenerate(self)
            %Not degerate ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(5);
            testCorrect()
            %Degenerate ellipsoids
            arraySizeVec = [2, 1, 1, 1, 3, 1, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @true, ...
                1, 1, 1);
            testCorrect()
            arraySizeVec = [1, 1, 2, 3, 1, 2, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @true, ...
                1, 1, 1);
            testCorrect()
            mlunitext.assert_equals(class(isAnsArray), class(isTestRes)); 
            [testEllArray, ~, isAnsArray] = createTypicalArray(16);
            testCorrect()
            mlunitext.assert_equals(class(isAnsArray), class(isTestRes)); 
            %Empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect()
                isTestRes = isdegenerate(testEllArray);
                mlunitext.assert_equals(isAnsArray, isTestRes);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.isdegenerate()', ...
                        'wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.isdegenerate()',...
                        errorStr);
                end
           end
        end
        function self = testIsEmpty(self)
            %Chek realy empty ellipsoid            
            arraySizeVec = [2, 1, 1, 1, 1, 3, 1, 1];
            testEllArray(2, 1, 1, 1, 1, 3, 1, 1) = ellipsoid;
            isAnsArray = createObjectArray(arraySizeVec, @true, ...
                1, 1, 1);
            testCorrect()
            %Chek not empty ellipsoid
            [testEllArray isAnsArray] = createTypicalArray(5);
            testCorrect()
            arraySizeVec = [1, 1, 1, 1, 1, 4, 1, 1, 3];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([zeros(1, 50), ones(1, 50)]), 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @false, ...
                1, 1, 1);
            testEllArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = ellipsoid;
            isAnsArray(1, 1, 1, 1, 1, 3, 1, 1, 2) = true;
            testCorrect()
            [testEllArray, ~, isAnsArray] = createTypicalArray(16);
            testCorrect()
            mlunitext.assert_equals(class(isAnsArray), class(isTestRes)); 
            function testCorrect()
                isTestRes = testEllArray.isEmpty();
                mlunitext.assert_equals(isAnsArray, isTestRes);
            end
        end
        function self = testMaxEig(self)
            checkMaxeigAndMineig(self, true);
        end
        function self = testMinEig(self)
            checkMaxeigAndMineig(self, false);
        end
        function self = testTrace(self)
            %Check degenerate matrix
            testCorrect(6);
            testCorrect(2);
            testCorrect(7);
            testCorrect(8);
            testCorrect(16);
            mlunitext.assert_equals(class(ansNumArray), class(testNumArray)); 
            %Empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect(flag)
                if (flag == 2) || (flag == 6) || (flag == 16)
                    [testEllArray ansNumArray] = createTypicalArray(flag);
                else
                    [testEllArray, ~, ~, ansNumArray] = createTypicalArray(flag);
                end
                [testNumArray] = trace(testEllArray);
                mlunitext.assert_equals(ansNumArray, testNumArray);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.trace()','wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.trace()', errorStr);
                end
            end
        end
        function self = testVolume(self)
            %Check degenerate ellipsoid
            testCorrect(4);
            %Check dim=1 with two different centers
            testCorrect(2);
            testCorrect(3);
            testCorrect(16);
            mlunitext.assert_equals(class(ansDoubleArray), ...
                class(testDoubleArray)); 
            %Empty ellipsoid
            testError(1);
            testError(14);
            testError(15);
            function testCorrect(flag)
                if  (flag == 16)
                    [testEllArray, ansDoubleArray, ~] = createTypicalArray(flag);
                elseif (flag == 2) || (flag == 3)
                    [testEllArray, ~, ansDoubleArray] = createTypicalArray(flag);
                else
                    [testEllArray, ~, ~, ansDoubleArray] = createTypicalArray(flag);
                end
                [testDoubleArray] = volume(testEllArray);
                mlunitext.assert_equals(ansDoubleArray, testDoubleArray);
            end
            function testError(flag)
                [testEllArray, ~, errorStr] = createTypicalArray(flag);
                if (flag == 1)
                    self.runAndCheckError('testEllArray.volume()','wrongInput:emptyEllipsoid');
                else
                    self.runAndCheckError('testEllArray.volume()', errorStr);
                end
            end
        end
        function self = testEq(self)
            checkEqAndNq(self, true);
        end
        function self = testNe(self)
            checkEqAndNq(self, false);
        end
        function self = testGe(self)
            checkGeAndGtAndLeAndLt(self, true, true);
        end 
        function self = testGt(self)
            checkGeAndGtAndLeAndLt(self, true, false);
        end
        function self = testLe(self)
            checkGeAndGtAndLeAndLt(self, false, true);
        end
        function self = testLt(self)
            checkGeAndGtAndLeAndLt(self, false, false);
        end
        function self = testPropertyGetters(self)
            arraySizeVec = [1, 1, 2, 1, 1, 1, 1, 1, 2, 1];
            ellCenter = ones(10, 1);
            ellMat = rand(10);
            ellMat = ellMat * ellMat.';
            testAbsTol = 3;
            testRelTol = 0.4;
            testNPlot2dPoints = 40;
            testNPlot3dPoints = 100;
            args = {ellCenter, ellMat, 'absTol', testAbsTol, 'relTol', ...
                testRelTol, 'nPlot2dPoints', testNPlot2dPoints,...
                'nPlot3dPoints', testNPlot3dPoints};
            testEllArray(1, 1, 1, 1, 1, 1, 1, 1, 1, 1) = ellipsoid(args{:});
            testEllArray(1, 1, 1, 1, 1, 1, 1, 1, 2, 1) = ellipsoid(args{:});
            testEllArray(1, 1, 2, 1, 1, 1, 1, 1, 1, 1) = ellipsoid(args{:});
            testEllArray(1, 1, 2, 1, 1, 1, 1, 1, 2, 1) = ellipsoid(args{:});
            testAbsTolArray = createObjectArray(arraySizeVec, @repmat, ... 
                testAbsTol, 1, 2);
            testRelTolArray = createObjectArray(arraySizeVec, @repmat, ... 
                testRelTol, 1, 2);
            testNPlot2dPointsArray = createObjectArray(arraySizeVec, @repmat, ... 
                testNPlot2dPoints, 1, 2);
            testNPlot3dPointsArray = createObjectArray(arraySizeVec, @repmat, ... 
                testNPlot3dPoints, 1, 2);
            mlunitext.assert_equals(testAbsTolArray, testEllArray.getAbsTol());
            mlunitext.assert_equals(testRelTolArray, testEllArray.getRelTol());
            mlunitext.assert_equals(testNPlot2dPointsArray, ...
                testEllArray.getNPlot2dPoints());
            mlunitext.assert_equals(testNPlot3dPointsArray, ...
                testEllArray.getNPlot3dPoints());
        end
     end
 end
function [varargout] = createTypicalArray(flag)
    arraySizeVec = [2, 1, 1, 2, 1, 3, 1];
    switch flag
        case 1
            arraySizeVec = [2, 1, 3, 2, 1, 1, 4];
            testEllArray(2, 1, 3, 2, 1, 1, 4) = ellipsoid;
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            isAnsArray = true(arraySizeVec);
            errorStr = 'emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = isAnsArray;
            varargout{4} = errorStr;
        case 2
            arraySizeVec = [1, 2, 4, 3, 2, 1];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                1, 1, 1);
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                1, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySizeVec, @diag, ...
                2, 1, 1);
            isAnsArray = true(arraySizeVec);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
            varargout{4} = isAnsArray;
        case 3
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                eye(5), 1, 1);
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                5, 1, 1);
            volumeDouble = 8 * (pi ^ 2) / 15;
            ansVolumeDoubleArray = createObjectArray(arraySizeVec, @diag, ...
                volumeDouble, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
            varargout{3} = ansVolumeDoubleArray;
        case 4
            arraySizeVec = [2, 1, 3, 2, 1, 1, 4, 1, 1];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag([1, 2, 3, 4, 0]), 1, 1);
            ansDimNumArray = createObjectArray(arraySizeVec, @diag, ...
                5, 1, 1);
            ansRankNumArray = createObjectArray(arraySizeVec, @diag, ...
                4, 1, 1);
            ansVolumeDoubleArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansDimNumArray;
            varargout{3} = ansRankNumArray;
            varargout{4} = ansVolumeDoubleArray;
        case 5
            arraySizeVec = [1, 2, 4, 3, 2];
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                1, 1, 1);
            isAnsArray = createObjectArray(arraySizeVec, @false, ...
                1, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = isAnsArray;
        case 6
            arraySizeVec = [1, 1, 2, 3, 2, 1, 1, 1, 4];
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                diag(zeros(1, 100)), 1, 1);
            ansNumArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansNumArray;
        case 7
            arraySizeVec = [2, 3, 2, 1, 1, 1, 4, 1, 1];
            myMat = diag(0 : 1 : 100);
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySizeVec, @diag, ...
                100, 1, 1);
            ansMinNumArray = createObjectArray(arraySizeVec, @diag, ...
                0, 1, 1);
            ansTraceNumArray = createObjectArray(arraySizeVec, @diag, ...
                sum(0 : 1 : 100), 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        case 8
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            myMat = rand(10);
            myMat = myMat * myMat.';
            testEllArray = createObjectArray(arraySizeVec, @ellipsoid, ...
                myMat, 1, 1);
            ansMaxNumArray = createObjectArray(arraySizeVec, @diag, ...
                max(eig(myMat)), 1, 1);
            ansMinNumArray = createObjectArray(arraySizeVec, @diag, ...
                min(eig(myMat)), 1, 1);
            ansTraceNumArray = createObjectArray(arraySizeVec, @diag, ...
                trace(myMat), 1, 1);
            varargout{1} = testEllArray;
            varargout{2} = ansMaxNumArray;
            varargout{3} = ansMinNumArray;
            varargout{4} = ansTraceNumArray;
        case 9
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySizeVec = [1, 1, 1, 1, 1, 7, 1, 1, 7];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                2, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                diag([1 + MAX_TOL, 1 + MAX_TOL]) , 1, 1);
            isAnsArray = true(arraySizeVec);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
        case 10
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySizeVec = [1, 1, 2, 1, 1, 1, 2, 1, 1];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                5, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                diag(repmat(1 + 100 * MAX_TOL, 1, 5)), 1, 1);
            isAnsArray = false(arraySizeVec);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
        case 11
            arraySizeVec = [1, 1, 3, 1, 1, 1, 2, 1, 1];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                5, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                4, 1, 1);
            isAnsArray = false(arraySizeVec);
            reportStr = 'wrongInput';
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
            varargout{4} = reportStr;
        case 12
            import elltool.conf.Properties;
            MAX_TOL = Properties.getRelTol();
            arraySizeVec = [1, 1, 2, 1, 1, 1, 1, 1, 2];
            my1EllArray = createObjectArray(arraySizeVec, @ell_unitball, ... 
                10, 1, 1);
            my2EllArray = createObjectArray(arraySizeVec, @ellipsoid, ... 
                (2 * MAX_TOL) * ones(10, 1), eye(10), 2);
            isAnsArray = false(arraySizeVec);
            varargout{1} = my1EllArray;
            varargout{2} = my2EllArray;
            varargout{3} = isAnsArray;
        case 13
            testEllArray = ellipsoid.empty(1, 0, 0, 1, 5);
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyArray';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 14
            testEllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            testEllArray(2, 1, 1, 2, 1, 3, 1) = ellipsoid;
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 15
            testEllArray = createObjectArray(arraySizeVec, @(x)ellipsoid(), ...
                3, 1, 1);
            test2EllArray = createObjectArray(arraySizeVec, @ell_unitball, ...
                3, 1, 1);
            errorStr = 'wrongInput:emptyEllipsoid';
            varargout{1} = testEllArray;
            varargout{2} = test2EllArray;
            varargout{3} = errorStr;
        case 16
            arraySizeVec = [1, 0, 0, 1, 5];
            testEllArray = ellipsoid.empty(arraySizeVec);
            ansDoubleArray = zeros(arraySizeVec);
            isAnsArray = true(arraySizeVec);
            varargout{1} = testEllArray;
            varargout{2} = ansDoubleArray;
            varargout{3} = isAnsArray;
        otherwise
    end
end
function objectArray = createObjectArray(arraySizeVec, func, firstArg, ...
    secondArg, nArg)
    nElems = prod(arraySizeVec, 2);
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
    objectArray = reshape([objectCArray{:}], arraySizeVec);
end
function checkMaxeigAndMineig(self, isMaxeigCheck)
    %Check degenerate matrix
    testCorrect(6);
    testCorrect(2);
    testCorrect(7);
    testCorrect(8);
    testCorrect(16);
    mlunitext.assert_equals(class(ansNumArray), class(testNumArray)); 
    %Check empty ellipsoid
    testError(1);
    testError(14);
    testError(15);
    function testCorrect(flag)
        if isMaxeigCheck
            [testEllArray ansNumArray] = createTypicalArray(flag);
            [testNumArray] = maxeig(testEllArray);
        else
            if (flag == 2) || (flag == 6) || (flag == 16)
                [testEllArray ansNumArray] = createTypicalArray(flag);
            else
                [testEllArray, ~, ansNumArray] = createTypicalArray(flag);
            end
            [testNumArray] = mineig(testEllArray);
        end
        mlunitext.assert_equals(ansNumArray, testNumArray);
    end
    function testError(flag)
        [testEllArray, ~, errorStr] = createTypicalArray(flag);
        if isMaxeigCheck
            if (flag == 1)
                self.runAndCheckError('testEllArray.maxeig()','wrongInput:emptyEllipsoid');
            else
                self.runAndCheckError('testEllArray.maxeig()', errorStr);
            end
        else
            if (flag == 1)
                self.runAndCheckError('testEllArray.mineig()','wrongInput:emptyEllipsoid');
            else
                self.runAndCheckError('testEllArray.mineig()', errorStr);
            end
        end
    end
end
function checkEqAndNq(self, isEqCheck)
    isAnsArray = [];
    testCorrect(1);
    testCorrect(2);
    testCorrect(9);
    testCheckCorrect()
    testCorrect(10);
    testCheckCorrect()
    testCorrect(11);
    testCorrect(12);
    [test1EllArray, test2EllArray, errorStr] = createTypicalArray(13);
    if isEqCheck
        self.runAndCheckError('eq(test1EllArray, test2EllArray)', ...
            errorStr);
        self.runAndCheckError('eq(test2EllArray, test1EllArray)', ... 
            errorStr);
    else
        self.runAndCheckError('ne(test1EllArray, test2EllArray)', ...
            errorStr);
        self.runAndCheckError('ne(test2EllArray, test1EllArray)', ... 
            errorStr);
    end
    function testCheckCorrect()
        if isEqCheck
            mlunitext.assert_equals(isAnsArray, ...
                test1EllArray.eq(test2EllArray));
            mlunitext.assert_equals(isAnsArray, ...
                test2EllArray.eq(test1EllArray));
        else
            mlunitext.assert_equals(isAnsArray, ...
                test1EllArray.ne(test2EllArray));
            mlunitext.assert_equals(isAnsArray, ...
                test2EllArray.ne(test1EllArray));
        end
    end
    function testCorrect(flag)
        myReportStr = '';
        if (flag == 1)
            [test1EllArray, ~, isAnsArray, ~] = ...
                createTypicalArray(flag);
            [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
        elseif (flag == 2)
            [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
            [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
        else
            [test1EllArray, test2EllArray, isAnsArray] = ...
                createTypicalArray(flag);
        end
        if isEqCheck
            [isTestArray, reportStr] = isEqual(test1EllArray, test2EllArray);
        else
            isAnsArray = ~isAnsArray;
            isTestArray = ne(test1EllArray, test2EllArray);
        end
        mlunitext.assert_equals(isTestArray, isAnsArray);
        if isEqCheck && ((flag == 1) || (flag == 2) || (flag == 9))
            mlunitext.assert_equals(myReportStr, reportStr);
        end
    end
end
function checkGeAndGtAndLeAndLt(self, isG, isE)
    isAnsArray = [];
    test1EllArray = [];
    test2EllArray = [];
    testCorrect(2);
    testCorrect(9);
    testCorrect(10);
    testCorrect(12);
    testError(1);
    testError(11);
    testError(13);
    testError(14);
    testError(15);
    function testCheckCorrect()
        if isG
            if isE
                mlunitext.assert_equals(isAnsArray, ...
                    test1EllArray.ge(test2EllArray));
                mlunitext.assert_equals(~isAnsArray, ...
                    test2EllArray.ge(test1EllArray));
            else
                mlunitext.assert_equals(isAnsArray, ...
                    test1EllArray.gt(test2EllArray));
                mlunitext.assert_equals(~isAnsArray, ...
                    test2EllArray.gt(test1EllArray));
            end
        elseif isE
            mlunitext.assert_equals(isAnsArray, ...
                test1EllArray.le(test2EllArray));
            mlunitext.assert_equals(~isAnsArray, ...
                test2EllArray.le(test1EllArray));
        else
            mlunitext.assert_equals(isAnsArray, ...
                test1EllArray.lt(test2EllArray));
            mlunitext.assert_equals(~isAnsArray, ...
                test2EllArray.lt(test1EllArray));
        end
    end
    function testCorrect(flag)
        if (flag == 2)
            [test1EllArray, ~, ~, ~] = createTypicalArray(flag);
            [test2EllArray, ~, ~, isAnsArray] = createTypicalArray(flag);
        else
            [test1EllArray, test2EllArray, isAnsArray] = ...
                createTypicalArray(flag);
        end
        if (flag == 12) || (isG && (flag == 9)) || (~isG && (flag == 10))
            isAnsArray = ~isAnsArray;
        end
        if (flag == 9) || (flag == 10)
            testCheckCorrect();
        end
        if isG
            if isE
                testResArray = ge(test1EllArray, test2EllArray);
            else
                testResArray = gt(test1EllArray, test2EllArray);
            end
        elseif isE
            testResArray = le(test1EllArray, test2EllArray);
        else
            testResArray = le(test1EllArray, test2EllArray);
        end
        mlunitext.assert_equals(isAnsArray, testResArray);
    end
    function testError(flag)
        if (flag == 1)
            [test1EllArray, ~, ~, errorStr] = ...
                createTypicalArray(flag);
            [test2EllArray, ~, ~, ~] = createTypicalArray(flag);
        elseif (flag == 11)
            [test1EllArray, test2EllArray, ~, errorStr] = ...
                createTypicalArray(flag);
        else
            [test1EllArray, test2EllArray, errorStr] = ...
                createTypicalArray(flag);
        end
        if isG
            if isE
                self.runAndCheckError('test1EllArray.ge(test2EllArray)',...
                    errorStr);
            else
                self.runAndCheckError('test1EllArray.gt(test2EllArray)',...
                    errorStr);
            end
        elseif isE
            self.runAndCheckError('test1EllArray.le(test2EllArray)',...
                errorStr);
        else
            self.runAndCheckError('test1EllArray.lt(test2EllArray)',...
                errorStr);
        end
    end
end