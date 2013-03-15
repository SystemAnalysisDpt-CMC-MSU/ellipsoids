classdef EllipsoidSecTestCase < mlunitext.test_case
    
% $Author: Igor Samokhin, Lomonosov Moscow State University,
% Faculty of Computational Mathematics and Cybernetics, System Analysis
% Department, 02-November-2012, <igorian.vmk@gmail.com>$
% $Copyright: Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department 2012 $

     properties (Access=private)
        testDataRootDir
     end
     methods
        function self=EllipsoidSecTestCase(varargin)
            self=self@mlunitext.test_case(varargin{:});
            [~,className]=modgen.common.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),filesep,...
                'TestData', filesep,shortClassName];
        end
        function self = testIsInside(self)
            [test1Ell, test2Ell] = createTypicalEll(11);
            compareForIsInside(test1Ell, [test1Ell test2Ell], 'i', 1);
            compareForIsInside(test1Ell, [test1Ell test2Ell], [], 0);
            [test1Ell, test2Ell] = createTypicalEll(12);
            compareForIsInside(test1Ell, [test1Ell test2Ell], 'i', 1);
            compareForIsInside(test1Ell, [test1Ell test2Ell], 'u', 0);
            [test1Ell, test2Ell] = createTypicalEll(13);
            compareForIsInside(test1Ell, [test1Ell test2Ell], 'i', -1);
            compareForIsInside(test1Ell, [test1Ell test2Ell], 'u', 0);
            [test1Ell, test2Ell] = createTypicalEll(14);
            compareForIsInside([test1Ell test2Ell], test1Ell, 'i', 0);
            compareForIsInside([test1Ell test2Ell], [test1Ell test2Ell],...
                [], 0);
        end
        function self = testIsBadDirection(self)
            import elltool.conf.Properties;
            absTol=Properties.getAbsTol();
            [test1Ell, test2Ell] = createTypicalEll(15);
            aMat = [diag(ones(6, 1)), [1; 2; 3; 3; 4; 5]];
            isTestResVec = isbaddirection(test1Ell, test2Ell, aMat,...
                absTol);
            isTestRes = any(isTestResVec);
            mlunit.assert_equals(0, isTestRes);
            [test1Ell, test2Ell] = createTypicalEll(16);
            compareExpForIsBadDir(test1Ell, test2Ell, [1, -1; 0, 0], ...
                [1, -1; 2, 3],absTol);
            [test1Ell, test2Ell] = createTypicalEll(17);
            compareExpForIsBadDir(test1Ell, test2Ell,...
            [1, -1, 1000, 1000; 0, 0, 0.5, 0.5; 0, 0, -0.5, -1],...
            [1, -1, 0, 0; 1, -2, 1, 2; 7, 3, 2, 1],absTol);
        end
        function self = testMinkmp_ea(self)
            compareAnalyticForMinkMp(true, false, 18, 5, 0, [])
            compareAnalyticForMinkMp(true, false, 19, 5, 5, true)
            compareAnalyticForMinkMp(true, false, 20, 5, 2, true)
            compareAnalyticForMinkMp(true, true, 13, 100, 100, true)
        end
        function self = testMinkmp_ia(self)
            compareAnalyticForMinkMp(false, false, 18, 5, 0, [])
            compareAnalyticForMinkMp(false, false, 19, 5, 5, true)
            compareAnalyticForMinkMp(false, false, 20, 5, 2, true)
            compareAnalyticForMinkMp(false, true, 13, 100, 100, true)
        end
        function self = testMinksum_ea(self)
            compareAnalyticForMinkSum(true, false, 21, 5, 5, true)
            compareAnalyticForMinkSum(true, false, 22, 5, 5, true)
            compareAnalyticForMinkSum(true, false, 23, 5, 5, true)
            compareAnalyticForMinkSum(true, true, 14, 100, 100, true)
        end
        function self = testMinksum_ia(self)
            compareAnalyticForMinkSum(false, false, 21, 5, 5, true)
            compareAnalyticForMinkSum(false, false, 22, 5, 5, true)
            compareAnalyticForMinkSum(false, false, 23, 5, 5, true)
            compareAnalyticForMinkSum(false, true, 14, 100, 100, true)
        end
     end
end
function [varargout] = createTypicalEll(flag)
    switch flag
        case 11
            varargout{1} = ellipsoid([2; 1], [4, 1; 1, 1]);
            varargout{2} = ell_unitball(2);
        case 12
            varargout{1} = ellipsoid([2; 1; 0], ...
                [4, 1, 1; 1, 2, 1; 1, 1, 5]);
            varargout{2} = ell_unitball(3);
        case 13
            varargout{1} = ellipsoid([5; 5; 5], ...
                [4, 1, 1; 1, 2, 1; 1, 1, 5]);
            varargout{2} = ell_unitball(3);
        case 14
            varargout{1} = ellipsoid([5; 5; 5; 5], ...
                [4, 1, 1, 1; 1, 2, 1, 1; 1, 1, 5, 1; 1, 1, 1, 6]);
            varargout{2} = ell_unitball(4);    
        case 15
            varargout{1} = ell_unitball(6);
            varargout{2} = ellipsoid(zeros(6, 1), diag(0.5 * ones(6, 1)));
        case 16
            varargout{1} = ellipsoid([5; 0], diag([4, 1]));
            varargout{2} = ellipsoid([0; 0], diag([1 / 8, 1/ 2]));
        case 17
            varargout{1} = ellipsoid([0; 0; 0], diag([4, 1, 1]));
            varargout{2} = ellipsoid([0; 0; 0], ...
                diag([1 / 8, 1/ 2, 1 / 2]));
        case 18
            varargout{1} = [3; 3; 8; 3; 23];
            varargout{2} = diag(ones(1, 5));
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = [6.5; 1; 1; 1; 1];
            varargout{5} = diag([5, 2, 2, 2, 2]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = [3; 3; 65; 4; 23];
            varargout{8} = diag([13, 3, 2, 2, 2]);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = [3; 8; 3; 2; 6];
            varargout{10} = diag([7, 2, 6, 2, 2]);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
        case 19
            varargout{1} = [3; 3; 8; 3; 23];
            varargout{2} = diag(ones(1, 5));
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = [6.5; 1; 1; 1; 1];
            varargout{5} = diag([0.25, 0.25, 0.25, 0.25, 0.25]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = [3; 3; 65; 4; 23];
            varargout{8} = diag([13, 3, 2, 2, 2]);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = [3; 8; 3; 2; 6];
            varargout{10} = diag([7, 2, 6, 2, 2]);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
         case 20
            varargout{1} = [3; 76; 8; 3; 23];
            varargout{2} = diag([3, 5, 6, 2, 7]);
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = [6.5; 1.345; 1.234; 114; 241];
            varargout{5} = diag([2, 3, 1.5, 0.6, 2]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = [7; 33; 45; 42; 3];
            varargout{8} = diag([3, 34, 23, 22, 21]);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = [32; 81; 36; -2325; -6];
            varargout{10} = diag([34, 12, 8, 17, 7]);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
        case 21
            varargout{1} = [3; 61; 2; 34; 3];
            varargout{2} = diag(5 * ones(1, 5));
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = 0;
            varargout{4} = 0;
            varargout{5} = 0;
            varargout{6} = 0;
            varargout{7} = test0Ell;
        case 22
            varargout{1} = [3; 61; 2; 34; 3];
            varargout{2} = diag(5 * ones(1, 5));
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = [31; 34; 51; 42; 3];
            varargout{4} = diag([13, 3, 22, 2, 24]);
            test1Ell = ellipsoid(varargout{3}, varargout{4});
            varargout{5} = [3; 8; 23; 12; 6];
            varargout{6} = diag([7, 6, 6, 8, 2]);
            test2Ell = ellipsoid(varargout{5}, varargout{6});
            varargout{7} = [test0Ell, test1Ell, test2Ell];
        case 23    
            varargout{1} = [32; 0; 8; 1; 23];
            varargout{2} = diag([3, 5, 6, 5, 2]);
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = [7; 3; 5; 42; 3];
            varargout{4} = diag([32, 34, 23, 12, 21]);
            test1Ell = ellipsoid(varargout{3}, varargout{4});
            varargout{5} = [32; 81; 36; -25; -62];
            varargout{6} = diag([4, 12, 1, 1, 75]);
            test2Ell = ellipsoid(varargout{5}, varargout{6});
            varargout{7} = [test0Ell, test1Ell, test2Ell];
        otherwise
    end
end

function [varargout] = createTypicalHighDimEll(flag)
    switch flag
        case 13
            varargout{1} = rand(100, 1);
            varargout{2} = diag([5 * ones(1, 50), 2 * ones(1, 50)]);
            varargout{3} = ellipsoid(varargout{1}, varargout{2});
            varargout{4} = rand(100, 1);
            varargout{5} = diag([0.5 * ones(1, 50), 0.2 * ones(1, 50)]);
            varargout{6} = ellipsoid(varargout{4}, varargout{5});
            varargout{7} = rand(100, 1);
            varargout{8} = diag(10 * rand(1, 100) + 0.5);
            test1Ell = ellipsoid(varargout{7}, varargout{8});
            varargout{9} = rand(100, 1);
            varargout{10} = diag(10 * rand(1, 100) + 0.5);
            test2Ell = ellipsoid(varargout{9}, varargout{10});
            varargout{11} = [test1Ell, test2Ell];
        case 14
            varargout{1} = rand(100, 1);
            varargout{2} = diag(10 * rand(1, 100) + 0.3);
            test0Ell = ellipsoid(varargout{1}, varargout{2});
            varargout{3} = rand(100, 1);
            varargout{4} = diag(10 * rand(1, 100) + 0.3);
            test1Ell = ellipsoid(varargout{3}, varargout{4});
            varargout{5} = rand(100, 1);
            varargout{6} = diag(10 * rand(1, 100) + 0.3);
            test2Ell = ellipsoid(varargout{5}, varargout{6});
            varargout{7} = [test0Ell, test1Ell, test2Ell];    
        otherwise
    end
end
function analyticResEllVec = calcExpMinkMp(isExtApx, nDirs, aMat,...
    e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, qVec, qMat)
    analyticResVec = e0Vec - qVec + e1Vec + e2Vec;
    analyticResEllVec(nDirs) = ellipsoid;
    for iDir = 1 : nDirs
        lVec = aMat(:, iDir);
        if (isExtApx == 1) % minkmp_ea
            supp1Mat = sqrt(e0Mat);
            supp1Mat = 0.5 * (supp1Mat + supp1Mat.');
            supp1Vec = supp1Mat * lVec;
            supp2Mat = sqrt(qMat);
            supp2Mat = 0.5 * (supp2Mat + supp2Mat.');
            supp2Vec = supp2Mat * lVec;
            [unitaryU1Mat, ~, unitaryV1Mat] = svd(supp1Vec);
            [unitaryU2Mat, ~, unitaryV2Mat] = svd(supp2Vec);
            sMat = unitaryU1Mat * unitaryV1Mat * ...
                unitaryV2Mat.' * unitaryU2Mat.';
            sMat = real(sMat);
            qStarMat = supp1Mat - sMat * supp2Mat;
            qPlusMat = qStarMat.' * qStarMat;
            qPlusMat = 0.5 * (qPlusMat + qPlusMat.');
            aDouble = sqrt(dot(lVec, qPlusMat * lVec));
            a1Double = sqrt(dot(lVec, e1Mat * lVec));
            a2Double = sqrt(dot(lVec, e2Mat * lVec));
            analyticResMat = (aDouble + a1Double + a2Double) .* ...
                ( qPlusMat ./ aDouble + e1Mat ./ a1Double + ...
                e2Mat ./ a2Double);
        else % minkmp_ia
            pDouble  = (sqrt(dot(lVec, e0Mat * lVec))) / ...
                (sqrt(dot(lVec, qMat * lVec)));
            qMinusMat  = (1 - (1 / pDouble)) * e0Mat + ...
                (1 - pDouble) * qMat;
            qMinusMat = 0.5 * (qMinusMat + qMinusMat.');
            supp1Mat = sqrtm(qMinusMat);
            supp2Mat = sqrtm(e1Mat);
            supp3Mat = sqrtm(e2Mat);
            supp1lVec = supp1Mat * lVec;
            supp2lVec = supp2Mat * lVec;
            supp3lVec = supp3Mat * lVec;
            [unitaryU1Mat, ~, unitaryV1Mat] = svd(supp1lVec);
            [unitaryU2Mat, ~, unitaryV2Mat] = svd(supp2lVec);
            [unitaryU3Mat, ~, unitaryV3Mat] = svd(supp3lVec);
            s2Mat = unitaryU1Mat * unitaryV1Mat * unitaryV2Mat.' * ...
                unitaryU2Mat.';
            s2Mat = real(s2Mat);
            s3Mat = unitaryU1Mat * unitaryV1Mat * unitaryV3Mat.' * ...
                unitaryU3Mat.';
            s3Mat = real(s3Mat);
            qStarMat = supp1Mat + s2Mat * supp2Mat + s3Mat * supp3Mat;
            analyticResMat = qStarMat' * qStarMat;
        end
            analyticResEllVec(1, iDir) = ellipsoid(analyticResVec, ...
                analyticResMat);
    end
end
function analyticResEllVec = calcExpMinkSum(isExtApx, nDirs, aMat, ...
    e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat)
    analyticResVec = e0Vec + e1Vec + e2Vec;
    analyticResEllVec(nDirs) = ellipsoid;
    for iDir = 1 : nDirs
        lVec = aMat(:, iDir);
        if isExtApx % minksum_ea
            a0Double = sqrt(dot(lVec, e0Mat * lVec));
            a1Double = sqrt(dot(lVec, e1Mat * lVec));
            a2Double = sqrt(dot(lVec, e2Mat * lVec));
            analyticResMat = (a0Double + a1Double + a2Double) .* ...
                ( e0Mat ./ a0Double + e1Mat ./ a1Double + ...
                e2Mat ./ a2Double);
        else % minksum_ia
            supp1Mat = sqrtm(e0Mat);
            supp2Mat = sqrtm(e1Mat);
            supp3Mat = sqrtm(e2Mat);
            supp1lVec = supp1Mat * lVec;
            supp2lVec = supp2Mat * lVec;
            supp3lVec = supp3Mat * lVec;
            [unitaryU1Mat, ~, unitaryV1Mat] = svd(supp1lVec);
            [unitaryU2Mat, ~, unitaryV2Mat] = svd(supp2lVec);
            [unitaryU3Mat, ~, unitaryV3Mat] = svd(supp3lVec);
            s2Mat = unitaryU1Mat * unitaryV1Mat * unitaryV2Mat.' ...
                * unitaryU2Mat.';
            s2Mat = real(s2Mat);
            s3Mat = unitaryU1Mat * unitaryV1Mat * unitaryV3Mat.' * ...
                unitaryU3Mat.';
            s3Mat = real(s3Mat);
            qStarMat = supp1Mat + s2Mat * supp2Mat + s3Mat * supp3Mat;
            analyticResMat = qStarMat.' * qStarMat;
        end 
        analyticResEllVec(1, iDir) = ellipsoid(analyticResVec, analyticResMat);
    end
end
function compareForIsInside(test1EllVec, test2EllVec, myString, myResult)
    if isempty(myString)
        testRes = isinside(test1EllVec, test2EllVec);
    else
        testRes = isinside(test1EllVec, test2EllVec, myString);
    end
    mlunit.assert_equals(myResult, testRes);
end
function compareExpForIsBadDir(test1Ell, test2Ell, a1Mat, a2Mat,absTol)
    isTestResVec = isbaddirection(test1Ell, test2Ell, a1Mat,absTol);
    isTestRes = all(isTestResVec);
    mlunit.assert_equals(true, isTestRes);
    isTestResVec = isbaddirection(test1Ell, test2Ell, a2Mat,absTol);
    isTestRes = any(isTestResVec);
    mlunit.assert_equals(false, isTestRes);
end
function compareAnalyticForMinkMp(isEA, isHighDim, indTypicalExample, ...
    nDirs, nGoodDirs, myResult)
    if isHighDim % createTypicalHighDimEll
        [e0Vec, e0Mat, test0Ell, qVec, qMat, qEll, e1Vec, e1Mat, e2Vec, ...
            e2Mat, aEllVec] = createTypicalHighDimEll(indTypicalExample);
    else % createTypicalEll
        [e0Vec, e0Mat, test0Ell, qVec, qMat, qEll, e1Vec, e1Mat, ...
            e2Vec, e2Mat, aEllVec] = createTypicalEll(indTypicalExample);
    end
    aMat = diag(ones(1, nDirs));
    if isEA % minkmp_ea
        testRes = minkmp_ea(test0Ell, qEll, aEllVec, aMat);
    else % minkmp_ia
        testRes = minkmp_ia(test0Ell, qEll, aEllVec, aMat);
    end
    if ~isempty(myResult)
        analyticResEllVec = calcExpMinkMp(isEA, nGoodDirs, aMat, e0Vec, ...
            e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, qVec, qMat);
        [isEqVec, reportStr] = eq(analyticResEllVec, testRes);
        isEq = all(isEqVec);
        mlunit.assert_equals(true, isEq, reportStr);
    else
        mlunit.assert_equals(myResult, testRes);
    end
end
function compareAnalyticForMinkSum(isEA, isHighDim, indTypicalExample, ...
    nDirs, nGoodDirs, myResult)
    if isHighDim % createTypicalHighDimEll
        [e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, aEllVec] = ...
            createTypicalHighDimEll(indTypicalExample);
    else % createTypicalEll
        [e0Vec, e0Mat, e1Vec, e1Mat, e2Vec, e2Mat, aEllVec] = ...
            createTypicalEll(indTypicalExample);
    end
    aMat = diag(ones(1, nDirs));
    if isEA % minksum_ea
        testRes = minksum_ea(aEllVec, aMat);
    else % minksum_ia
        testRes = minksum_ia(aEllVec, aMat);
    end
    if ~isHighDim && (indTypicalExample == 21)
        test0Ell = ellipsoid(e0Vec, e0Mat);
        analyticResEllVec = [test0Ell, test0Ell, test0Ell, test0Ell, ...
            test0Ell];
        [isEqVec, reportStr] = eq(analyticResEllVec, testRes);
        isEq = all(isEqVec);
        mlunit.assert_equals(true, isEq, reportStr);
   else
        analyticResEllVec = calcExpMinkSum(isEA, nGoodDirs, aMat, e0Vec,...
            e0Mat, e1Vec, e1Mat, e2Vec, e2Mat);
        [isEqVec, reportStr] = eq(analyticResEllVec, testRes);
        isEq = all(isEqVec);
        mlunit.assert_equals(myResult, isEq, reportStr);
    end
end